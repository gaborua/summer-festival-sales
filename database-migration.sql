-- ============================================================================
-- MIGRACIÓN DE BASE DE DATOS - SISTEMA UNIFICADO
-- Sistema Integral de Gestión de Eventos - Summer Festival
-- ============================================================================
-- Fecha: Enero 2026
-- Descripción: Script completo para crear todas las tablas del sistema unificado
-- Instrucciones: Ejecutar en Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. TABLA: events (Central del Sistema)
-- ============================================================================
CREATE TABLE IF NOT EXISTS events (
  id SERIAL PRIMARY KEY,
  event_name VARCHAR(200) NOT NULL,
  event_slug VARCHAR(200) UNIQUE NOT NULL,
  event_date DATE NOT NULL,
  event_type VARCHAR(50),
  status VARCHAR(50) DEFAULT 'planificacion',
  total_capacity INTEGER,
  ticket_base_price DECIMAL(10,2),
  description TEXT,
  banner_image_url TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(200)
);

-- Índices para events
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_slug ON events(event_slug);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);

-- Comentarios
COMMENT ON TABLE events IS 'Tabla central de eventos - Cada registro representa un evento/festival';
COMMENT ON COLUMN events.status IS 'Estados: planificacion, activo, finalizado, cancelado';
COMMENT ON COLUMN events.event_type IS 'Tipo de evento: festival, concierto, party, etc.';

-- Datos iniciales
INSERT INTO events (event_name, event_slug, event_date, status, ticket_base_price, event_type) VALUES
  ('Año Nuevo 2026', 'ano-nuevo-2026', '2026-01-01', 'finalizado', 200.00, 'festival'),
  ('Carnaval Summer 2026', 'carnaval-2026', '2026-02-15', 'activo', 180.00, 'festival')
ON CONFLICT (event_slug) DO NOTHING;


-- ============================================================================
-- 2. MODIFICAR TABLA: sales (Ya existe - agregar columnas)
-- ============================================================================

-- Agregar event_id si no existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='sales' AND column_name='event_id') THEN
    ALTER TABLE sales ADD COLUMN event_id INTEGER REFERENCES events(id);
  END IF;
END $$;

-- Agregar otras columnas nuevas
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='sales' AND column_name='payment_method') THEN
    ALTER TABLE sales ADD COLUMN payment_method VARCHAR(50) DEFAULT 'transferencia';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='sales' AND column_name='notes') THEN
    ALTER TABLE sales ADD COLUMN notes TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='sales' AND column_name='confirmed') THEN
    ALTER TABLE sales ADD COLUMN confirmed BOOLEAN DEFAULT FALSE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='sales' AND column_name='confirmed_by') THEN
    ALTER TABLE sales ADD COLUMN confirmed_by VARCHAR(200);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='sales' AND column_name='confirmed_at') THEN
    ALTER TABLE sales ADD COLUMN confirmed_at TIMESTAMP;
  END IF;
END $$;

-- Migrar datos existentes a event_id (basado en event_name)
UPDATE sales
SET event_id = (SELECT id FROM events WHERE event_slug = 'ano-nuevo-2026')
WHERE event_name = 'Año Nuevo 2026' AND event_id IS NULL;

UPDATE sales
SET event_id = (SELECT id FROM events WHERE event_slug = 'carnaval-2026')
WHERE event_name = 'Carnaval Summer 2026' AND event_id IS NULL;

-- Crear índices adicionales
CREATE INDEX IF NOT EXISTS idx_sales_event_id ON sales(event_id);
CREATE INDEX IF NOT EXISTS idx_sales_confirmed ON sales(confirmed);
CREATE INDEX IF NOT EXISTS idx_sales_city_event ON sales(city, event_id);


