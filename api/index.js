const express = require('express');
const cors = require('cors');
const path = require('path');
const multer = require('multer');
const { createClient } = require('@supabase/supabase-js');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../')));

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
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
const supabase = createClient(
    process.env.SUPABASE_URL,
    SUPABASE_KEY
);

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Función para obtener URL pública de un archivo en storage
function getPublicUrl(bucketName, filename) {
    if (!filename) return null;
    const { data } = supabase.storage.from(bucketName).getPublicUrl(filename);
    return data?.publicUrl || null;
}

// Función para subir archivo a storage
async function uploadFile(bucketName, file, prefix = '') {
    if (!file) return null;

    const ts = Date.now();
    const safeName = sanitizeFilename(file.originalname || 'file');
    const storagePath = prefix ? `${prefix}/${ts}-${safeName}` : `${ts}-${safeName}`;

    // Intentar subir
    let { error } = await supabase.storage
        .from(bucketName)
        .upload(storagePath, file.buffer, {
            contentType: file.mimetype || 'application/octet-stream',
            upsert: false
        });

    // Si el bucket no existe, intentar crearlo
    if (error && /not found|No such file|bucket/i.test(error.message || '')) {
        try {
            await supabase.storage.createBucket(bucketName, { public: true });
            const retry = await supabase.storage
                .from(bucketName)
                .upload(storagePath, file.buffer, {
                    contentType: file.mimetype || 'application/octet-stream',
                    upsert: false
                });
            if (retry.error) throw retry.error;
            error = null;
        } catch (e) {
            error = e;
        }
    }

    if (error) throw error;
    return storagePath;
}

// ============================================================================
// ENDPOINTS
// ============================================================================

// Health check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        version: '2.0'
    });
});

// ============================================================================
// EVENTOS
// ============================================================================

