# 📋 Plan Detallado de Unificación - Sistema Integral de Gestión de Eventos

**Versión:** 1.0
**Fecha:** Enero 2026
**Proyecto:** Summer Festival - Sistema Unificado

---

## 📱 1. MOCKUP DEL DASHBOARD PRINCIPAL UNIFICADO

### 1.1 Vista Principal (Main Dashboard)

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                          🎉 SUMMER EVENTS                            ║
║                    Sistema Integral de Gestión                       ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐  ║
║  │ 💰 VENTAS   │ │ 💸 GASTOS   │ │ 🧮 CALCULAR │ │ 👤 VENTAS   │  ║
║  │   EQUIPOS   │ │             │ │   EVENTOS   │ │ INDIVIDUALES│  ║
║  │             │ │             │ │             │ │             │  ║
║  │   [Ir →]    │ │   [Ir →]    │ │   [Ir →]    │ │   [Ir →]    │  ║
║  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘  ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                        📊 RESUMEN GENERAL                            ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐        ║
║  │   INGRESOS     │  │     GASTOS     │  │   BALANCE      │        ║
║  │                │  │                │  │                │        ║
║  │   $45,200      │  │    $18,500     │  │   $26,700      │        ║
║  │                │  │                │  │                │        ║
║  │ 226 tickets    │  │  15 categorías │  │   ▲ +59%       │        ║
║  └────────────────┘  └────────────────┘  └────────────────┘        ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                    🎯 EVENTOS ACTIVOS                                ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  🎆 Año Nuevo 2026                                                  ║
║     └─ 5 ciudades │ 226 tickets │ $45,200 │ Estado: Finalizado     ║
║                                                                      ║
║  🎭 Carnaval Summer 2026                                            ║
║     └─ 3 ciudades │ 89 tickets │ $17,800 │ Estado: En Curso        ║
║                                                                      ║
║  🎵 Festival Primavera 2026                                         ║
║     └─ 2 ciudades │ 0 tickets │ $0 │ Estado: Planificación         ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

### 1.2 Navegación Lateral (Sidebar Alternative)

```
╔════════════════════╗
║   SUMMER EVENTS    ║
╠════════════════════╣
║                    ║
║ 🏠 Dashboard       ║
║                    ║
║ 💰 Ventas          ║
║   ├─ Por Equipos   ║  ← Sistema actual
║   └─ Individuales  ║  ← Nueva integración
║                    ║
║ 💸 Gastos          ║  ← Nueva integración
║                    ║
║ 🧮 Calculadora     ║  ← Nueva integración
║                    ║
║ 🎯 Eventos         ║
║   ├─ Activos       ║
║   └─ Historial     ║
║                    ║
║ 📊 Reportes        ║
║   ├─ Financiero    ║
║   ├─ Por Ciudad    ║
║   └─ Por Evento    ║
║                    ║
║ ⚙️  Configuración  ║
║                    ║
╚════════════════════╝
```

---

## 🗄️ 2. ESQUEMA COMPLETO DE BASE DE DATOS

### 2.1 Tabla: `events` (Nueva - Central del Sistema)

```sql
CREATE TABLE events (
  id SERIAL PRIMARY KEY,
  event_name VARCHAR(200) NOT NULL,
  event_slug VARCHAR(200) UNIQUE NOT NULL,    -- 'ano-nuevo-2026', 'carnaval-2026'
  event_date DATE NOT NULL,
  event_type VARCHAR(50),                      -- 'festival', 'concierto', 'party'
  status VARCHAR(50) DEFAULT 'planificacion',  -- 'planificacion', 'activo', 'finalizado', 'cancelado'
  total_capacity INTEGER,                      -- Capacidad total de tickets
  ticket_base_price DECIMAL(10,2),             -- Precio base del ticket
  description TEXT,
  banner_image_url TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(200)
);

-- Índices
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_slug ON events(event_slug);
CREATE INDEX idx_events_date ON events(event_date);

-- Datos iniciales
INSERT INTO events (event_name, event_slug, event_date, status, ticket_base_price) VALUES
  ('Año Nuevo 2026', 'ano-nuevo-2026', '2026-01-01', 'finalizado', 200.00),
  ('Carnaval Summer 2026', 'carnaval-2026', '2026-02-15', 'activo', 180.00);
```

### 2.2 Tabla: `sales` (Actual - Modificada)

```sql
-- Ya existe, agregar columnas y claves foráneas
ALTER TABLE sales
  ADD COLUMN event_id INTEGER REFERENCES events(id),
  ADD COLUMN payment_method VARCHAR(50) DEFAULT 'transferencia',
  ADD COLUMN notes TEXT,
  ADD COLUMN confirmed BOOLEAN DEFAULT FALSE,
  ADD COLUMN confirmed_by VARCHAR(200),
  ADD COLUMN confirmed_at TIMESTAMP;

-- Migrar datos existentes a event_id
UPDATE sales
SET event_id = (SELECT id FROM events WHERE event_slug = 'ano-nuevo-2026')
WHERE event_name = 'Año Nuevo 2026';

UPDATE sales
SET event_id = (SELECT id FROM events WHERE event_slug = 'carnaval-2026')
WHERE event_name = 'Carnaval Summer 2026';

-- Índices adicionales
CREATE INDEX idx_sales_event_id ON sales(event_id);
CREATE INDEX idx_sales_confirmed ON sales(confirmed);
CREATE INDEX idx_sales_city_event ON sales(city, event_id);
```