-- ============================================================================
-- 3. TABLA: individual_sales (Nueva)
-- ============================================================================
CREATE TABLE IF NOT EXISTS individual_sales (
  id SERIAL PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id),

  -- Información del cliente
  customer_name VARCHAR(200) NOT NULL,
  customer_phone VARCHAR(50),
  customer_email VARCHAR(200),
  customer_id_number VARCHAR(50),

  -- Información de venta
  city VARCHAR(100) NOT NULL,
  ticket_quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,

  -- Vendedor/RRPP
  rrpp_name VARCHAR(200),
  rrpp_commission DECIMAL(10,2),

  -- Pago
  payment_method VARCHAR(50) NOT NULL,
  payment_status VARCHAR(50) DEFAULT 'pendiente',
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Entrega
  tickets_delivered BOOLEAN DEFAULT FALSE,
  delivery_date TIMESTAMP,
  delivery_notes TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Índices para individual_sales
CREATE INDEX IF NOT EXISTS idx_individual_sales_event ON individual_sales(event_id);
CREATE INDEX IF NOT EXISTS idx_individual_sales_city ON individual_sales(city);
CREATE INDEX IF NOT EXISTS idx_individual_sales_customer ON individual_sales(customer_phone);
CREATE INDEX IF NOT EXISTS idx_individual_sales_payment_status ON individual_sales(payment_status);
CREATE INDEX IF NOT EXISTS idx_individual_sales_rrpp ON individual_sales(rrpp_name);

-- Comentarios
COMMENT ON TABLE individual_sales IS 'Ventas directas a clientes finales';
COMMENT ON COLUMN individual_sales.payment_method IS 'Métodos: efectivo, transferencia, qr, tarjeta';
COMMENT ON COLUMN individual_sales.payment_status IS 'Estados: pendiente, pagado, parcial';


-- ============================================================================
-- 4. TABLA: expenses (Nueva)
-- ============================================================================
CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  event_id INTEGER REFERENCES events(id),

  -- Información del gasto
  description TEXT NOT NULL,
  category VARCHAR(100) NOT NULL,
  subcategory VARCHAR(100),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'BOB',

  -- Ubicación
  city VARCHAR(100),

  -- Proveedor/Beneficiario
  vendor_name VARCHAR(200),
  vendor_id VARCHAR(100),

  -- Documentación
  invoice_number VARCHAR(100),
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Aprobación
  status VARCHAR(50) DEFAULT 'pendiente',
  requested_by VARCHAR(200),
  approved_by VARCHAR(200),
  approved_at TIMESTAMP,
  payment_date DATE,

  -- Metadata
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Índices para expenses
CREATE INDEX IF NOT EXISTS idx_expenses_event ON expenses(event_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);
CREATE INDEX IF NOT EXISTS idx_expenses_status ON expenses(status);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_city ON expenses(city);

-- Comentarios
COMMENT ON TABLE expenses IS 'Registro de gastos y costos del evento';
COMMENT ON COLUMN expenses.category IS 'Categorías: Producción, Marketing, Personal, Logística, Alquiler, Seguridad, Catering, Tecnología, Legal, Transporte, Otros';
COMMENT ON COLUMN expenses.status IS 'Estados: pendiente, aprobado, rechazado, pagado';


-- ============================================================================
-- 5. TABLA: event_calculations (Nueva - Para Calculadora)
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_calculations (
  id SERIAL PRIMARY KEY,
  event_id INTEGER REFERENCES events(id),

  -- Información básica
  calculation_name VARCHAR(200) NOT NULL,
  city VARCHAR(100),
  venue_name VARCHAR(200),
  event_date DATE,

  -- Capacidad y precios
  total_capacity INTEGER NOT NULL,
  expected_attendance INTEGER,
  ticket_price_general DECIMAL(10,2),
  ticket_price_vip DECIMAL(10,2),
  ticket_price_early DECIMAL(10,2),

  -- Costos estimados
  venue_cost DECIMAL(10,2),
  production_cost DECIMAL(10,2),
  marketing_cost DECIMAL(10,2),
  staff_cost DECIMAL(10,2),
  other_costs DECIMAL(10,2),
  total_estimated_costs DECIMAL(10,2),

  -- Proyecciones
  projected_revenue DECIMAL(10,2),
  projected_profit DECIMAL(10,2),
  break_even_tickets INTEGER,
  profit_margin DECIMAL(5,2),

  -- Escenarios
  scenario_type VARCHAR(50),

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(200),
  notes TEXT
);

