# 🔄 Plan Actualizado - Sistema Unificado v2.0

**Fecha:** Enero 2026
**Cambios basados en feedback del cliente**

---

## 📝 Cambios Principales Solicitados

### ✅ Cambio 1: Módulo de Ventas Unificado

**ANTES:** 2 módulos separados (Ventas por Equipos + Ventas Individuales)

**AHORA:** 1 módulo de VENTAS con 2 áreas:

#### 🎁 ÁREA 1: VENTAS PAQUETES
- Venta de paquetes que incluyen múltiples eventos (3-5 eventos)
- Ejemplos de paquetes:
  - **Paquete Año Nuevo 2026**: Incluye 5 eventos (Tarija, Santa Cruz, Cochabamba, La Paz, Sucre)
  - **Paquete Carnaval 2026**: Incluye 3 eventos (Tarija, Santa Cruz, Cochabamba)
- El cliente compra el paquete completo
- Precio especial por paquete

#### 🎫 ÁREA 2: VENTAS INDIVIDUALES
- Venta de tickets para eventos específicos
- El cliente selecciona qué eventos quiere (1, 2, 3 o más)
- Ejemplos:
  - Cliente A: Solo Año Nuevo en Tarija
  - Cliente B: Año Nuevo en Tarija + Carnaval en Santa Cruz
  - Cliente C: 3 eventos específicos
- Se registra la lista exacta de eventos comprados
- Precio individual por evento

### ✅ Cambio 2: Categorización Detallada de Gastos

**IMPORTANTE:** Necesitamos saber exactamente cuánto costó cada ítem y área del evento.

Sistema de categorías y subcategorías más granular:
- Cada gasto debe tener categoría y subcategoría obligatoria
- Posibilidad de asignar gastos a eventos específicos
- Reportes detallados por categoría al final del evento

---

## 🗄️ Nueva Arquitectura de Base de Datos

### 1. Tabla: `events` (Sin cambios - Central)

```sql
CREATE TABLE events (
  id SERIAL PRIMARY KEY,
  event_name VARCHAR(200) NOT NULL,           -- "Año Nuevo 2026 - Tarija"
  event_slug VARCHAR(200) UNIQUE NOT NULL,
  event_date DATE NOT NULL,
  event_type VARCHAR(50),
  city VARCHAR(100),                          -- Ciudad del evento
  venue_name VARCHAR(200),                    -- Nombre del local/venue
  status VARCHAR(50) DEFAULT 'planificacion',
  capacity INTEGER,
  ticket_price DECIMAL(10,2),

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_events_city ON events(city);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_date ON events(event_date);

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
  ('Carnaval 2026 - Cochabamba', 'carnaval-2026-cochabamba', '2026-02-15', 'Cochabamba', 180.00, 'activo');
```

### 2. Tabla: `packages` (Nueva - Para Paquetes de Eventos)

```sql
CREATE TABLE packages (
  id SERIAL PRIMARY KEY,
  package_name VARCHAR(200) NOT NULL,         -- "Paquete Año Nuevo 2026"
  package_slug VARCHAR(200) UNIQUE NOT NULL,
  description TEXT,
  package_price DECIMAL(10,2) NOT NULL,       -- Precio especial del paquete
  discount_percent DECIMAL(5,2),              -- % de descuento vs comprar individual

  active BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Datos de ejemplo
INSERT INTO packages (package_name, package_slug, package_price, discount_percent, active) VALUES
  ('Paquete Año Nuevo 2026', 'paquete-ano-nuevo-2026', 850.00, 15, true),
  ('Paquete Carnaval 2026', 'paquete-carnaval-2026', 450.00, 15, true);
```

### 3. Tabla: `package_events` (Nueva - Relación Paquete-Eventos)

```sql
CREATE TABLE package_events (
  package_id INTEGER REFERENCES packages(id) ON DELETE CASCADE,
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
  PRIMARY KEY (package_id, event_id)
);

-- Relaciones de ejemplo
INSERT INTO package_events (package_id, event_id) VALUES
  -- Paquete Año Nuevo incluye 5 eventos
  (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),

  -- Paquete Carnaval incluye 3 eventos
  (2, 6), (2, 7), (2, 8);

CREATE INDEX idx_package_events_package ON package_events(package_id);
CREATE INDEX idx_package_events_event ON package_events(event_id);
```