### 2.3 Tabla: `individual_sales` (Nueva)

```sql
CREATE TABLE individual_sales (
  id SERIAL PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id),

  -- Información del cliente
  customer_name VARCHAR(200) NOT NULL,
  customer_phone VARCHAR(50),
  customer_email VARCHAR(200),
  customer_id_number VARCHAR(50),               -- CI/DNI/Pasaporte

  -- Información de venta
  city VARCHAR(100) NOT NULL,
  ticket_quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,

  -- Vendedor/RRPP
  rrpp_name VARCHAR(200),
  rrpp_commission DECIMAL(10,2),

  -- Pago
  payment_method VARCHAR(50) NOT NULL,          -- 'efectivo', 'transferencia', 'qr', 'tarjeta'
  payment_status VARCHAR(50) DEFAULT 'pendiente', -- 'pendiente', 'pagado', 'parcial'
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

-- Índices
CREATE INDEX idx_individual_sales_event ON individual_sales(event_id);
CREATE INDEX idx_individual_sales_city ON individual_sales(city);
CREATE INDEX idx_individual_sales_customer ON individual_sales(customer_phone);
CREATE INDEX idx_individual_sales_payment_status ON individual_sales(payment_status);
```

### 2.4 Tabla: `expenses` (Nueva)

```sql
CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,
  event_id INTEGER REFERENCES events(id),       -- NULL = gasto general, no específico de evento

  -- Información del gasto
  description TEXT NOT NULL,
  category VARCHAR(100) NOT NULL,               -- Ver categorías abajo
  subcategory VARCHAR(100),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'BOB',

  -- Ubicación
  city VARCHAR(100),

  -- Proveedor/Beneficiario
  vendor_name VARCHAR(200),
  vendor_id VARCHAR(100),                       -- RUC/NIT del proveedor

  -- Documentación
  invoice_number VARCHAR(100),
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Aprobación
  status VARCHAR(50) DEFAULT 'pendiente',       -- 'pendiente', 'aprobado', 'rechazado', 'pagado'
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

-- Índices
CREATE INDEX idx_expenses_event ON expenses(event_id);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_status ON expenses(status);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_city ON expenses(city);

-- Categorías de gastos
COMMENT ON COLUMN expenses.category IS
  'Categorías: Producción, Marketing, Personal, Logística, Alquiler,
   Seguridad, Catering, Tecnología, Legal, Transporte, Otros';
```

### 2.5 Tabla: `event_calculations` (Nueva - Para Calculadora)

```sql
CREATE TABLE event_calculations (
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
  scenario_type VARCHAR(50),                    -- 'pesimista', 'realista', 'optimista'

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(200),
  notes TEXT
);

-- Índices
CREATE INDEX idx_calculations_event ON event_calculations(event_id);
CREATE INDEX idx_calculations_city ON event_calculations(city);
```

### 2.6 Vistas Útiles (Para Reportes)

```sql
-- Vista: Resumen financiero por evento
CREATE VIEW v_event_financial_summary AS
SELECT
  e.id,
  e.event_name,
  e.event_slug,
  e.status,

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
   COALESCE(SUM(ex.amount), 0)) AS net_profit

FROM events e
LEFT JOIN sales s ON s.event_id = e.id
LEFT JOIN individual_sales i ON i.event_id = e.id
LEFT JOIN expenses ex ON ex.event_id = e.id
GROUP BY e.id, e.event_name, e.event_slug, e.status, e.ticket_base_price;


-- Vista: Resumen por ciudad
CREATE VIEW v_city_summary AS
SELECT
  city,
  COUNT(DISTINCT event_id) AS total_events,
  SUM(ticket_quantity) AS total_tickets,
  COUNT(*) AS total_sales
FROM sales
GROUP BY city
ORDER BY total_tickets DESC;


-- Vista: Top RRPPs
CREATE VIEW v_top_rrpps AS
SELECT
  rrpp_name,
  COUNT(*) AS total_sales,
  SUM(ticket_quantity) AS total_tickets,
  COUNT(DISTINCT event_id) AS events_worked
FROM sales
WHERE rrpp_name IS NOT NULL
GROUP BY rrpp_name
ORDER BY total_tickets DESC;
```

---

## 🎨 3. DISEÑO DE MÓDULOS DETALLADO

### 3.1 Módulo: Ventas por Equipos (Actual Mejorado)

**Ruta:** `/dashboard/sales-teams.html`
**API:** `/api/sales/*`

#### Características Mejoradas:
- ✅ Filtro por evento (ya existe)
- ✅ Filtro por ciudad (ya existe)
- ➕ **NUEVO**: Filtro por estado de confirmación
- ➕ **NUEVO**: Asignación de paquetes por lote
- ➕ **NUEVO**: Notificaciones de entrega pendiente
- ➕ **NUEVO**: Integración con ventas individuales (vista comparativa)