-- Índices para event_calculations
CREATE INDEX IF NOT EXISTS idx_calculations_event ON event_calculations(event_id);
CREATE INDEX IF NOT EXISTS idx_calculations_city ON event_calculations(city);

-- Comentarios
COMMENT ON TABLE event_calculations IS 'Cálculos y proyecciones financieras de eventos';
COMMENT ON COLUMN event_calculations.scenario_type IS 'Escenarios: pesimista, realista, optimista';


-- ============================================================================
-- 6. VISTAS PARA REPORTES
-- ============================================================================

-- Vista: Resumen financiero por evento
CREATE OR REPLACE VIEW v_event_financial_summary AS
SELECT
  e.id,
  e.event_name,
  e.event_slug,
  e.event_date,
  e.status,
  e.ticket_base_price,

  -- Ventas por equipos
  COUNT(DISTINCT s.id) AS team_sales_count,
  COALESCE(SUM(s.ticket_quantity), 0) AS team_tickets_sold,
  COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) AS team_revenue,

  -- Ventas individuales
  COUNT(DISTINCT i.id) AS individual_sales_count,
  COALESCE(SUM(i.ticket_quantity), 0) AS individual_tickets_sold,
  COALESCE(SUM(i.total_amount), 0) AS individual_revenue,

  -- Totales
  (COALESCE(SUM(s.ticket_quantity), 0) + COALESCE(SUM(i.ticket_quantity), 0)) AS total_tickets_sold,
  (COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) + COALESCE(SUM(i.total_amount), 0)) AS total_revenue,

  -- Gastos
  COALESCE(SUM(ex.amount), 0) AS total_expenses,

  -- Balance
  (COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) +
   COALESCE(SUM(i.total_amount), 0) -
   COALESCE(SUM(ex.amount), 0)) AS net_profit,

  -- Margen
  CASE
    WHEN (COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) + COALESCE(SUM(i.total_amount), 0)) > 0
    THEN ROUND(
      ((COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) + COALESCE(SUM(i.total_amount), 0) - COALESCE(SUM(ex.amount), 0))
      / (COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) + COALESCE(SUM(i.total_amount), 0)) * 100)::numeric, 2
    )
    ELSE 0
  END AS profit_margin_percent

FROM events e
LEFT JOIN sales s ON s.event_id = e.id
LEFT JOIN individual_sales i ON i.event_id = e.id
LEFT JOIN expenses ex ON ex.event_id = e.id
GROUP BY e.id, e.event_name, e.event_slug, e.event_date, e.status, e.ticket_base_price
ORDER BY e.event_date DESC;

COMMENT ON VIEW v_event_financial_summary IS 'Resumen financiero completo por evento';


-- Vista: Resumen por ciudad
CREATE OR REPLACE VIEW v_city_summary AS
SELECT
  city,
  COUNT(DISTINCT event_id) AS total_events,
  SUM(ticket_quantity) AS total_tickets,
  COUNT(*) AS total_sales
FROM sales
WHERE city IS NOT NULL
GROUP BY city
ORDER BY total_tickets DESC;

COMMENT ON VIEW v_city_summary IS 'Resumen de ventas por ciudad';


-- Vista: Top RRPPs
CREATE OR REPLACE VIEW v_top_rrpps AS
SELECT
  rrpp_name,
  COUNT(*) AS total_sales,
  SUM(ticket_quantity) AS total_tickets,
  COUNT(DISTINCT event_id) AS events_worked,
  MAX(created_at) AS last_sale_date
FROM sales
WHERE rrpp_name IS NOT NULL AND rrpp_name != ''
GROUP BY rrpp_name
ORDER BY total_tickets DESC;

COMMENT ON VIEW v_top_rrpps IS 'Ranking de RRPPs por ventas';


-- Vista: Gastos por categoría
CREATE OR REPLACE VIEW v_expenses_by_category AS
SELECT
  category,
  COUNT(*) AS expense_count,
  SUM(amount) AS total_amount,
  AVG(amount) AS avg_amount,
  MAX(amount) AS max_amount,
  MIN(amount) AS min_amount