### 4. Tabla: `sales` (Rediseñada - Ventas Unificadas)

```sql
-- ELIMINAR la tabla sales actual y recrear
DROP TABLE IF EXISTS sales CASCADE;

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,

  -- Tipo de venta
  sale_type VARCHAR(50) NOT NULL,             -- 'package' o 'individual'
  package_id INTEGER REFERENCES packages(id), -- Si es venta de paquete

  -- Información del cliente/comprador
  customer_name VARCHAR(200) NOT NULL,
  customer_phone VARCHAR(50),
  customer_email VARCHAR(200),
  customer_id_number VARCHAR(50),             -- CI/DNI

  -- Información de venta
  ticket_quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,

  -- Vendedor/RRPP
  team_leader VARCHAR(200),                   -- Para ventas por equipo
  rrpp_name VARCHAR(200),
  rrpp_commission DECIMAL(10,2),

  -- Pago
  payment_method VARCHAR(50) NOT NULL DEFAULT 'transferencia',
  payment_status VARCHAR(50) DEFAULT 'pendiente',
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Entrega
  tickets_delivered BOOLEAN DEFAULT FALSE,
  packages_delivered BOOLEAN DEFAULT FALSE,   -- Para paquetes físicos
  delivery_date TIMESTAMP,
  delivery_notes TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Índices
CREATE INDEX idx_sales_sale_type ON sales(sale_type);
CREATE INDEX idx_sales_package_id ON sales(package_id);
CREATE INDEX idx_sales_customer_phone ON sales(customer_phone);
CREATE INDEX idx_sales_rrpp ON sales(rrpp_name);
CREATE INDEX idx_sales_payment_status ON sales(payment_status);

COMMENT ON TABLE sales IS 'Tabla unificada de ventas (paquetes e individuales)';
COMMENT ON COLUMN sales.sale_type IS 'Tipo: package (paquete) o individual (eventos específicos)';
```

### 5. Tabla: `sale_events` (Nueva - Eventos en Ventas Individuales)

```sql
-- Para ventas individuales: qué eventos específicos compró el cliente
CREATE TABLE sale_events (
  sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
  PRIMARY KEY (sale_id, event_id)
);

CREATE INDEX idx_sale_events_sale ON sale_events(sale_id);
CREATE INDEX idx_sale_events_event ON sale_events(event_id);

COMMENT ON TABLE sale_events IS 'Eventos específicos incluidos en ventas individuales';
```

### 6. Tabla: `expense_categories` (Nueva - Categorías de Gastos)

```sql
CREATE TABLE expense_categories (
  id SERIAL PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  category_slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon VARCHAR(50),                           -- Emoji o icono
  active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0
);

-- Categorías principales
INSERT INTO expense_categories (category_name, category_slug, icon) VALUES
  ('Producción', 'produccion', '🎬'),
  ('Marketing y Publicidad', 'marketing', '📢'),
  ('Personal y Staff', 'personal', '👥'),
  ('Logística', 'logistica', '🚚'),
  ('Alquiler de Espacios', 'alquiler', '🏢'),
  ('Seguridad', 'seguridad', '🛡️'),
  ('Catering y Bebidas', 'catering', '🍽️'),
  ('Tecnología y Equipos', 'tecnologia', '💻'),
  ('Legal y Permisos', 'legal', '⚖️'),
  ('Transporte', 'transporte', '🚗'),
  ('Decoración', 'decoracion', '🎨'),
  ('Limpieza', 'limpieza', '🧹'),
  ('Otros', 'otros', '📦');
```

### 7. Tabla: `expense_subcategories` (Nueva - Subcategorías Detalladas)

