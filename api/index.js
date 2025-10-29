const express = require('express');
const cors = require('cors');
const multer = require('multer');
const { createClient } = require('@supabase/supabase-js');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Multer para memoria (Vercel no tiene filesystem)
const upload = multer({ 
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 }
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
        const { team_leader, rrpp_name, ticket_quantity } = req.body;
        
        if (!team_leader || !rrpp_name || !ticket_quantity) {
            return res.status(400).json({ error: 'Todos los campos son obligatorios' });
        }

        const receiptFilename = req.file ? `receipt-${Date.now()}-${req.file.originalname}` : null;
        
        const { data, error } = await supabase
            .from('sales')
            .insert([{
                team_leader,
                rrpp_name,
                ticket_quantity: parseInt(ticket_quantity),
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
        res.status(500).json({ error: error.message });
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