FROM expenses
WHERE status != 'rechazado'
GROUP BY category
ORDER BY total_amount DESC;

COMMENT ON VIEW v_expenses_by_category IS 'Resumen de gastos por categoría';


-- Vista: Estadísticas generales del sistema
CREATE OR REPLACE VIEW v_system_stats AS
SELECT
  (SELECT COUNT(*) FROM events WHERE status = 'activo') AS active_events,
  (SELECT COUNT(*) FROM events WHERE status = 'finalizado') AS completed_events,
  (SELECT COUNT(*) FROM sales) AS total_team_sales,
  (SELECT COUNT(*) FROM individual_sales) AS total_individual_sales,
  (SELECT COUNT(*) FROM expenses WHERE status = 'pendiente') AS pending_expenses,
  (SELECT COALESCE(SUM(ticket_quantity * e.ticket_base_price), 0)
   FROM sales s
   JOIN events e ON s.event_id = e.id) AS total_team_revenue,
  (SELECT COALESCE(SUM(total_amount), 0) FROM individual_sales) AS total_individual_revenue,
  (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE status IN ('aprobado', 'pagado')) AS total_expenses;

COMMENT ON VIEW v_system_stats IS 'Estadísticas generales del sistema';


-- ============================================================================
-- 7. FUNCIONES ÚTILES
-- ============================================================================

-- Función para calcular el revenue total de un evento
CREATE OR REPLACE FUNCTION calculate_event_revenue(p_event_id INTEGER)
RETURNS DECIMAL(10,2) AS $$
DECLARE
  v_revenue DECIMAL(10,2);
BEGIN
  SELECT
    COALESCE(SUM(s.ticket_quantity * e.ticket_base_price), 0) +
    COALESCE(SUM(i.total_amount), 0)
  INTO v_revenue
  FROM events e
  LEFT JOIN sales s ON s.event_id = e.id
  LEFT JOIN individual_sales i ON i.event_id = e.id
  WHERE e.id = p_event_id
  GROUP BY e.id;

  RETURN COALESCE(v_revenue, 0);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_event_revenue IS 'Calcula el revenue total de un evento (ventas equipos + individuales)';


-- Función para obtener el balance de un evento
CREATE OR REPLACE FUNCTION calculate_event_balance(p_event_id INTEGER)
RETURNS TABLE(
  revenue DECIMAL(10,2),
  expenses DECIMAL(10,2),
  balance DECIMAL(10,2),
  margin DECIMAL(5,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.total_revenue,
    v.total_expenses,
    v.net_profit,
    v.profit_margin_percent
  FROM v_event_financial_summary v
  WHERE v.id = p_event_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_event_balance IS 'Obtiene el balance financiero completo de un evento';


-- ============================================================================
-- 8. TRIGGERS (Opcional - para actualizar updated_at automáticamente)
-- ============================================================================

-- Función genérica para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_individual_sales_updated_at BEFORE UPDATE ON individual_sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_calculations_updated_at BEFORE UPDATE ON event_calculations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- 9. PERMISOS (Row Level Security - RLS)
-- ============================================================================
-- Nota: Ajusta según tus necesidades de seguridad

-- Habilitar RLS en tablas sensibles (opcional)
-- ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE individual_sales ENABLE ROW LEVEL SECURITY;

-- Crear políticas si es necesario
-- CREATE POLICY "Permitir lectura pública" ON events FOR SELECT USING (true);


-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

-- Verificar que todo se creó correctamente
DO $$
DECLARE
  v_events_count INTEGER;
  v_sales_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_events_count FROM events;
  SELECT COUNT(*) INTO v_sales_count FROM sales;

  RAISE NOTICE '✅ Migración completada exitosamente';
  RAISE NOTICE '📊 Total eventos: %', v_events_count;
  RAISE NOTICE '💰 Total ventas: %', v_sales_count;
  RAISE NOTICE '✨ Sistema unificado listo para usar';
END $$;