```sql
CREATE TABLE expense_subcategories (
  id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES expense_categories(id) ON DELETE CASCADE,
  subcategory_name VARCHAR(100) NOT NULL,
  subcategory_slug VARCHAR(100) NOT NULL,
  description TEXT,
  active BOOLEAN DEFAULT TRUE,

  UNIQUE(category_id, subcategory_slug)
);

-- Subcategorías de PRODUCCIÓN
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (1, 'Sistema de Sonido', 'sonido'),
  (1, 'Iluminación', 'iluminacion'),
  (1, 'DJ/Artistas', 'dj-artistas'),
  (1, 'Escenario', 'escenario'),
  (1, 'Efectos Especiales', 'efectos');

-- Subcategorías de MARKETING
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (2, 'Publicidad en Redes Sociales', 'redes-sociales'),
  (2, 'Flyers y Material Impreso', 'material-impreso'),
  (2, 'Publicidad en Radio', 'radio'),
  (2, 'Banners y Gigantografías', 'banners'),
  (2, 'Influencers/Promotores', 'influencers');

-- Subcategorías de PERSONAL
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (3, 'Coordinadores', 'coordinadores'),
  (3, 'Personal de Barra', 'personal-barra'),
  (3, 'Meseros', 'meseros'),
  (3, 'Cajeros', 'cajeros'),
  (3, 'Fotógrafos/Videógrafos', 'foto-video');

-- Subcategorías de LOGÍSTICA
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (4, 'Transporte de Equipos', 'transporte-equipos'),
  (4, 'Almacenamiento', 'almacenamiento'),
  (4, 'Mobiliario (Mesas/Sillas)', 'mobiliario');

-- Subcategorías de ALQUILER
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (5, 'Alquiler de Local/Venue', 'local'),
  (5, 'Alquiler de Carpas', 'carpas'),
  (5, 'Generadores Eléctricos', 'generadores');

-- Subcategorías de SEGURIDAD
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (6, 'Personal de Seguridad', 'personal-seguridad'),
  (6, 'Vallas y Control de Acceso', 'vallas');

-- Subcategorías de CATERING
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (7, 'Bebidas Alcohólicas', 'bebidas-alcoholicas'),
  (7, 'Bebidas sin Alcohol', 'bebidas-sin-alcohol'),
  (7, 'Hielo', 'hielo'),
  (7, 'Comida/Snacks', 'comida'),
  (7, 'Vasos/Descartables', 'descartables');

-- Subcategorías de TECNOLOGÍA
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (8, 'Sistema de Ticketing', 'ticketing'),
  (8, 'Internet/WiFi', 'internet'),
  (8, 'Sistemas POS', 'pos');

-- Subcategorías de LEGAL
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (9, 'Permisos Municipales', 'permisos'),
  (9, 'Seguros', 'seguros'),
  (9, 'Honorarios Legales', 'honorarios');

-- Subcategorías de TRANSPORTE
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (10, 'Transporte de Staff', 'transporte-staff'),
  (10, 'Combustible', 'combustible'),
  (10, 'Taxis/Uber', 'taxis');

-- Subcategorías de DECORACIÓN
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (11, 'Decoración Temática', 'decoracion-tematica'),
  (11, 'Globos y Ambientación', 'globos'),
  (11, 'Flores/Plantas', 'flores');

-- Subcategorías de LIMPIEZA
INSERT INTO expense_subcategories (category_id, subcategory_name, subcategory_slug) VALUES
  (12, 'Personal de Limpieza', 'personal-limpieza'),
  (12, 'Materiales de Limpieza', 'materiales'),
  (12, 'Baños Portátiles', 'banos');

CREATE INDEX idx_expense_subcategories_category ON expense_subcategories(category_id);
```

### 8. Tabla: `expenses` (Rediseñada con Categorización)

```sql
CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,

  -- Relación con eventos (opcional - puede ser gasto general)
  event_id INTEGER REFERENCES events(id),

  -- Categorización OBLIGATORIA
  category_id INTEGER NOT NULL REFERENCES expense_categories(id),
  subcategory_id INTEGER NOT NULL REFERENCES expense_subcategories(id),

  -- Información del gasto
  description TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'BOB',
  quantity INTEGER DEFAULT 1,                 -- Cantidad de unidades
  unit_price DECIMAL(10,2),                   -- Precio por unidad

  -- Proveedor
  vendor_name VARCHAR(200),
  vendor_id VARCHAR(100),                     -- NIT/RUC

  -- Documentación
  invoice_number VARCHAR(100),
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Aprobación y pago
  status VARCHAR(50) DEFAULT 'pendiente',     -- pendiente, aprobado, rechazado, pagado
  requested_by VARCHAR(200),
  approved_by VARCHAR(200),
  approved_at TIMESTAMP,
  payment_date DATE,
  payment_method VARCHAR(50),                 -- efectivo, transferencia, tarjeta

  -- Metadata
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Índices
CREATE INDEX idx_expenses_event ON expenses(event_id);
CREATE INDEX idx_expenses_category ON expenses(category_id);
CREATE INDEX idx_expenses_subcategory ON expenses(subcategory_id);
CREATE INDEX idx_expenses_status ON expenses(status);
CREATE INDEX idx_expenses_date ON expenses(expense_date);

COMMENT ON TABLE expenses IS 'Gastos con categorización detallada obligatoria';
COMMENT ON COLUMN expenses.quantity IS 'Ejemplo: 10 cajas de bebidas';
COMMENT ON COLUMN expenses.unit_price IS 'Ejemplo: Bs. 50 por caja';
```

