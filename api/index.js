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

// Supabase client
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
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
        res.json(data || []);
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

        const receiptFilename = req.file ? `receipt-${Date.now()}-${req.file.originalname}` : null;
        
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
