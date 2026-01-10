-- ============================================================================
-- MIGRACIÓN DE BASE DE DATOS V2.0 - SISTEMA UNIFICADO
-- Sistema Integral de Gestión de Eventos - Summer Festival
-- ============================================================================
-- Fecha: Enero 2026
-- Descripción: Script completo actualizado con arquitectura v2.0
-- Cambios principales:
--   - Módulo de ventas unificado (paquetes + individuales)
--   - Sistema de categorización detallada de gastos
-- Instrucciones: Ejecutar en Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. TABLA: events (Eventos Individuales)
-- ============================================================================
CREATE TABLE IF NOT EXISTS events (
  id SERIAL PRIMARY KEY,
  event_name VARCHAR(200) NOT NULL,
  event_slug VARCHAR(200) UNIQUE NOT NULL,
  event_date DATE NOT NULL,
  event_type VARCHAR(50),
  city VARCHAR(100),
  venue_name VARCHAR(200),
  status VARCHAR(50) DEFAULT 'planificacion',
  capacity INTEGER,
  ticket_price DECIMAL(10,2),

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_events_city ON events(city);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_slug ON events(event_slug);

COMMENT ON TABLE events IS 'Eventos individuales - Cada registro es un evento específico en una ciudad';
COMMENT ON COLUMN events.status IS 'Estados: planificacion, activo, finalizado, cancelado';

-- Datos de ejemplo
INSERT INTO events (event_name, event_slug, event_date, city, ticket_price, status) VALUES
  -- Año Nuevo 2026
  ('Año Nuevo 2026 - Tarija', 'ano-nuevo-2026-tarija', '2025-12-31', 'Tarija', 200.00, 'activo'),
  ('Año Nuevo 2026 - Santa Cruz', 'ano-nuevo-2026-santa-cruz', '2025-12-31', 'Santa Cruz', 200.00, 'activo'),
  ('Año Nuevo 2026 - Cochabamba', 'ano-nuevo-2026-cochabamba', '2025-12-31', 'Cochabamba', 200.00, 'activo'),
  ('Año Nuevo 2026 - La Paz', 'ano-nuevo-2026-la-paz', '2025-12-31', 'La Paz', 200.00, 'activo'),
  ('Año Nuevo 2026 - Sucre', 'ano-nuevo-2026-sucre', '2025-12-31', 'Sucre', 200.00, 'activo'),

  -- Carnaval 2026
  ('Carnaval 2026 - Tarija', 'carnaval-2026-tarija', '2026-02-15', 'Tarija', 180.00, 'activo'),
  ('Carnaval 2026 - Santa Cruz', 'carnaval-2026-santa-cruz', '2026-02-15', 'Santa Cruz', 180.00, 'activo'),
  ('Carnaval 2026 - Cochabamba', 'carnaval-2026-cochabamba', '2026-02-15', 'Cochabamba', 180.00, 'activo')
ON CONFLICT (event_slug) DO NOTHING;


-- ============================================================================
-- 2. TABLA: packages (Paquetes de Eventos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS packages (
  id SERIAL PRIMARY KEY,
  package_name VARCHAR(200) NOT NULL,
  package_slug VARCHAR(200) UNIQUE NOT NULL,
  description TEXT,
  package_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2),
  active BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE packages IS 'Paquetes que incluyen múltiples eventos';
COMMENT ON COLUMN packages.discount_percent IS 'Porcentaje de descuento vs compra individual';

-- Paquetes de ejemplo
INSERT INTO packages (package_name, package_slug, package_price, discount_percent, active) VALUES
  ('Paquete Año Nuevo 2026', 'paquete-ano-nuevo-2026', 850.00, 15, true),
  ('Paquete Carnaval 2026', 'paquete-carnaval-2026', 450.00, 15, true)
ON CONFLICT (package_slug) DO NOTHING;


-- ============================================================================
-- 3. TABLA: package_events (Relación Paquete-Eventos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS package_events (
  package_id INTEGER REFERENCES packages(id) ON DELETE CASCADE,
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
  PRIMARY KEY (package_id, event_id)
);

CREATE INDEX IF NOT EXISTS idx_package_events_package ON package_events(package_id);
CREATE INDEX IF NOT EXISTS idx_package_events_event ON package_events(event_id);

COMMENT ON TABLE package_events IS 'Eventos incluidos en cada paquete';

-- Relaciones: Qué eventos incluye cada paquete
INSERT INTO package_events (package_id, event_id)
SELECT
  p.id,
  e.id
FROM packages p
CROSS JOIN events e
WHERE
  (p.package_slug = 'paquete-ano-nuevo-2026' AND e.event_slug LIKE 'ano-nuevo-2026-%')
  OR
  (p.package_slug = 'paquete-carnaval-2026' AND e.event_slug LIKE 'carnaval-2026-%')
ON CONFLICT DO NOTHING;


-- ============================================================================
-- 4. TABLA: sales (Rediseñada - Ventas Unificadas)
-- ============================================================================

-- ADVERTENCIA: Esto eliminará la tabla sales actual
-- Asegúrate de hacer backup antes si tienes datos importantes
-- DROP TABLE IF EXISTS sales CASCADE;

-- Si la tabla sales ya existe, renombrarla como backup
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sales') THEN
    -- Renombrar tabla existente
    ALTER TABLE sales RENAME TO sales_backup_before_v2;
    RAISE NOTICE 'Tabla sales renombrada a sales_backup_before_v2';
  END IF;
END $$;

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,

  -- Tipo de venta
  sale_type VARCHAR(50) NOT NULL,             -- 'package' o 'individual'
  package_id INTEGER REFERENCES packages(id), -- Solo si sale_type = 'package'

  -- Información del cliente/comprador
  customer_name VARCHAR(200) NOT NULL,
  customer_phone VARCHAR(50),
  customer_email VARCHAR(200),
  customer_id_number VARCHAR(50),

  -- Información de venta
  ticket_quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,

  -- Vendedor/RRPP
  team_leader VARCHAR(200),
  rrpp_name VARCHAR(200),
  rrpp_commission DECIMAL(10,2),

  -- Pago
  payment_method VARCHAR(50) NOT NULL DEFAULT 'transferencia',
  payment_status VARCHAR(50) DEFAULT 'pendiente',
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Entrega
  tickets_delivered BOOLEAN DEFAULT FALSE,
  packages_delivered BOOLEAN DEFAULT FALSE,
  delivery_date TIMESTAMP,
  delivery_notes TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT,

  -- Constraint: si es paquete, debe tener package_id
  CONSTRAINT check_package_type CHECK (
    (sale_type = 'package' AND package_id IS NOT NULL)
    OR
    (sale_type = 'individual' AND package_id IS NULL)
  )
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_sales_sale_type ON sales(sale_type);
CREATE INDEX IF NOT EXISTS idx_sales_package_id ON sales(package_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_phone ON sales(customer_phone);
CREATE INDEX IF NOT EXISTS idx_sales_rrpp ON sales(rrpp_name);
CREATE INDEX IF NOT EXISTS idx_sales_payment_status ON sales(payment_status);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at DESC);

COMMENT ON TABLE sales IS 'Tabla unificada de ventas (paquetes e individuales)';
COMMENT ON COLUMN sales.sale_type IS 'Valores: package (paquete) o individual (eventos específicos)';
COMMENT ON COLUMN sales.payment_status IS 'Estados: pendiente, pagado, parcial, rechazado';


-- ============================================================================
-- 5. TABLA: sale_events (Eventos en Ventas Individuales)
-- ============================================================================
CREATE TABLE IF NOT EXISTS sale_events (
  sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
  PRIMARY KEY (sale_id, event_id)
);

CREATE INDEX IF NOT EXISTS idx_sale_events_sale ON sale_events(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_events_event ON sale_events(event_id);

COMMENT ON TABLE sale_events IS 'Eventos específicos seleccionados en ventas individuales';


-- ============================================================================
-- 6. TABLA: expense_categories (Categorías de Gastos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS expense_categories (
  id SERIAL PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  category_slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon VARCHAR(50),
  active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0
);

-- Categorías principales
INSERT INTO expense_categories (category_name, category_slug, icon, sort_order) VALUES
  ('Producción', 'produccion', '🎬', 1),
  ('Marketing y Publicidad', 'marketing', '📢', 2),
  ('Personal y Staff', 'personal', '👥', 3),
  ('Logística', 'logistica', '🚚', 4),
  ('Alquiler de Espacios', 'alquiler', '🏢', 5),
  ('Seguridad', 'seguridad', '🛡️', 6),
  ('Catering y Bebidas', 'catering', '🍽️', 7),
  ('Tecnología y Equipos', 'tecnologia', '💻', 8),
  ('Legal y Permisos', 'legal', '⚖️', 9),
  ('Transporte', 'transporte', '🚗', 10),
  ('Decoración', 'decoracion', '🎨', 11),
  ('Limpieza', 'limpieza', '🧹', 12),
  ('Otros', 'otros', '📦', 99)
ON CONFLICT (category_slug) DO NOTHING;

COMMENT ON TABLE expense_categories IS 'Categorías principales de gastos';


-- ============================================================================
-- 7. TABLA: expense_subcategories (Subcategorías Detalladas)
-- ============================================================================
CREATE TABLE IF NOT EXISTS expense_subcategories (
  id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES expense_categories(id) ON DELETE CASCADE,
  subcategory_name VARCHAR(100) NOT NULL,
  subcategory_slug VARCHAR(100) NOT NULL,
  description TEXT,
  active BOOLEAN DEFAULT TRUE,

  UNIQUE(category_id, subcategory_slug)
);

-- Subcategorías por categoría
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug)
SELECT
  ec.id,
  sc.name,
  sc.slug
FROM expense_categories ec
CROSS JOIN (VALUES
  -- PRODUCCIÓN (id=1)
  (1, 'Sistema de Sonido', 'sonido'),
  (1, 'Iluminación', 'iluminacion'),
  (1, 'DJ/Artistas', 'dj-artistas'),
  (1, 'Escenario', 'escenario'),
  (1, 'Efectos Especiales', 'efectos'),

  -- MARKETING (id=2)
  (2, 'Publicidad en Redes Sociales', 'redes-sociales'),
  (2, 'Flyers y Material Impreso', 'material-impreso'),
  (2, 'Publicidad en Radio', 'radio'),
  (2, 'Banners y Gigantografías', 'banners'),
  (2, 'Influencers/Promotores', 'influencers'),

  -- PERSONAL (id=3)
  (3, 'Coordinadores', 'coordinadores'),
  (3, 'Personal de Barra', 'personal-barra'),
  (3, 'Meseros', 'meseros'),
  (3, 'Cajeros', 'cajeros'),
  (3, 'Fotógrafos/Videógrafos', 'foto-video'),

  -- LOGÍSTICA (id=4)
  (4, 'Transporte de Equipos', 'transporte-equipos'),
  (4, 'Almacenamiento', 'almacenamiento'),
  (4, 'Mobiliario (Mesas/Sillas)', 'mobiliario'),

  -- ALQUILER (id=5)
  (5, 'Alquiler de Local/Venue', 'local'),
  (5, 'Alquiler de Carpas', 'carpas'),
  (5, 'Generadores Eléctricos', 'generadores'),

  -- SEGURIDAD (id=6)
  (6, 'Personal de Seguridad', 'personal-seguridad'),
  (6, 'Vallas y Control de Acceso', 'vallas'),

  -- CATERING (id=7)
  (7, 'Bebidas Alcohólicas', 'bebidas-alcoholicas'),
  (7, 'Bebidas sin Alcohol', 'bebidas-sin-alcohol'),
  (7, 'Hielo', 'hielo'),
  (7, 'Comida/Snacks', 'comida'),
  (7, 'Vasos/Descartables', 'descartables'),

  -- TECNOLOGÍA (id=8)
  (8, 'Sistema de Ticketing', 'ticketing'),
  (8, 'Internet/WiFi', 'internet'),
  (8, 'Sistemas POS', 'pos'),

  -- LEGAL (id=9)
  (9, 'Permisos Municipales', 'permisos'),
  (9, 'Seguros', 'seguros'),
  (9, 'Honorarios Legales', 'honorarios'),

  -- TRANSPORTE (id=10)
  (10, 'Transporte de Staff', 'transporte-staff'),
  (10, 'Combustible', 'combustible'),
  (10, 'Taxis/Uber', 'taxis'),

  -- DECORACIÓN (id=11)
  (11, 'Decoración Temática', 'decoracion-tematica'),
  (11, 'Globos y Ambientación', 'globos'),
  (11, 'Flores/Plantas', 'flores'),

  -- LIMPIEZA (id=12)
  (12, 'Personal de Limpieza', 'personal-limpieza'),
  (12, 'Materiales de Limpieza', 'materiales'),
  (12, 'Baños Portátiles', 'banos'),

  -- OTROS (id=13)
  (13, 'Varios', 'varios'),
  (13, 'No Categorizado', 'no-categorizado')

) AS sc(cat_id, name, slug)
WHERE ec.id = sc.cat_id
ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_expense_subcategories_category ON expense_subcategories(category_id);

COMMENT ON TABLE expense_subcategories IS 'Subcategorías detalladas de gastos para mejor tracking';


-- ============================================================================
-- 8. TABLA: expenses (Rediseñada con Categorización Obligatoria)
-- ============================================================================

-- Si existe, renombrar como backup
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'expenses') THEN
    ALTER TABLE expenses RENAME TO expenses_backup_before_v2;
    RAISE NOTICE 'Tabla expenses renombrada a expenses_backup_before_v2';
  END IF;
END $$;

CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,

  -- Relación con eventos (opcional - NULL = gasto general)
  event_id INTEGER REFERENCES events(id),

  -- Categorización OBLIGATORIA
  category_id INTEGER NOT NULL REFERENCES expense_categories(id),
  subcategory_id INTEGER NOT NULL REFERENCES expense_subcategories(id),

  -- Información del gasto
  description TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'BOB',
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10,2),

  -- Proveedor
  vendor_name VARCHAR(200),
  vendor_id VARCHAR(100),

  -- Documentación
  invoice_number VARCHAR(100),
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Aprobación y pago
  status VARCHAR(50) DEFAULT 'pendiente',
  requested_by VARCHAR(200),
  approved_by VARCHAR(200),
  approved_at TIMESTAMP,
  payment_date DATE,
  payment_method VARCHAR(50),

  -- Metadata
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT,

  -- Constraint: subcategory debe pertenecer a la categoría
  CONSTRAINT check_subcategory_matches_category CHECK (
    subcategory_id IN (
      SELECT id FROM expense_subcategories WHERE category_id = expenses.category_id
    )
  )
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_expenses_event ON expenses(event_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_subcategory ON expenses(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_expenses_status ON expenses(status);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at DESC);

COMMENT ON TABLE expenses IS 'Gastos con categorización detallada obligatoria';
COMMENT ON COLUMN expenses.status IS 'Estados: pendiente, aprobado, rechazado, pagado';
COMMENT ON COLUMN expenses.quantity IS 'Cantidad de unidades (ej: 10 cajas)';
COMMENT ON COLUMN expenses.unit_price IS 'Precio por unidad (ej: Bs. 50 por caja)';


-- ============================================================================
-- 9. VISTAS PARA REPORTES
-- ============================================================================

-- Vista: Resumen de ventas por tipo
CREATE OR REPLACE VIEW v_sales_summary AS
SELECT
  sale_type,
  COUNT(*) AS total_sales,
  SUM(ticket_quantity) AS total_tickets,
  SUM(total_amount) AS total_revenue,
  AVG(total_amount) AS avg_sale_amount,
  SUM(CASE WHEN payment_status = 'pagado' THEN total_amount ELSE 0 END) AS paid_revenue,
  SUM(CASE WHEN payment_status = 'pendiente' THEN total_amount ELSE 0 END) AS pending_revenue
FROM sales
WHERE payment_status != 'rechazado'
GROUP BY sale_type;

COMMENT ON VIEW v_sales_summary IS 'Resumen de ventas agrupado por tipo (package/individual)';


-- Vista: Detalles de ventas de paquetes
CREATE OR REPLACE VIEW v_package_sales_detail AS
SELECT
  s.id AS sale_id,
  s.customer_name,
  s.customer_phone,
  s.customer_email,
  p.package_name,
  s.ticket_quantity,
  s.unit_price,
  s.total_amount,
  s.payment_status,
  s.payment_method,
  s.tickets_delivered,
  s.packages_delivered,
  s.rrpp_name,
  s.team_leader,
  s.created_at,

  -- Eventos incluidos en el paquete
  (SELECT string_agg(e.event_name, ', ' ORDER BY e.event_date)
   FROM package_events pe
   JOIN events e ON pe.event_id = e.id
   WHERE pe.package_id = s.package_id) AS included_events,

  -- Cantidad de eventos en el paquete
  (SELECT COUNT(*)
   FROM package_events pe
   WHERE pe.package_id = s.package_id) AS events_count

FROM sales s
JOIN packages p ON s.package_id = p.id
WHERE s.sale_type = 'package'
ORDER BY s.created_at DESC;

COMMENT ON VIEW v_package_sales_detail IS 'Detalle completo de ventas de paquetes';


-- Vista: Detalles de ventas individuales
CREATE OR REPLACE VIEW v_individual_sales_detail AS
SELECT
  s.id AS sale_id,
  s.customer_name,
  s.customer_phone,
  s.customer_email,
  s.ticket_quantity,
  s.unit_price,
  s.total_amount,
  s.payment_status,
  s.payment_method,
  s.tickets_delivered,
  s.rrpp_name,
  s.team_leader,
  s.created_at,

  -- Eventos seleccionados
  (SELECT string_agg(e.event_name, ', ' ORDER BY e.event_date)
   FROM sale_events se
   JOIN events e ON se.event_id = e.id
   WHERE se.sale_id = s.id) AS selected_events,

  -- Cantidad de eventos
  (SELECT COUNT(*)
   FROM sale_events se
   WHERE se.sale_id = s.id) AS events_count

FROM sales s
WHERE s.sale_type = 'individual'
ORDER BY s.created_at DESC;

COMMENT ON VIEW v_individual_sales_detail IS 'Detalle completo de ventas individuales';


-- Vista: Gastos por categoría y subcategoría
CREATE OR REPLACE VIEW v_expenses_by_category AS
SELECT
  ec.id AS category_id,
  ec.category_name,
  ec.icon AS category_icon,
  esc.id AS subcategory_id,
  esc.subcategory_name,

  -- Agregaciones
  COUNT(e.id) AS expense_count,
  SUM(e.amount) AS total_amount,
  AVG(e.amount) AS avg_amount,
  MIN(e.amount) AS min_amount,
  MAX(e.amount) AS max_amount,

  -- Por estado
  SUM(CASE WHEN e.status = 'pagado' THEN e.amount ELSE 0 END) AS paid_amount,
  SUM(CASE WHEN e.status = 'aprobado' THEN e.amount ELSE 0 END) AS approved_amount,
  SUM(CASE WHEN e.status = 'pendiente' THEN e.amount ELSE 0 END) AS pending_amount

FROM expense_categories ec
JOIN expense_subcategories esc ON ec.id = esc.category_id
LEFT JOIN expenses e ON e.subcategory_id = esc.id AND e.status != 'rechazado'

GROUP BY ec.id, ec.category_name, ec.icon, esc.id, esc.subcategory_name
ORDER BY ec.sort_order, total_amount DESC NULLS LAST;

COMMENT ON VIEW v_expenses_by_category IS 'Resumen de gastos por categoría y subcategoría';


-- Vista: Resumen financiero por evento
CREATE OR REPLACE VIEW v_event_financial_summary AS
SELECT
  e.id AS event_id,
  e.event_name,
  e.city,
  e.event_date,
  e.status,
  e.ticket_price,

  -- Ingresos por paquetes (proporcional)
  COALESCE(
    (SELECT SUM(s.total_amount / (SELECT COUNT(*) FROM package_events WHERE package_id = s.package_id))
     FROM sales s
     JOIN package_events pe ON s.package_id = pe.package_id
     WHERE pe.event_id = e.id AND s.sale_type = 'package' AND s.payment_status = 'pagado'),
    0
  ) AS package_revenue,

  -- Cantidad de paquetes vendidos (proporcional)
  COALESCE(
    (SELECT SUM(s.ticket_quantity::decimal / (SELECT COUNT(*) FROM package_events WHERE package_id = s.package_id))
     FROM sales s
     JOIN package_events pe ON s.package_id = pe.package_id
     WHERE pe.event_id = e.id AND s.sale_type = 'package' AND s.payment_status = 'pagado'),
    0
  ) AS package_tickets,

  -- Ingresos individuales
  COALESCE(
    (SELECT SUM(s.total_amount / (SELECT COUNT(*) FROM sale_events WHERE sale_id = s.id))
     FROM sales s
     JOIN sale_events se ON s.id = se.sale_id
     WHERE se.event_id = e.id AND s.sale_type = 'individual' AND s.payment_status = 'pagado'),
    0
  ) AS individual_revenue,

  -- Cantidad de tickets individuales
  COALESCE(
    (SELECT SUM(s.ticket_quantity::decimal / (SELECT COUNT(*) FROM sale_events WHERE sale_id = s.id))
     FROM sales s
     JOIN sale_events se ON s.id = se.sale_id
     WHERE se.event_id = e.id AND s.sale_type = 'individual' AND s.payment_status = 'pagado'),
    0
  ) AS individual_tickets,

  -- Gastos del evento
  COALESCE(
    (SELECT SUM(amount) FROM expenses WHERE event_id = e.id AND status IN ('aprobado', 'pagado')),
    0
  ) AS total_expenses,

  -- Totales
  COALESCE(
    (SELECT SUM(s.total_amount / (SELECT COUNT(*) FROM package_events WHERE package_id = s.package_id))
     FROM sales s JOIN package_events pe ON s.package_id = pe.package_id
     WHERE pe.event_id = e.id AND s.sale_type = 'package' AND s.payment_status = 'pagado'),
    0
  ) +
  COALESCE(
    (SELECT SUM(s.total_amount / (SELECT COUNT(*) FROM sale_events WHERE sale_id = s.id))
     FROM sales s JOIN sale_events se ON s.id = se.sale_id
     WHERE se.event_id = e.id AND s.sale_type = 'individual' AND s.payment_status = 'pagado'),
    0
  ) AS total_revenue,

  -- Balance neto
  (COALESCE(
    (SELECT SUM(s.total_amount / (SELECT COUNT(*) FROM package_events WHERE package_id = s.package_id))
     FROM sales s JOIN package_events pe ON s.package_id = pe.package_id
     WHERE pe.event_id = e.id AND s.sale_type = 'package' AND s.payment_status = 'pagado'),
    0
  ) +
  COALESCE(
    (SELECT SUM(s.total_amount / (SELECT COUNT(*) FROM sale_events WHERE sale_id = s.id))
     FROM sales s JOIN sale_events se ON s.id = se.sale_id
     WHERE se.event_id = e.id AND s.sale_type = 'individual' AND s.payment_status = 'pagado'),
    0
  ) -
  COALESCE(
    (SELECT SUM(amount) FROM expenses WHERE event_id = e.id AND status IN ('aprobado', 'pagado')),
    0
  )) AS net_balance

FROM events e
ORDER BY e.event_date DESC;

COMMENT ON VIEW v_event_financial_summary IS 'Resumen financiero completo por evento';


-- Vista: Estadísticas generales del sistema
CREATE OR REPLACE VIEW v_system_stats AS
SELECT
  -- Eventos
  (SELECT COUNT(*) FROM events WHERE status = 'activo') AS active_events,
  (SELECT COUNT(*) FROM events WHERE status = 'finalizado') AS completed_events,
  (SELECT COUNT(*) FROM events) AS total_events,

  -- Ventas
  (SELECT COUNT(*) FROM sales WHERE sale_type = 'package') AS package_sales,
  (SELECT COUNT(*) FROM sales WHERE sale_type = 'individual') AS individual_sales,
  (SELECT COUNT(*) FROM sales) AS total_sales,

  -- Ingresos
  (SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE payment_status = 'pagado') AS total_revenue,
  (SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE sale_type = 'package' AND payment_status = 'pagado') AS package_revenue,
  (SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE sale_type = 'individual' AND payment_status = 'pagado') AS individual_revenue,

  -- Gastos
  (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE status IN ('aprobado', 'pagado')) AS total_expenses,
  (SELECT COUNT(*) FROM expenses WHERE status = 'pendiente') AS pending_expenses,

  -- Balance
  (SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE payment_status = 'pagado') -
  (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE status IN ('aprobado', 'pagado')) AS net_balance;

COMMENT ON VIEW v_system_stats IS 'Estadísticas generales del sistema';


-- ============================================================================
-- 10. TRIGGERS
-- ============================================================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a tablas
DROP TRIGGER IF EXISTS update_events_updated_at ON events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_packages_updated_at ON packages;
CREATE TRIGGER update_packages_updated_at BEFORE UPDATE ON packages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_expenses_updated_at ON expenses;
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- 11. FUNCIONES ÚTILES
-- ============================================================================

-- Función: Obtener eventos de un paquete
CREATE OR REPLACE FUNCTION get_package_events(p_package_id INTEGER)
RETURNS TABLE(
  event_id INTEGER,
  event_name VARCHAR,
  city VARCHAR,
  event_date DATE,
  ticket_price DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.event_name, e.city, e.event_date, e.ticket_price
  FROM package_events pe
  JOIN events e ON pe.event_id = e.id
  WHERE pe.package_id = p_package_id
  ORDER BY e.event_date;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_package_events IS 'Obtiene los eventos incluidos en un paquete';


-- Función: Obtener eventos de una venta individual
CREATE OR REPLACE FUNCTION get_sale_events(p_sale_id INTEGER)
RETURNS TABLE(
  event_id INTEGER,
  event_name VARCHAR,
  city VARCHAR,
  event_date DATE,
  ticket_price DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.event_name, e.city, e.event_date, e.ticket_price
  FROM sale_events se
  JOIN events e ON se.event_id = e.id
  WHERE se.sale_id = p_sale_id
  ORDER BY e.event_date;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_sale_events IS 'Obtiene los eventos seleccionados en una venta individual';


-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

-- Verificación final
DO $$
DECLARE
  v_events_count INTEGER;
  v_packages_count INTEGER;
  v_categories_count INTEGER;
  v_subcategories_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_events_count FROM events;
  SELECT COUNT(*) INTO v_packages_count FROM packages;
  SELECT COUNT(*) INTO v_categories_count FROM expense_categories;
  SELECT COUNT(*) INTO v_subcategories_count FROM expense_subcategories;

  RAISE NOTICE '';
  RAISE NOTICE '✅ ============================================';
  RAISE NOTICE '✅ Migración V2.0 completada exitosamente';
  RAISE NOTICE '✅ ============================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Resumen:';
  RAISE NOTICE '   - Eventos: %', v_events_count;
  RAISE NOTICE '   - Paquetes: %', v_packages_count;
  RAISE NOTICE '   - Categorías de gastos: %', v_categories_count;
  RAISE NOTICE '   - Subcategorías de gastos: %', v_subcategories_count;
  RAISE NOTICE '';
  RAISE NOTICE '✨ Sistema unificado listo para usar';
  RAISE NOTICE '';

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sales_backup_before_v2') THEN
    RAISE NOTICE '⚠️  NOTA: Tu tabla sales anterior fue renombrada a sales_backup_before_v2';
    RAISE NOTICE '   Revisa los datos y migra lo necesario a la nueva estructura';
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'expenses_backup_before_v2') THEN
    RAISE NOTICE '⚠️  NOTA: Tu tabla expenses anterior fue renombrada a expenses_backup_before_v2';
    RAISE NOTICE '   Revisa los datos y migra lo necesario a la nueva estructura';
  END IF;
END $$;