---

## 📊 Vistas Actualizadas para Reportes

### Vista: Resumen de Ventas por Tipo

```sql
CREATE OR REPLACE VIEW v_sales_summary AS
SELECT
  sale_type,
  COUNT(*) AS total_sales,
  SUM(ticket_quantity) AS total_tickets,
  SUM(total_amount) AS total_revenue,
  AVG(total_amount) AS avg_sale_amount
FROM sales
WHERE payment_status != 'rechazado'
GROUP BY sale_type;
```

### Vista: Ventas de Paquetes con Detalles

```sql
CREATE OR REPLACE VIEW v_package_sales_detail AS
SELECT
  s.id AS sale_id,
  s.customer_name,
  s.customer_phone,
  p.package_name,
  s.ticket_quantity,
  s.total_amount,
  s.payment_status,
  s.tickets_delivered,
  s.rrpp_name,
  s.created_at,

  -- Eventos incluidos en el paquete
  (SELECT string_agg(e.event_name, ', ')
   FROM package_events pe
   JOIN events e ON pe.event_id = e.id
   WHERE pe.package_id = s.package_id) AS included_events

FROM sales s
JOIN packages p ON s.package_id = p.id
WHERE s.sale_type = 'package';
```

### Vista: Ventas Individuales con Eventos

```sql
CREATE OR REPLACE VIEW v_individual_sales_detail AS
SELECT
  s.id AS sale_id,
  s.customer_name,
  s.customer_phone,
  s.ticket_quantity,
  s.total_amount,
  s.payment_status,
  s.tickets_delivered,
  s.rrpp_name,
  s.created_at,

  -- Eventos seleccionados
  (SELECT string_agg(e.event_name, ', ')
   FROM sale_events se
   JOIN events e ON se.event_id = e.id
   WHERE se.sale_id = s.id) AS selected_events,

  -- Cantidad de eventos
  (SELECT COUNT(*)
   FROM sale_events se
   WHERE se.sale_id = s.id) AS events_count

FROM sales s
WHERE s.sale_type = 'individual';
```

### Vista: Gastos por Categoría y Subcategoría

```sql
CREATE OR REPLACE VIEW v_expenses_by_category AS
SELECT
  ec.category_name,
  ec.icon AS category_icon,
  esc.subcategory_name,
  COUNT(e.id) AS expense_count,
  SUM(e.amount) AS total_amount,
  AVG(e.amount) AS avg_amount,

  -- Por evento (si aplica)
  ev.event_name,

  -- Estado de pago
  SUM(CASE WHEN e.status = 'pagado' THEN e.amount ELSE 0 END) AS paid_amount,
  SUM(CASE WHEN e.status = 'pendiente' THEN e.amount ELSE 0 END) AS pending_amount

FROM expenses e
JOIN expense_categories ec ON e.category_id = ec.id
JOIN expense_subcategories esc ON e.subcategory_id = esc.id
LEFT JOIN events ev ON e.event_id = ev.id

WHERE e.status != 'rechazado'

GROUP BY ec.category_name, ec.icon, esc.subcategory_name, ev.event_name
ORDER BY ec.category_name, total_amount DESC;
```

### Vista: Resumen Financiero por Evento