#### Mockup:

```
┌─────────────────────────────────────────────────────────────────┐
│ 💰 VENTAS POR EQUIPOS                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [Evento: Todos ▼] [Ciudad: Todas ▼] [Estado: Todos ▼] 🔍       │
│                                                                 │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│ │ Total Ventas│ │Total Tickets│ │  Pendientes │               │
│ │     45      │ │     226     │ │     12      │               │
│ └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                 │
│ Tarija: 89 tickets • Santa Cruz: 67 tickets • La Paz: 42 ...   │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ ID │ Líder    │ RRPP    │ Evento  │ Ciudad │ Tickets │ Estado │
├────┼──────────┼─────────┼─────────┼────────┼─────────┼────────┤
│ 45 │ Juan P.  │ María G.│ Año Nvo │ Tarija │   15    │ ✓ OK   │
│ 44 │ Carlos M.│ Ana L.  │ Carnaval│ SC     │    8    │ ⏳ Pend│
│ 43 │ Sofia R. │ Luis T. │ Año Nvo │ LPZ    │   12    │ ✓ OK   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
  [🔄 Actualizar] [📥 Exportar CSV] [📦 Asignar lote]
```

---

### 3.2 Módulo: Ventas Individuales (Nuevo)

**Ruta:** `/dashboard/sales-individual.html`
**API:** `/api/individual-sales/*`

#### Características:
- Registro de venta directa a cliente final
- Campos de cliente (nombre, teléfono, email, CI)
- Selección de método de pago
- Tracking de entrega de tickets
- Comisiones de RRPP
- Búsqueda por cliente

#### Mockup:

