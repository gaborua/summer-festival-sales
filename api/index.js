const express = require('express');
const cors = require('cors');
const multer = require('multer');
const { createClient } = require('@supabase/supabase-js');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Multer en memoria (Vercel no permite escribir en disco)
// Nota: Vercel suele tener límite de payload ~4.5MB. Usamos 4MB por seguridad.
const upload = multer({ 
    storage: multer.memoryStorage(),
    limits: { fileSize: 4 * 1024 * 1024 } // 4MB
});

// Helper para nombres de archivo seguros
function sanitizeFilename(name) {
    return name
        .toLowerCase()
        .replace(/[^a-z0-9\.\-]+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');
}

// Supabase client
// Prefer service role on the server to bypass RLS for backend-only operations
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
const supabase = createClient(
    process.env.SUPABASE_URL,
    SUPABASE_KEY
);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK',
        timestamp: new Date().toISOString()
    });
});

// Obtener todas las ventas
app.get('/api/sales', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('sales')
            .select('*')
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        // Adjuntar URL pública del comprobante si existe
        const withUrls = (data || []).map((row) => {
            let receipt_url = null;
            if (row.receipt_filename) {
                const { data: pub } = supabase
                    .storage
                    .from('receipts')
                    .getPublicUrl(row.receipt_filename);
                receipt_url = pub?.publicUrl || null;
            }
            return { ...row, receipt_url };
        });
        res.json(withUrls);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener estadísticas
app.get('/api/stats', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('sales')
            .select('ticket_quantity');
        
        if (error) throw error;

        const totalSales = data.length;
        const totalTickets = data.reduce((sum, sale) => sum + sale.ticket_quantity, 0);
        
        res.json({ totalSales, totalTickets });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Registrar nueva venta
app.post('/api/sales', upload.single('receipt'), async (req, res) => {
    try {
        const { team_leader, rrpp_name, ticket_quantity, city } = req.body;
        
        if (!team_leader || !rrpp_name || !ticket_quantity) {
            return res.status(400).json({ error: 'Todos los campos son obligatorios' });
        }

        // Ciudad: si no viene, usar 'General' para compatibilidad
        const cityValue = (typeof city === 'string' && city.trim().length > 0)
            ? city.trim()
            : 'General';

        let receiptFilename = null;
        if (req.file) {
            const ts = Date.now();
            const safeName = sanitizeFilename(req.file.originalname || 'comprobante');
            const storagePath = `${ts}-${safeName}`;

            // Subir a Supabase Storage (bucket: receipts, público)
            let uploadError;
            const { error: upErr } = await supabase
                .storage
                .from('receipts')
                .upload(storagePath, req.file.buffer, {
                    contentType: req.file.mimetype || 'application/octet-stream',
                    upsert: false
                });
            uploadError = upErr;

            // Si falla por bucket inexistente, intentamos crearlo (requiere service role)
            if (uploadError && /not found|No such file|bucket/i.test(uploadError.message || '')) {
                try {
                    await supabase.storage.createBucket('receipts', { public: true });
                    const again = await supabase
                        .storage
                        .from('receipts')
                        .upload(storagePath, req.file.buffer, {
                            contentType: req.file.mimetype || 'application/octet-stream',
                            upsert: false
                        });
                    if (again.error) throw again.error;
                    uploadError = null;
                } catch (e) {
                    uploadError = e;
                }
            }

            if (uploadError) {
                return res.status(500).json({ error: `Error al subir comprobante: ${uploadError.message || uploadError}` });
            }

            receiptFilename = storagePath;
        }
        
        const { data, error } = await supabase
            .from('sales')
            .insert([{
                team_leader,
                rrpp_name,
                ticket_quantity: parseInt(ticket_quantity),
                city: cityValue,
                receipt_filename: receiptFilename
            }])
            .select();
        
        if (error) throw error;
        
        res.json({
            success: true,
            id: data[0].id,
            message: 'Venta registrada exitosamente'
        });
    } catch (error) {
        // Errores de Multer (p.ej. tamaño excedido)
        if (error instanceof multer.MulterError) {
            if (error.code === 'LIMIT_FILE_SIZE') {
                return res.status(413).json({ error: 'El archivo es demasiado grande. Máximo 4MB.' });
            }
            return res.status(400).json({ error: `Error de carga: ${error.message}` });
        }
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// Para desarrollo local
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Server running on http://localhost:${PORT}`);
    });
}

// Exportar para Vercel
module.exports = app;