```sql
CREATE OR REPLACE VIEW v_event_financial_summary AS
SELECT
  e.id AS event_id,
  e.event_name,
  e.city,
  e.event_date,
  e.status,

  -- Ingresos por paquetes (proporcional)
  COALESCE(
    (SELECT SUM(s.total_amount /
      (SELECT COUNT(*) FROM package_events WHERE package_id = s.package_id))
     FROM sales s
     JOIN package_events pe ON s.package_id = pe.package_id
     WHERE pe.event_id = e.id AND s.sale_type = 'package'),
    0
  ) AS package_revenue,

  -- Ingresos individuales
  COALESCE(
    (SELECT SUM(s.total_amount /
      (SELECT COUNT(*) FROM sale_events WHERE sale_id = s.id))
     FROM sales s
     JOIN sale_events se ON s.id = se.sale_id
     WHERE se.event_id = e.id AND s.sale_type = 'individual'),
    0
  ) AS individual_revenue,

  -- Gastos
  COALESCE(
    (SELECT SUM(amount) FROM expenses WHERE event_id = e.id AND status IN ('aprobado', 'pagado')),
    0
  ) AS total_expenses,

  -- Balance
  COALESCE(
    (SELECT SUM(s.total_amount /
      (SELECT COUNT(*) FROM package_events WHERE package_id = s.package_id))
     FROM sales s
     JOIN package_events pe ON s.package_id = pe.package_id
     WHERE pe.event_id = e.id AND s.sale_type = 'package'),
    0
  ) +
  COALESCE(
    (SELECT SUM(s.total_amount /
      (SELECT COUNT(*) FROM sale_events WHERE sale_id = s.id))
     FROM sales s
     JOIN sale_events se ON s.id = se.sale_id
     WHERE se.event_id = e.id AND s.sale_type = 'individual'),
    0
  ) -
  COALESCE(
    (SELECT SUM(amount) FROM expenses WHERE event_id = e.id AND status IN ('aprobado', 'pagado')),
    0
  ) AS net_balance

FROM events e;
```

---

## 🎨 Mockups Actualizados

### MÓDULO UNIFICADO: VENTAS