// Obtener todos los eventos
app.get('/api/events', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('events')
            .select('*')
            .order('event_date', { ascending: true });

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener un evento por ID
app.get('/api/events/:id', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('events')
            .select('*')
            .eq('id', req.params.id)
            .single();

        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener eventos activos
app.get('/api/events/active', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('events')
            .select('*')
            .eq('status', 'activo')
            .order('event_date', { ascending: true });

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================================================
// PAQUETES
// ============================================================================

// Obtener todos los paquetes con sus eventos
app.get('/api/packages', async (req, res) => {
    try {
        const { data: packages, error } = await supabase
            .from('packages')
            .select(`
                *,
                package_events (
                    event_id,
                    events (*)
                )
            `)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json(packages || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener paquetes activos
app.get('/api/packages/active', async (req, res) => {
    try {
        const { data: packages, error } = await supabase
            .from('packages')
            .select(`
                *,
                package_events (
                    event_id,
                    events (*)
                )
            `)
            .eq('active', true)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json(packages || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================================================
// VENTAS
// ============================================================================

// Obtener todas las ventas (usando vista detallada)
app.get('/api/sales', async (req, res) => {
    try {
        const { sale_type } = req.query;

        let query = supabase.from('sales').select('*').order('created_at', { ascending: false });

        if (sale_type) {
            query = query.eq('sale_type', sale_type);
        }

        const { data, error } = await query;
        if (error) throw error;

        // Adjuntar URL pública del comprobante
        const withUrls = (data || []).map((row) => ({
            ...row,
            receipt_url: getPublicUrl('receipts', row.receipt_filename)
        }));

        res.json(withUrls);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener resumen de ventas (usando vista)
app.get('/api/sales/summary', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_sales_summary')
            .select('*');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener ventas de paquetes (detalladas)
app.get('/api/sales/packages', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_package_sales_detail')
            .select('*');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener ventas individuales (detalladas)
app.get('/api/sales/individual', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_individual_sales_detail')
            .select('*');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener estadísticas generales
app.get('/api/stats', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_system_stats')
            .select('*')
            .single();

        if (error) throw error;
        res.json(data || {});
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Registrar nueva venta (paquete o individual)
app.post('/api/sales', upload.single('receipt'), async (req, res) => {
    try {
        const {
            sale_type,
            package_id,
            event_ids, // Array de IDs de eventos (solo para ventas individuales)
            customer_name,
            customer_phone,
            customer_email,
            customer_id_number,
            ticket_quantity,
            unit_price,
            total_amount,
            team_leader,
            rrpp_name,
            rrpp_commission,
            payment_method,
            payment_status,
            notes
        } = req.body;

        // Validaciones
        if (!sale_type || !customer_name || !ticket_quantity || !unit_price || !total_amount) {
            return res.status(400).json({
                error: 'Campos requeridos: sale_type, customer_name, ticket_quantity, unit_price, total_amount'
            });
        }

        if (sale_type === 'package' && !package_id) {
            return res.status(400).json({ error: 'package_id es requerido para ventas de paquetes' });
        }

        if (sale_type === 'individual' && (!event_ids || !Array.isArray(event_ids) || event_ids.length === 0)) {
            return res.status(400).json({ error: 'event_ids es requerido para ventas individuales' });
        }

        // Subir comprobante si existe
        let receiptFilename = null;
        if (req.file) {
            receiptFilename = await uploadFile('receipts', req.file, 'sales');
        }

        // Insertar venta
        const { data: sale, error: saleError } = await supabase
            .from('sales')
            .insert([{
                sale_type,
                package_id: sale_type === 'package' ? package_id : null,
                customer_name,
                customer_phone: customer_phone || null,
                customer_email: customer_email || null,
                customer_id_number: customer_id_number || null,
                ticket_quantity: parseInt(ticket_quantity),
                unit_price: parseFloat(unit_price),
                total_amount: parseFloat(total_amount),
                team_leader: team_leader || null,
                rrpp_name: rrpp_name || null,
                rrpp_commission: rrpp_commission ? parseFloat(rrpp_commission) : null,
                payment_method: payment_method || 'transferencia',
                payment_status: payment_status || 'pendiente',
                receipt_filename: receiptFilename,
                notes: notes || null
            }])
            .select()
            .single();

        if (saleError) throw saleError;

        // Si es venta individual, insertar relaciones con eventos
        if (sale_type === 'individual' && event_ids && event_ids.length > 0) {
            const saleEvents = event_ids.map(event_id => ({
                sale_id: sale.id,
                event_id: parseInt(event_id)
            }));

            const { error: eventsError } = await supabase
                .from('sale_events')
                .insert(saleEvents);

            if (eventsError) throw eventsError;
        }

        res.json({
            success: true,
            id: sale.id,
            message: 'Venta registrada exitosamente',
            data: sale
        });
    } catch (error) {
        if (error instanceof multer.MulterError) {
            if (error.code === 'LIMIT_FILE_SIZE') {
                return res.status(413).json({ error: 'El archivo es demasiado grande. Máximo 4MB.' });
            }
            return res.status(400).json({ error: `Error de carga: ${error.message}` });
        }
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// Actualizar una venta
app.patch('/api/sales/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = {};

        // Solo actualizar campos que vengan en el request
        const allowedFields = [
            'customer_name', 'customer_phone', 'customer_email', 'customer_id_number',
            'ticket_quantity', 'unit_price', 'total_amount', 'team_leader', 'rrpp_name',
            'rrpp_commission', 'payment_method', 'payment_status', 'tickets_delivered',
            'packages_delivered', 'delivery_date', 'delivery_notes', 'notes'
        ];

        allowedFields.forEach(field => {
            if (req.body[field] !== undefined) {
                updateData[field] = req.body[field];
            }
        });

        if (Object.keys(updateData).length === 0) {
            return res.status(400).json({ error: 'No hay datos para actualizar' });
        }

        const { data, error } = await supabase
            .from('sales')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({
            success: true,
            message: 'Venta actualizada exitosamente',
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// Actualizar estado de entrega
app.patch('/api/sales/:id/delivery', async (req, res) => {
    try {
        const { id } = req.params;
        const { tickets_delivered, packages_delivered, delivery_notes } = req.body;

        const updateData = {
            delivery_date: new Date().toISOString()
        };

        if (tickets_delivered !== undefined) updateData.tickets_delivered = tickets_delivered;
        if (packages_delivered !== undefined) updateData.packages_delivered = packages_delivered;
        if (delivery_notes !== undefined) updateData.delivery_notes = delivery_notes;

        const { data, error } = await supabase
            .from('sales')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({
            success: true,
            message: 'Estado de entrega actualizado',
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// Actualizar estado de pago
app.patch('/api/sales/:id/payment', async (req, res) => {
    try {
        const { id } = req.params;
        const { payment_status, payment_method } = req.body;

        if (!payment_status) {
            return res.status(400).json({ error: 'payment_status es requerido' });
        }

        const updateData = { payment_status };
        if (payment_method) updateData.payment_method = payment_method;

        const { data, error } = await supabase
            .from('sales')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({
            success: true,
            message: 'Estado de pago actualizado',
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// ============================================================================
// GASTOS / EXPENSES
// ============================================================================

// Obtener categorías de gastos
app.get('/api/expenses/categories', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('expense_categories')
            .select('*')
            .eq('active', true)
            .order('sort_order');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener subcategorías de una categoría
app.get('/api/expenses/categories/:categoryId/subcategories', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('expense_subcategories')
            .select('*')
            .eq('category_id', req.params.categoryId)
            .eq('active', true)
            .order('subcategory_name');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Obtener todos los gastos
app.get('/api/expenses', async (req, res) => {
    try {
        const { event_id, status } = req.query;

        let query = supabase
            .from('expenses')
            .select(`
                *,
                events (event_name, city),
                expense_categories (category_name, icon),
                expense_subcategories (subcategory_name)
            `)
            .order('created_at', { ascending: false });

        if (event_id) query = query.eq('event_id', event_id);
        if (status) query = query.eq('status', status);

        const { data, error } = await query;
        if (error) throw error;

        // Adjuntar URL pública del comprobante
        const withUrls = (data || []).map((row) => ({
            ...row,
            receipt_url: getPublicUrl('expense-receipts', row.receipt_filename)
        }));

        res.json(withUrls);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Crear nuevo gasto
app.post('/api/expenses', upload.single('receipt'), async (req, res) => {
    try {
        const {
            event_id,
            category_id,
            subcategory_id,
            description,
            amount,
            currency,
            quantity,
            unit_price,
            vendor_name,
            vendor_id,
            invoice_number,
            status,
            requested_by,
            payment_method,
            expense_date,
            notes
        } = req.body;

        // Validaciones
        if (!category_id || !subcategory_id || !description || !amount) {
            return res.status(400).json({
                error: 'Campos requeridos: category_id, subcategory_id, description, amount'
            });
        }

        // Subir comprobante si existe
        let receiptFilename = null;
        if (req.file) {
            receiptFilename = await uploadFile('expense-receipts', req.file, 'expenses');
        }

        const { data, error } = await supabase
            .from('expenses')
            .insert([{
                event_id: event_id || null,
                category_id: parseInt(category_id),
                subcategory_id: parseInt(subcategory_id),
                description,
                amount: parseFloat(amount),
                currency: currency || 'BOB',
                quantity: quantity ? parseInt(quantity) : 1,
                unit_price: unit_price ? parseFloat(unit_price) : null,
                vendor_name: vendor_name || null,
                vendor_id: vendor_id || null,
                invoice_number: invoice_number || null,
                receipt_filename: receiptFilename,
                status: status || 'pendiente',
                requested_by: requested_by || null,
                payment_method: payment_method || null,
                expense_date: expense_date || new Date().toISOString().split('T')[0],
                notes: notes || null
            }])
            .select()
            .single();

        if (error) throw error;

        res.json({
            success: true,
            id: data.id,
            message: 'Gasto registrado exitosamente',
            data
        });
    } catch (error) {
        if (error instanceof multer.MulterError) {
            if (error.code === 'LIMIT_FILE_SIZE') {
                return res.status(413).json({ error: 'El archivo es demasiado grande. Máximo 4MB.' });
            }
            return res.status(400).json({ error: `Error de carga: ${error.message}` });
        }
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// Actualizar gasto
app.patch('/api/expenses/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = {};

        const allowedFields = [
            'event_id', 'category_id', 'subcategory_id', 'description', 'amount',
            'currency', 'quantity', 'unit_price', 'vendor_name', 'vendor_id',
            'invoice_number', 'status', 'requested_by', 'approved_by',
            'payment_date', 'payment_method', 'expense_date', 'notes'
        ];

        allowedFields.forEach(field => {
            if (req.body[field] !== undefined) {
                updateData[field] = req.body[field];
            }
        });

        // Si se aprueba, agregar fecha y usuario
        if (updateData.status === 'aprobado' && !updateData.approved_by) {
            updateData.approved_at = new Date().toISOString();
        }

        if (Object.keys(updateData).length === 0) {
            return res.status(400).json({ error: 'No hay datos para actualizar' });
        }

        const { data, error } = await supabase
            .from('expenses')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({
            success: true,
            message: 'Gasto actualizado exitosamente',
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }
});

// Obtener resumen de gastos por categoría
app.get('/api/expenses/summary', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_expenses_by_category')
            .select('*');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================================================
// REPORTES
// ============================================================================

// Resumen financiero por evento
app.get('/api/reports/events', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_event_financial_summary')
            .select('*');

        if (error) throw error;
        res.json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Ventas por evento
app.get('/api/reports/sales-by-event', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('v_sales_by_event')
            .select('*');

        if (error) throw error;
        res.json(data || []);
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