```
┌─────────────────────────────────────────────────────────────────┐
│ 👤 VENTAS INDIVIDUALES                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [+ Nueva Venta Individual]                      🔍 Buscar...    │
│                                                                 │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│ │ Total Ventas │ │Total Clientes│ │ Por Entregar │            │
│ │     128      │ │      95      │ │      18      │            │
│ └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ Cliente     │ Tel/Email     │ Ciudad │ Tickets │ Pago  │ Estado│
├─────────────┼───────────────┼────────┼─────────┼───────┼───────┤
│ Ana Mendoza │ 789-555-1234  │ Tarija │    2    │ Transf│ ✓ Ent │
│ Pedro Ruiz  │ pedro@mail.com│   SC   │    1    │ QR    │ ⏳ Pend│
│ Laura Gómez │ 771-555-9876  │  CBBA  │    3    │ Efect │ ✓ Ent │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Formulario de Nueva Venta:

```
┌─────────────────────────────────────────────────────────────────┐
│ ➕ NUEVA VENTA INDIVIDUAL                               [× Cerrar│
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ INFORMACIÓN DEL CLIENTE                                         │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Nombre completo *                                           │ │
│ │ [_____________________________________________________]     │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Teléfono/WhatsApp        │  │ Email                      │  │
│ │ [__________________]     │  │ [____________________]     │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ INFORMACIÓN DE VENTA                                            │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Evento *                 │  │ Ciudad *                   │  │
│ │ [Carnaval 2026     ▼]    │  │ [Tarija           ▼]       │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Cantidad *               │  │ Precio unitario            │  │
│ │ [- 2 +]                  │  │ Bs. 180.00 (automático)    │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Método de pago *         │  │ RRPP (opcional)            │  │
│ │ [Transferencia      ▼]   │  │ [María González      ▼]    │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ 📎 Comprobante de pago                                          │
│ [Seleccionar archivo...]  comprobante.jpg                       │
│                                                                 │
│ TOTAL: Bs. 360.00                                               │
│                                                                 │
│            [Cancelar]  [💾 Guardar Venta]                       │
└─────────────────────────────────────────────────────────────────┘
```

---

### 3.3 Módulo: Gastos (Nuevo)

**Ruta:** `/dashboard/expenses.html`
**API:** `/api/expenses/*`

#### Características:
- Registro de gastos por categoría
- Asociación a eventos o gastos generales
- Sistema de aprobación de gastos
- Upload de facturas/comprobantes
- Reportes por categoría y período
- Filtro por estado (pendiente/aprobado/pagado)

#### Mockup:

```
┌─────────────────────────────────────────────────────────────────┐
│ 💸 REGISTRO DE GASTOS                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [+ Nuevo Gasto]                                   🔍 Buscar...  │
│                                                                 │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│ │ Total Gastos │ │  Pendientes  │ │   Aprobados  │            │
│ │  Bs. 18,500  │ │   Bs. 3,200  │ │  Bs. 15,300  │            │
│ └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                 │
│ [Evento: Todos ▼] [Categoría: Todas ▼] [Estado: Todos ▼]       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ Fecha    │ Descripción       │ Categoría │ Monto │ Estado      │
├──────────┼───────────────────┼───────────┼───────┼─────────────┤
│ 05/01/26 │ Alquiler Local SC │ Alquiler  │ 5,000 │ ✓ Pagado    │
│ 03/01/26 │ Publicidad FB Ads │ Marketing │ 2,500 │ ⏰ Aprobado │
│ 02/01/26 │ DJ Año Nuevo      │ Personal  │ 4,000 │ ✓ Pagado    │
│ 30/12/25 │ Sistema de Sonido │Producción │ 3,200 │ ⏳ Pendiente│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

CATEGORÍAS:
📦 Producción  │  📢 Marketing  │  👥 Personal  │  🚚 Logística
🏢 Alquiler    │  🛡️  Seguridad │  🍽️  Catering │  💻 Tecnología
```

#### Formulario de Nuevo Gasto:

```
┌─────────────────────────────────────────────────────────────────┐
│ ➕ NUEVO GASTO                                          [× Cerrar│
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Evento                   │  │ Fecha del gasto *          │  │
│ │ [Carnaval 2026     ▼]    │  │ [05/01/2026]               │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Descripción del gasto *                                     │ │
│ │ [Alquiler de equipo de sonido para evento en Santa Cruz]   │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Categoría *              │  │ Subcategoría               │  │
│ │ [Producción        ▼]    │  │ [Sonido           ▼]       │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Monto *                  │  │ Ciudad                     │  │
│ │ Bs. [________]           │  │ [Santa Cruz       ▼]       │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ PROVEEDOR                                                       │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Nombre del proveedor     │  │ NIT/RUC                    │  │
│ │ [__________________]     │  │ [______________]           │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌──────────────────────────┐                                   │
│ │ Nº de Factura            │                                   │
│ │ [__________________]     │                                   │
│ └──────────────────────────┘                                   │
│                                                                 │
│ 📎 Factura/Comprobante                                          │
│ [Seleccionar archivo...]                                        │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Notas adicionales                                           │ │
│ │ [_______________________________________________________]   │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│            [Cancelar]  [💾 Registrar Gasto]                     │
└─────────────────────────────────────────────────────────────────┘
```

---

### 3.4 Módulo: Calculadora de Eventos (Nuevo)

**Ruta:** `/dashboard/calculator.html`
**API:** `/api/calculations/*`

#### Características:
- Calculadora de costos y proyecciones
- Múltiples escenarios (pesimista, realista, optimista)
- Punto de equilibrio automático
- Comparativa de márgenes
- Guardado de cálculos históricos
- Exportar a PDF

#### Mockup:

```
┌─────────────────────────────────────────────────────────────────┐
│ 🧮 CALCULADORA DE EVENTOS                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [+ Nuevo Cálculo]  [📂 Cargar Guardado]         [💾 Guardar]   │
│                                                                 │
│ DATOS DEL EVENTO                                                │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Nombre del evento        │  │ Ciudad                     │  │
│ │ [Festival Primavera 2026]│  │ [Tarija           ▼]       │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ ┌──────────────────────────┐  ┌────────────────────────────┐  │
│ │ Capacidad total          │  │ Asistencia esperada (%)    │  │
│ │ [500]                    │  │ [───●────────] 75%         │  │
│ └──────────────────────────┘  └────────────────────────────┘  │
│                                                                 │
│ PRECIOS DE TICKETS                                              │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│ │ General      │ │ VIP          │ │ Early Bird   │            │
│ │ Bs. [180]    │ │ Bs. [350]    │ │ Bs. [150]    │            │
│ │ 60% (300)    │ │ 30% (150)    │ │ 10% (50)     │            │
│ └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                 │
│ COSTOS ESTIMADOS                                                │
│ • Local/Venue:        Bs.  8,000                                │
│ • Producción:         Bs.  12,000                               │
│ • Marketing:          Bs.  5,000                                │
│ • Personal:           Bs.  4,500                                │
│ • Otros:              Bs.  2,500                                │
│ ──────────────────────────────────                              │
│   TOTAL COSTOS:       Bs.  32,000                               │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                    📊 RESULTADOS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                       INGRESOS PROYECTADOS               │  │
│  │                                                          │  │
│  │  General:    300 × Bs. 180  =  Bs. 54,000               │  │
│  │  VIP:        150 × Bs. 350  =  Bs. 52,500               │  │
│  │  Early:       50 × Bs. 150  =  Bs.  7,500               │  │
│  │                                  ──────────              │  │
│  │  TOTAL INGRESOS:                 Bs. 114,000            │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    ANÁLISIS FINANCIERO                   │  │
│  │                                                          │  │
│  │  💰 Utilidad Neta:        Bs.  82,000                    │  │
│  │  📈 Margen de Ganancia:        71.9%                     │  │
│  │  ⚖️  Punto de Equilibrio:     141 tickets                │  │
│  │  ✅ Capacidad Utilizada:       75%                       │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │ ████████████████████░░░░░░░ 71.9% RENTABLE       │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ESCENARIOS:                                                    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ 😟 PESIMISTA │ │ 😐 REALISTA  │ │ 😊 OPTIMISTA │           │
│  │   (50%)      │ │   (75%) ✓    │ │   (100%)     │           │
│  │ Utilidad:    │ │ Utilidad:    │ │ Utilidad:    │           │
│  │ Bs. 44,000   │ │ Bs. 82,000   │ │ Bs. 120,000  │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│                                                                 │
│         [📊 Ver Gráficos] [📄 Exportar PDF] [🔄 Recalcular]    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 4. PLAN DE IMPLEMENTACIÓN DETALLADO

### FASE 1: PREPARACIÓN Y REESTRUCTURACIÓN (2-3 días)

#### Día 1: Reestructuración del Proyecto

**Tareas:**
1. ✅ Crear nueva estructura de carpetas
   ```
   /public/
     /dashboard/
       main.html (dashboard principal)
       sales-teams.html (renombrar dashboard.html actual)
       sales-individual.html (placeholder)
       expenses.html (placeholder)
       calculator.html (placeholder)
     /forms/
       /sales/ (mover formularios actuales)
       /individual/ (placeholder)
   /api/
     sales.js (separar del index.js actual)
     individual-sales.js (nuevo)
     expenses.js (nuevo)
     calculations.js (nuevo)
     events.js (nuevo)
     index.js (router principal)
   /shared/
     /css/
       global.css (estilos compartidos)
       variables.css (colores, fuentes)
     /js/
       api-client.js (funciones de API compartidas)
       utils.js (funciones comunes)
   ```

2. ✅ Migrar archivos existentes a nueva estructura
3. ✅ Actualizar referencias y rutas en HTML
4. ✅ Probar que todo sigue funcionando

**Comandos Git:**
```bash
# Crear nueva estructura
mkdir -p public/dashboard public/forms/sales public/forms/individual
mkdir -p api shared/css shared/js

# Mover archivos
mv public/dashboard.html public/dashboard/sales-teams.html
mv public/dashboard.css shared/css/dashboard.css
mv *.html public/forms/sales/

# Commit
git add .
git commit -m "refactor: reorganize project structure for unified system"
```

#### Día 2-3: Base de Datos y API Base

**Tareas:**
1. ✅ Crear tabla `events` en Supabase
2. ✅ Migrar datos existentes a `event_id`
3. ✅ Crear API `/api/events/*`
4. ✅ Actualizar API de ventas para usar `event_id`
5. ✅ Crear dashboard principal (`main.html`)
6. ✅ Implementar navegación entre módulos

**Script SQL:**
```sql
-- Ejecutar en Supabase SQL Editor
-- Ver sección 2.1 para script completo
```

**Estructura del Router Principal:**
```javascript
// api/index.js
const express = require('express');
const salesRouter = require('./sales');
const eventsRouter = require('./events');
// ... otros routers cuando estén listos

const app = express();

app.use('/api/sales', salesRouter);
app.use('/api/events', eventsRouter);
// app.use('/api/individual-sales', individualRouter);
// app.use('/api/expenses', expensesRouter);
// app.use('/api/calculations', calculationsRouter);

module.exports = app;
```

---

### FASE 2: INTEGRACIÓN DE MÓDULOS (4-5 días)

#### Día 4: Módulo de Ventas Individuales

**Tareas:**
1. ✅ Crear tabla `individual_sales`
2. ✅ Crear API `/api/individual-sales/*`
   - POST `/api/individual-sales` - Crear venta
   - GET `/api/individual-sales` - Listar todas
   - PATCH `/api/individual-sales/:id` - Actualizar
   - PATCH `/api/individual-sales/:id/delivery` - Marcar entrega
3. ✅ Crear dashboard `sales-individual.html`
4. ✅ Crear formulario de registro
5. ✅ Probar flujo completo

**API Endpoints:**
```javascript
// api/individual-sales.js
router.post('/', upload.single('receipt'), async (req, res) => {
  // Crear venta individual
  // Upload de comprobante si existe
  // Calcular monto total
  // Insertar en BD
});

router.get('/', async (req, res) => {
  // Filtros: event_id, city, payment_status
  // Ordenar por created_at DESC
});

router.patch('/:id/delivery', async (req, res) => {
  // Actualizar tickets_delivered
  // Registrar delivery_date
});
```

#### Día 5-6: Módulo de Gastos

**Tareas:**
1. ✅ Crear tabla `expenses`
2. ✅ Crear API `/api/expenses/*`
   - POST `/api/expenses` - Crear gasto
   - GET `/api/expenses` - Listar con filtros
   - PATCH `/api/expenses/:id` - Actualizar
   - PATCH `/api/expenses/:id/approve` - Aprobar gasto
   - DELETE `/api/expenses/:id` - Eliminar (soft delete)
3. ✅ Crear dashboard `expenses.html`
4. ✅ Implementar sistema de categorías
5. ✅ Implementar flujo de aprobación
6. ✅ Crear reportes por categoría

#### Día 7-8: Módulo Calculadora

**Tareas:**
1. ✅ Crear tabla `event_calculations`
2. ✅ Crear API `/api/calculations/*`
3. ✅ Crear interfaz de calculadora
4. ✅ Implementar lógica de cálculos
5. ✅ Implementar escenarios múltiples
6. ✅ Exportación a PDF (opcional)

**Lógica de Cálculo:**
```javascript
function calculateEventProjection(data) {
  const {
    capacity,
    attendance_percent,
    prices,        // { general, vip, early }
    distribution,  // { general: 0.6, vip: 0.3, early: 0.1 }
    costs          // { venue, production, marketing, staff, other }
  } = data;

  const expected_attendance = capacity * (attendance_percent / 100);

  // Calcular tickets por tipo
  const tickets = {
    general: Math.round(expected_attendance * distribution.general),
    vip: Math.round(expected_attendance * distribution.vip),
    early: Math.round(expected_attendance * distribution.early)
  };

  // Calcular ingresos
  const revenue = {
    general: tickets.general * prices.general,
    vip: tickets.vip * prices.vip,
    early: tickets.early * prices.early,
    total: 0
  };
  revenue.total = revenue.general + revenue.vip + revenue.early;

  // Calcular costos
  const total_costs = Object.values(costs).reduce((sum, cost) => sum + cost, 0);

  // Análisis
  const profit = revenue.total - total_costs;
  const margin = (profit / revenue.total) * 100;

  // Punto de equilibrio (usando precio promedio)
  const avg_price = revenue.total / (tickets.general + tickets.vip + tickets.early);
  const break_even = Math.ceil(total_costs / avg_price);

  return {
    tickets,
    revenue,
    costs: { ...costs, total: total_costs },
    profit,
    margin,
    break_even
  };
}
```

---

### FASE 3: UNIFICACIÓN Y REPORTES (3-4 días)

#### Día 9-10: Dashboard Unificado

**Tareas:**
1. ✅ Mejorar `main.html` con datos reales
2. ✅ Implementar resumen financiero general
3. ✅ Crear vista de eventos con drilling
4. ✅ Implementar gráficos (opcional: Chart.js)
5. ✅ Crear sistema de notificaciones/alertas

**Estructura del Dashboard Principal:**
```javascript
// Cargar datos de múltiples fuentes
async function loadDashboardData() {
  const [events, salesSummary, expensesSummary, calculations] =
    await Promise.all([
      fetch('/api/events?status=activo'),
      fetch('/api/sales/summary'),
      fetch('/api/expenses/summary'),
      fetch('/api/calculations/latest')
    ]);

  // Renderizar estadísticas
  renderFinancialSummary(salesSummary, expensesSummary);
  renderActiveEvents(events);
  renderAlerts();
}
```

#### Día 11-12: Módulo de Reportes

**Tareas:**
1. ✅ Crear `/dashboard/reports.html`
2. ✅ Implementar reporte financiero consolidado
3. ✅ Reporte por ciudad
4. ✅ Reporte por evento
5. ✅ Reporte de RRPPs (ranking)
6. ✅ Exportación CSV/PDF

**Tipos de Reportes:**
- **Financiero General**: Ingresos vs Gastos por período
- **Por Evento**: Desglose completo de un evento
- **Por Ciudad**: Comparativa entre ciudades
- **Por RRPP**: Ranking de vendedores
- **Histórico**: Evolución en el tiempo

---

### FASE 4: TESTING Y DEPLOYMENT (1-2 días)

#### Día 13: Testing Integral

**Checklist de Testing:**
- [ ] Todas las APIs responden correctamente
- [ ] Filtros funcionan en todos los dashboards
- [ ] Upload de archivos funciona (recibos, facturas)
- [ ] Export CSV funciona en todos los módulos
- [ ] Navegación entre módulos es fluida
- [ ] Responsive design en móvil
- [ ] No hay errores en consola
- [ ] Datos históricos migrados correctamente

#### Día 14: Deploy y Documentación

**Tareas:**
1. ✅ Actualizar variables de entorno en Vercel
2. ✅ Deploy a producción
3. ✅ Verificar en producción
4. ✅ Crear documentación de usuario
5. ✅ Crear guía de mantenimiento

---

## 📊 5. DIAGRAMAS DE FLUJO

### 5.1 Flujo de Venta por Equipos (Actual)

```
┌──────────────┐
│ Líder llena  │
│  formulario  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Sube compro- │
│    bante     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Guarda en    │
│    sales     │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────┐
│  Dashboard   │────▶│ Admin marca    │
│   muestra    │     │retiro de tickets│
└──────────────┘     └────────────────┘
```

### 5.2 Flujo de Venta Individual (Nuevo)

```
┌──────────────┐
│ RRPP/Admin   │
│ abre form    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Ingresa datos│
│  de cliente  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Selecciona   │
│ método pago  │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────┐
│ Guarda en    │────▶│ Se calcula     │
│ individual_  │     │  comisión      │
│   sales      │     └────────────────┘
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────┐
│  Dashboard   │────▶│ Admin marca    │
│   muestra    │     │   entrega      │
└──────────────┘     └────────────────┘
```

### 5.3 Flujo de Gasto (Nuevo)

```
┌──────────────┐
│ Usuario crea │
│    gasto     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Sube factura │
│   opcional   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Estado:      │
│  PENDIENTE   │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────┐
│ Admin revisa │────▶│  ¿Aprobado?    │
│   en dash    │     └────┬───────┬───┘
└──────────────┘          │       │
                         SÍ      NO
                          │       │
                          ▼       ▼
                    ┌─────────┐ ┌──────────┐
                    │APROBADO │ │RECHAZADO │
                    └────┬────┘ └──────────┘
                         │
                         ▼
                    ┌─────────┐
                    │ PAGADO  │
                    └─────────┘
```

### 5.4 Flujo de Calculadora (Nuevo)

```
┌──────────────┐
│ Usuario      │
│ ingresa datos│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Sistema      │
│ calcula auto │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────┐
│ Muestra 3    │────▶│ Usuario ajusta │
│ escenarios   │     │  parámetros    │
└──────┬───────┘     └────────┬───────┘
       │                      │
       │◀─────────────────────┘
       │
       ▼
┌──────────────┐     ┌────────────────┐
│ ¿Guardar?    │────▶│ Guarda en      │
└──────────────┘  SÍ │ event_         │
                     │ calculations   │
                     └────────────────┘
```

---

## 🎯 6. PRIORIDADES Y HITOS

### Hito 1: Dashboard Principal Funcionando (Día 3)
✅ Estructura reestructurada
✅ Tabla events creada
✅ Dashboard principal con navegación
✅ Sistema actual funcionando en nueva estructura

### Hito 2: Primer Módulo Integrado (Día 5)
✅ Ventas individuales funcionando
✅ CRUD completo
✅ Dashboard operativo

### Hito 3: Sistema Completo (Día 8)
✅ Todos los módulos integrados
✅ Gastos y calculadora funcionando
✅ Navegación fluida

### Hito 4: Producción (Día 14)
✅ Testing completo
✅ Deploy exitoso
✅ Documentación lista
✅ Sistema unificado en producción

---

## 💡 7. RECOMENDACIONES TÉCNICAS

### 7.1 Compartir Código Entre Módulos

**Archivo: `/shared/js/api-client.js`**
```javascript
// Cliente API reutilizable
class APIClient {
  constructor(baseURL = '/api') {
    this.baseURL = baseURL;
  }

  async get(endpoint, params = {}) {
    const url = new URL(this.baseURL + endpoint, window.location.origin);
    Object.keys(params).forEach(key =>
      params[key] && url.searchParams.append(key, params[key])
    );

    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }

  async post(endpoint, data, file = null) {
    const formData = new FormData();

    if (file) {
      formData.append('receipt', file);
    }

    Object.keys(data).forEach(key => {
      if (data[key] !== null && data[key] !== undefined) {
        formData.append(key, data[key]);
      }
    });

    const response = await fetch(this.baseURL + endpoint, {
      method: 'POST',
      body: formData
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Error en la petición');
    }

    return response.json();
  }

  async patch(endpoint, data) {
    const response = await fetch(this.baseURL + endpoint, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }
}

// Uso en cualquier dashboard:
const api = new APIClient();
const sales = await api.get('/sales', { city: 'Tarija', event_id: 1 });
```

### 7.2 Sistema de Notificaciones/Toasts

**Archivo: `/shared/js/notifications.js`**
```javascript
class Notifications {
  static show(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.cssText = `
      position: fixed; top: 20px; right: 20px; z-index: 9999;
      padding: 16px 24px; border-radius: 12px;
      background: ${type === 'success' ? '#4CAF50' : '#f44336'};
      color: white; font-weight: 700; box-shadow: 0 8px 24px rgba(0,0,0,0.3);
      animation: slideIn 0.3s ease;
    `;

    document.body.appendChild(toast);

    setTimeout(() => {
      toast.style.animation = 'slideOut 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }

  static success(message) { this.show(message, 'success'); }
  static error(message) { this.show(message, 'error'); }
}

// Uso:
Notifications.success('Venta registrada correctamente');
Notifications.error('Error al procesar el pago');
```

### 7.3 Componente de Filtros Reutilizable

```javascript
// Función para crear filtros estándar
function createFilters(config) {
  const filtersHTML = config.filters.map(filter => {
    if (filter.type === 'select') {
      return `
        <select id="${filter.id}" class="filter-select">
          <option value="">${filter.placeholder}</option>
          ${filter.options.map(opt =>
            `<option value="${opt.value}">${opt.label}</option>`
          ).join('')}
        </select>
      `;
    } else if (filter.type === 'search') {
      return `
        <input type="search" id="${filter.id}"
               placeholder="${filter.placeholder}"
               class="filter-search" />
      `;
    }
  }).join('');

  return `<div class="filters">${filtersHTML}</div>`;
}

// Uso:
const filtersConfig = {
  filters: [
    {
      id: 'eventFilter',
      type: 'select',
      placeholder: 'Todos los eventos',
      options: [
        { value: 1, label: 'Año Nuevo 2026' },
        { value: 2, label: 'Carnaval 2026' }
      ]
    },
    {
      id: 'searchInput',
      type: 'search',
      placeholder: 'Buscar...'
    }
  ]
};
```

### 7.4 Manejo de Errores Centralizado

```javascript
// shared/js/error-handler.js
class ErrorHandler {
  static async handle(error, context = '') {
    console.error(`[${context}]`, error);

    let message = 'Ocurrió un error inesperado';

    if (error.message.includes('HTTP 404')) {
      message = 'Recurso no encontrado';
    } else if (error.message.includes('HTTP 401')) {
      message = 'No autorizado - verifica tu sesión';
    } else if (error.message.includes('HTTP 500')) {
      message = 'Error del servidor - intenta más tarde';
    } else if (error.message) {
      message = error.message;
    }

    Notifications.error(message);

    // Opcional: enviar a sistema de logging
    // await this.logToServer(error, context);
  }
}

// Uso:
try {
  await api.post('/sales', data);
} catch (error) {
  ErrorHandler.handle(error, 'CrearVenta');
}
```

---

## 🔐 8. CONSIDERACIONES DE SEGURIDAD

### 8.1 Roles y Permisos (Futuro)

Si necesitas control de acceso, considera agregar:

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(200) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'viewer',  -- admin, manager, rrpp, viewer
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_permissions (
  user_id INTEGER REFERENCES users(id),
  module VARCHAR(100),                 -- 'sales', 'expenses', 'reports'
  can_create BOOLEAN DEFAULT FALSE,
  can_read BOOLEAN DEFAULT TRUE,
  can_update BOOLEAN DEFAULT FALSE,
  can_delete BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (user_id, module)
);
```

### 8.2 Validación de Datos

En cada endpoint de API, validar:
- Tipos de datos
- Rangos válidos (precios > 0, cantidades > 0)
- Campos requeridos
- Longitud de strings
- Formato de archivos

```javascript
function validateSale(data) {
  const errors = [];

  if (!data.team_leader?.trim()) {
    errors.push('El nombre del líder es requerido');
  }

  if (!data.ticket_quantity || data.ticket_quantity < 1) {
    errors.push('La cantidad de tickets debe ser mayor a 0');
  }

  if (!data.event_id) {
    errors.push('Debe seleccionar un evento');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
```

---

## 📱 9. MÓVIL Y RESPONSIVE

Todos los dashboards deben ser responsivos:

```css
/* shared/css/responsive.css */
@media (max-width: 768px) {
  .stats {
    grid-template-columns: 1fr;
  }

  .table-wrap {
    max-height: 50vh;
  }

  .controls {
    flex-direction: column;
    width: 100%;
  }

  .btn {
    width: 100%;
  }

  /* Ocultar columnas no esenciales en móvil */
  table th:nth-child(n+5),
  table td:nth-child(n+5) {
    display: none;
  }
}
```

---

## 📚 10. DOCUMENTACIÓN PARA USUARIOS

Crear un archivo `MANUAL-USUARIO.md` con:

1. **Introducción al Sistema**
2. **Acceso y Navegación**
3. **Módulo de Ventas por Equipos**
   - Cómo registrar una venta
   - Cómo marcar entregas
   - Exportar reportes
4. **Módulo de Ventas Individuales**
   - Registro de clientes
   - Tracking de pagos
5. **Módulo de Gastos**
   - Crear gastos
   - Flujo de aprobación
   - Categorías disponibles
6. **Calculadora de Eventos**
   - Cómo hacer proyecciones
   - Interpretar resultados
7. **Reportes**
   - Tipos de reportes
   - Cómo exportar datos
8. **Preguntas Frecuentes**

---

## ✅ 11. CHECKLIST FINAL

Antes de considerar el proyecto completado:

### Funcionalidad
- [ ] Todos los módulos funcionan correctamente
- [ ] APIs responden sin errores
- [ ] Filtros y búsquedas operativos
- [ ] Upload de archivos funciona
- [ ] Exportación de datos funciona
- [ ] Navegación fluida entre módulos
- [ ] Datos históricos migrados

### UI/UX
- [ ] Diseño consistente entre módulos
- [ ] Responsive en móvil
- [ ] Mensajes de error claros
- [ ] Loading states implementados
- [ ] Confirmaciones en acciones críticas

### Datos
- [ ] Base de datos estructurada
- [ ] Índices creados
- [ ] Respaldos configurados (Supabase automático)
- [ ] Vistas de reportes creadas

### Deployment
- [ ] Variables de entorno configuradas
- [ ] Deploy en Vercel exitoso
- [ ] URLs funcionando correctamente
- [ ] Certificado SSL activo

### Documentación
- [ ] README actualizado
- [ ] Manual de usuario creado
- [ ] Guía de mantenimiento
- [ ] Comentarios en código crítico

---

## 🎉 CONCLUSIÓN

Este plan te permite unificar tus 4 sistemas en uno solo de forma ordenada y escalable:

✅ **Una sola base de datos** (Supabase)
✅ **Un solo deploy** (Vercel)
✅ **Código organizado** y reutilizable
✅ **Navegación integrada** entre módulos
✅ **Reportes consolidados** de todos los sistemas

**Tiempo estimado total:** 10-14 días de desarrollo

**Próximos pasos sugeridos:**
1. Revisar este plan y hacer ajustes si es necesario
2. Preparar los otros 3 sistemas para migración
3. Comenzar con la Fase 1 (Reestructuración)
4. Migrar módulo por módulo
5. Testing integral
6. Deploy a producción

---

**¿Listo para empezar con la implementación?** 🚀