```
╔══════════════════════════════════════════════════════════════════════╗
║                         💰 GESTIÓN DE VENTAS                         ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ┌────────────────────────────┐  ┌────────────────────────────┐    ║
║  │  [🎁 VENTA PAQUETES]       │  │  [ 🎫 VENTA INDIVIDUAL]    │    ║
║  └────────────────────────────┘  └────────────────────────────┘    ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                       📊 RESUMEN GENERAL                             ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  ║
║  │  Total      │  │   Ventas    │  │   Ventas    │  │  Total   │  ║
║  │  Ventas     │  │  Paquetes   │  │Individuales │  │ Tickets  │  ║
║  │             │  │             │  │             │  │          │  ║
║  │    156      │  │     89      │  │     67      │  │   342    │  ║
║  └─────────────┘  └─────────────┘  └─────────────┘  └──────────┘  ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

### FORMULARIO: VENTA DE PAQUETE

```
┌─────────────────────────────────────────────────────────────────┐
│ 🎁 NUEVA VENTA DE PAQUETE                            [× Cerrar] │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ SELECCIONAR PAQUETE *                                           │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ [Paquete Año Nuevo 2026 - Bs. 850                      ▼]  │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ Incluye los siguientes eventos:                                 │
│ ✓ Año Nuevo 2026 - Tarija (31 Dic)                             │
│ ✓ Año Nuevo 2026 - Santa Cruz (31 Dic)                         │
│ ✓ Año Nuevo 2026 - Cochabamba (31 Dic)                         │
│ ✓ Año Nuevo 2026 - La Paz (31 Dic)                             │
│ ✓ Año Nuevo 2026 - Sucre (31 Dic)                              │
│                                                                 │
│ 💰 Precio del paquete: Bs. 850 (Ahorro 15% vs individual)      │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ INFORMACIÓN DEL CLIENTE                                         │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Nombre completo *                                           │ │
│ │ [_____________________________________________________]     │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Teléfono/WhatsApp *      │  │ Email                      │  │
│ │ [__________________]     │  │ [____________________]     │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ CANTIDAD Y PAGO                                                 │
│ ┌──────────────────────────┐                                   │
│ │ Cantidad de paquetes *   │                                   │
│ │ [- 2 +]                  │                                   │
│ └──────────────────────────┘                                   │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Método de pago *         │  │ RRPP/Vendedor              │  │
│ │ [Transferencia      ▼]   │  │ [María González      ▼]    │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ 📎 Comprobante de pago                                          │
│ [Seleccionar archivo...]                                        │
│                                                                 │
│ TOTAL: Bs. 1,700 (2 paquetes × Bs. 850)                        │
│                                                                 │
│            [Cancelar]  [💾 Registrar Venta]                     │
└─────────────────────────────────────────────────────────────────┘
```

### FORMULARIO: VENTA INDIVIDUAL

```
┌─────────────────────────────────────────────────────────────────┐
│ 🎫 NUEVA VENTA INDIVIDUAL                            [× Cerrar] │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ INFORMACIÓN DEL CLIENTE                                         │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Nombre completo *                                           │ │
│ │ [_____________________________________________________]     │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Teléfono/WhatsApp *      │  │ Email                      │  │
│ │ [__________________]     │  │ [____________________]     │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ SELECCIONAR EVENTOS *                                           │
│                                                                 │
│ Año Nuevo 2026:                                                 │
│ ☑ Tarija - 31 Dic (Bs. 200)                                    │
│ ☑ Santa Cruz - 31 Dic (Bs. 200)                                │
│ ☐ Cochabamba - 31 Dic (Bs. 200)                                │
│ ☐ La Paz - 31 Dic (Bs. 200)                                    │
│ ☐ Sucre - 31 Dic (Bs. 200)                                     │
│                                                                 │
│ Carnaval 2026:                                                  │
│ ☐ Tarija - 15 Feb (Bs. 180)                                    │
│ ☑ Santa Cruz - 15 Feb (Bs. 180)                                │
│ ☐ Cochabamba - 15 Feb (Bs. 180)                                │
│                                                                 │
│ Eventos seleccionados: 3                                        │
│ Subtotal: Bs. 580                                               │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ CANTIDAD Y PAGO                                                 │
│ ┌──────────────────────────┐                                   │
│ │ Cantidad de tickets *    │                                   │
│ │ [- 1 +]                  │                                   │
│ └──────────────────────────┘                                   │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Método de pago *         │  │ RRPP/Vendedor              │  │
│ │ [Transferencia      ▼]   │  │ [María González      ▼]    │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ 📎 Comprobante de pago                                          │
│ [Seleccionar archivo...]                                        │
│                                                                 │
│ TOTAL: Bs. 580 (3 eventos × 1 ticket)                          │
│                                                                 │
│            [Cancelar]  [💾 Registrar Venta]                     │
└─────────────────────────────────────────────────────────────────┘
```

### DASHBOARD: LISTA DE VENTAS

```
┌─────────────────────────────────────────────────────────────────┐
│ 💰 GESTIÓN DE VENTAS                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [🎁 Nueva Venta Paquete] [🎫 Nueva Venta Individual]           │
│                                                                 │
│ Filtros: [Tipo: Todos ▼] [Estado: Todos ▼] 🔍 Buscar...        │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ Tipo  │ Cliente      │ Eventos/Paquete  │ Tickets│ Total│Estado│
├───────┼──────────────┼──────────────────┼────────┼──────┼──────┤
│ 🎁 Paq│ Juan Pérez   │ Paquete Año Nuevo│   2    │ 1700 │ ✓ Pag│
│ 🎫 Ind│ María López  │ 3 eventos        │   1    │  580 │ ⏳Pend│
│ 🎁 Paq│ Carlos Rojas │ Paquete Carnaval │   1    │  450 │ ✓ Pag│
│ 🎫 Ind│ Ana Silva    │ 1 evento (Tarija)│   2    │  400 │ ✓ Pag│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
  [📥 Exportar CSV] [🔄 Actualizar]
```

### MÓDULO: GASTOS CON CATEGORIZACIÓN

```
┌─────────────────────────────────────────────────────────────────┐
│ 💸 NUEVO GASTO                                       [× Cerrar] │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ EVENTO (opcional)                                               │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ [Año Nuevo 2026 - Tarija                               ▼]  │ │
│ └─────────────────────────────────────────────────────────────┘ │
│ Dejar vacío si es un gasto general (no específico de evento)   │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ CATEGORIZACIÓN (OBLIGATORIO)                                    │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Categoría *              │  │ Subcategoría *             │  │
│ │ [🎬 Producción      ▼]   │  │ [Sistema de Sonido    ▼]   │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ DESCRIPCIÓN DEL GASTO *                                         │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ [Alquiler de sistema de sonido completo con DJ booth]      │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ MONTO                                                           │
│ ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐    │
│ │ Cantidad     │  │ Precio Unit. │  │ Total              │    │
│ │ [1]          │  │ Bs.[3500]    │  │ Bs. 3,500          │    │
│ └──────────────┘  └──────────────┘  └────────────────────┘    │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│ PROVEEDOR                                                       │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Nombre del proveedor     │  │ NIT/RUC                    │  │
│ │ [Sonido Pro SA]          │  │ [1234567890]               │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Nº de Factura            │  │ Método de pago             │  │
│ │ [FAC-001234]             │  │ [Transferencia        ▼]   │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ 📎 Factura/Comprobante                                          │
│ [Seleccionar archivo...]                                        │
│                                                                 │
│            [Cancelar]  [💾 Registrar Gasto]                     │
└─────────────────────────────────────────────────────────────────┘
```

### REPORTE: GASTOS POR CATEGORÍA

```
╔══════════════════════════════════════════════════════════════════════╗
║                   📊 REPORTE DE GASTOS DETALLADO                     ║
║                  Año Nuevo 2026 - Tarija                             ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  🎬 PRODUCCIÓN ................................. Bs. 12,500 (35%)   ║
║     ├─ Sistema de Sonido .................... Bs. 3,500            ║
║     ├─ Iluminación .......................... Bs. 2,800            ║
║     ├─ DJ/Artistas .......................... Bs. 4,500            ║
║     ├─ Escenario ............................ Bs. 1,200            ║
║     └─ Efectos Especiales ................... Bs. 500              ║
║                                                                      ║
║  📢 MARKETING Y PUBLICIDAD .................... Bs. 5,200 (15%)    ║
║     ├─ Publicidad en Redes Sociales ......... Bs. 2,500            ║
║     ├─ Flyers y Material Impreso ............ Bs. 800              ║
║     ├─ Publicidad en Radio .................. Bs. 1,200            ║
║     └─ Banners y Gigantografías ............. Bs. 700              ║
║                                                                      ║
║  👥 PERSONAL Y STAFF .......................... Bs. 4,800 (13%)    ║
║     ├─ Coordinadores ........................ Bs. 1,500            ║
║     ├─ Personal de Barra .................... Bs. 2,000            ║
║     ├─ Meseros .............................. Bs. 800              ║
║     └─ Cajeros .............................. Bs. 500              ║
║                                                                      ║
║  🏢 ALQUILER DE ESPACIOS ...................... Bs. 8,000 (22%)    ║
║     └─ Alquiler de Local/Venue .............. Bs. 8,000            ║
║                                                                      ║
║  🛡️  SEGURIDAD ................................. Bs. 3,500 (10%)    ║
║     ├─ Personal de Seguridad ................ Bs. 3,000            ║
║     └─ Vallas y Control de Acceso ........... Bs. 500              ║
║                                                                      ║
║  🍽️  CATERING Y BEBIDAS ........................ Bs. 1,800 (5%)     ║
║     ├─ Hielo ................................ Bs. 300              ║
║     ├─ Comida/Snacks ........................ Bs. 800              ║
║     └─ Vasos/Descartables ................... Bs. 700              ║
║                                                                      ║
║  ──────────────────────────────────────────────────────────────    ║
║  TOTAL GASTOS ................................... Bs. 35,800        ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

## 🔍 Necesito Acceso a tus Repositorios

Para diseñar la integración perfecta, **necesito revisar los otros 3 sistemas**:

1. **Sistema de Registro de Gastos**
2. **Calculadora de Eventos**
3. **Registro de Ventas Individuales**

Por favor comparte:
- 🔗 URLs de los repositorios en GitHub
- 📝 Explicación breve de qué hace cada uno
- 📊 Si tienen datos existentes que migrar

---

## ✅ Próximos Pasos

1. **Revisa esta arquitectura actualizada** ¿Te parece bien?
2. **Comparte los 3 repositorios** para que pueda analizarlos
3. **Decidimos si ejecutamos el plan** o hacemos más ajustes

¿Qué te parece esta nueva estructura? 🎯
