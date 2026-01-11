# 🎯 PLAN MAESTRO DE INTEGRACIÓN - SISTEMA UNIFICADO
## Summer Festival - Integración de 4 Sistemas

**Versión:** 3.0 Final
**Fecha:** Enero 2026
**Autor:** Claude Code
**Estado:** Análisis Completo de 4 Repositorios

---

## 📊 RESUMEN EJECUTIVO

### Situación Actual

Tienes **4 sistemas separados** en producción:

| # | Sistema | Repo | Tecnología | Estado | Complejidad |
|---|---------|------|------------|--------|-------------|
| 1 | **Ventas Paquetes** | `summer-festival-sales` | Express + Supabase | ✅ Producción | Media |
| 2 | **Ventas Individuales** | `ventas-individuales-summer` | Express + Supabase | ✅ Producción | Media |
| 3 | **Gastos** | `gastos-summer` | Vite + React + Supabase | ⚠️ Desarrollo | Baja |
| 4 | **Calculadora** | `calculadora-summer` | Next.js + Firebase | ⚠️ Desarrollo | Alta |

### Objetivo

**Unificar los 4 sistemas en una sola aplicación** con:
- ✅ 1 base de datos Supabase
- ✅ 1 deploy en Vercel
- ✅ Código compartido y reutilizable
- ✅ Navegación integrada
- ✅ Reportes consolidados

---

## 🔍 ANÁLISIS DETALLADO DE CADA SISTEMA

### 1️⃣ Sistema: VENTAS PAQUETES (summer-festival-sales)

**Estado:** ✅ En producción
**URL:** Ya desplegado en Vercel
**Base de Datos:** Supabase PostgreSQL

#### Características Actuales

```yaml
Tecnologías:
  Backend: Express.js + Node.js
  Frontend: HTML + Vanilla JavaScript
  Base de Datos: Supabase PostgreSQL
  Storage: Bucket "receipts" (público)
  Deploy: Vercel (serverless)

Tabla Principal: sales
  Campos:
    - id (SERIAL)
    - team_leader (TEXT)
    - rrpp_name (TEXT)
    - ticket_quantity (INTEGER)
    - city (TEXT)
    - event_name (TEXT) ← "Año Nuevo 2026" o "Carnaval Summer 2026"
    - receipt_filename (TEXT)
    - package_delivered (BOOLEAN)
    - tickets_picked_up (BOOLEAN)
    - created_at (TIMESTAMP)

Funcionalidades:
  ✅ Formularios por ciudad (Tarija, Santa Cruz, etc.)
  ✅ Formularios por evento (Año Nuevo, Carnaval)
  ✅ Upload de comprobantes de pago
  ✅ Dashboard administrativo con filtros
  ✅ Exportación a CSV
  ✅ Tracking de entregas
  ✅ Sistema de diseño completo
  ✅ Accesibilidad WCAG AA
```

#### Archivos Clave

```
summer-festival-sales/
├── api/index.js (256 líneas) - Backend Express
├── index.html - Formulario Año Nuevo general
├── tarija.html, santa-cruz.html, etc. - Formularios por ciudad
├── carnaval-2026.html - Formulario Carnaval general
├── carnaval-tarija.html, etc. - Carnaval por ciudad
├── public/dashboard.html - Admin dashboard
├── public/dashboard.css - Estilos dashboard
└── public/qr-*.jpg - QR codes de pago por ciudad
```

#### Endpoints API

```javascript
GET  /api/health         - Health check
GET  /api/sales          - Listar todas las ventas
GET  /api/stats          - Estadísticas (totalSales, totalTickets)
POST /api/sales          - Crear nueva venta (con upload de comprobante)
PATCH /api/sales/:id/delivery - Actualizar estado de entrega de paquete
PATCH /api/sales/:id/pickup   - Actualizar estado de retiro de tickets
```

---

### 2️⃣ Sistema: VENTAS INDIVIDUALES (ventas-individuales-summer)

**Estado:** ✅ En producción
**URL:** Ya desplegado en Vercel
**Base de Datos:** Supabase PostgreSQL (DIFERENTE instancia)

#### Características Actuales

```yaml
Tecnologías:
  Backend: Express.js + Node.js
  Frontend: HTML + Vanilla JavaScript
  Base de Datos: Supabase PostgreSQL
  Storage: Bucket "receipts" (público)
  Deploy: Vercel (serverless)

Tabla Principal: sales
  Campos:
    - id (BIGSERIAL)
    - team_leader (TEXT)
    - rrpp_name (TEXT)
    - ticket_quantity (INTEGER)
    - city (TEXT)
    - events (JSONB) ← ["26 dic - welcome", "27 dic - summer fest"]
    - receipt_filename (TEXT)
    - delivered (BOOLEAN)
    - created_at (TIMESTAMPTZ)

Funcionalidades:
  ✅ Selección MÚLTIPLE de eventos (checkboxes)
  ✅ Formularios por ciudad (sin selección de eventos)
  ✅ Upload de comprobantes de pago
  ✅ Dashboard administrativo con búsqueda
  ✅ Filtros por ciudad
  ✅ Exportación a CSV
  ✅ Tracking de entregas (checkbox)
  ✅ Sistema de diseño idéntico al de paquetes
  ✅ Dashboard monitor (actualización en vivo)
```

#### Diferencia Clave con Paquetes

```javascript
// VENTAS INDIVIDUALES: El cliente selecciona qué eventos quiere
events: [
  "26 dic - welcome",
  "27 dic - summer fest",
  "31 dic - new year"
]

// VENTAS PAQUETES: Un solo evento predefinido
event_name: "Año Nuevo 2026"  // Incluye TODOS los eventos implícitos
```

#### Archivos Clave

```
ventas-individuales-summer/
├── api/index.js (246 líneas) - Backend Express
├── index.html - Formulario con selección múltiple de eventos
├── tarija.html, santa-cruz.html, etc. - Formularios por ciudad
├── public/dashboard.html - Admin dashboard
├── dashboard-monitor.html - Monitor en vivo
├── DESIGN-REFERENCE.md - Guía de diseño (307 líneas)
├── UI-UX-DESIGN-GUIDE.md - Guía completa (359 líneas)
├── design-showcase.html - Componentes interactivos (565 líneas)
└── db/migrations/ - Migraciones SQL
```

#### Endpoints API

```javascript
GET  /api/health           - Health check
GET  /api/deploy-info      - Info de deployment Vercel
GET  /api/sales            - Listar todas las ventas
GET  /api/stats            - Estadísticas
POST /api/sales            - Crear nueva venta
PATCH /api/sales/:id/delivered - Actualizar estado de entrega
```

---

### 3️⃣ Sistema: GASTOS (gastos-summer)

**Estado:** ⚠️ En desarrollo (el menos avanzado)
**URL:** No desplegado aún
**Base de Datos:** Supabase PostgreSQL

#### Características Actuales

```yaml
Tecnologías:
  Frontend: Vite + React 18.3.1
  Backend: No tiene (usa Supabase directamente)
  Base de Datos: Supabase PostgreSQL
  Storage: Bucket "expense-receipts"
  Deploy: Vercel (configurado pero no usado)
  UI: Tailwind CSS + shadcn/ui

Tabla Principal: expenses
  Campos (según SQL migrations):
    - id (UUID)
    - event_name (TEXT)
    - category (TEXT)
    - description (TEXT)
    - amount (DECIMAL)
    - receipt_url (TEXT)
    - created_at (TIMESTAMP)
    - updated_at (TIMESTAMP)

Estado del Código:
  ⚠️ Estructura básica creada
  ⚠️ No tiene formularios completos
  ⚠️ No tiene dashboard
  ⚠️ SQL migrations básicas
  ⚠️ README con instrucciones de setup
```

#### Archivos Clave

```
gastos-summer/
├── src/
│   ├── App.tsx (muy básico)
│   ├── main.tsx
│   └── components/ (vacío o mínimo)
├── supabase-migration.sql (tabla expenses básica)
├── supabase-setup.sql
├── storage-policies.sql
├── package.json (Vite + React + Supabase)
└── vite.config.js
```

#### Conclusión

**Este sistema necesita desarrollo desde cero**. Solo tiene:
- ✅ Estructura de proyecto Vite+React
- ✅ Configuración básica de Supabase
- ✅ Tabla `expenses` en SQL
- ❌ No tiene interfaz completa
- ❌ No tiene lógica de negocio

**Recomendación:** Construir desde cero usando el mismo stack de los otros (Express + HTML) para mantener consistencia.

---

### 4️⃣ Sistema: CALCULADORA (calculadora-summer)

**Estado:** ⚠️ En desarrollo
**URL:** No desplegado (Firebase Hosting configurado)
**Base de Datos:** Firebase Firestore

#### Características Actuales

```yaml
Tecnologías:
  Framework: Next.js 15.1.3 + TypeScript
  UI: shadcn/ui + Tailwind CSS + Radix UI
  Base de Datos: Firebase Firestore
  Deploy: Firebase Hosting (App Hosting)
  Backend: Firebase Functions (integrado)

Funcionalidades Planeadas (según docs):
  - Cálculo de costos por evento
  - Proyección de ingresos
  - Punto de equilibrio
  - Márgenes de ganancia
  - Escenarios (pesimista, realista, optimista)
  - Dashboard de análisis

Estado del Código:
  ⚠️ Estructura Next.js creada
  ⚠️ Configuración Firebase completa
  ⚠️ UI components de shadcn instalados
  ⚠️ No tiene lógica de cálculo implementada
  ⚠️ No tiene formularios de entrada
```

#### Archivos Clave

```
calculadora-summer/
├── src/
│   ├── app/ (Next.js App Router)
│   ├── components/ (shadcn/ui components)
│   └── lib/ (utilidades)
├── docs/ (documentación vacía)
├── firebase.json
├── firestore.rules
├── apphosting.yaml
├── next.config.ts
└── package.json (Next.js + Firebase + shadcn)
```

#### Problema: Stack Diferente

Este sistema usa **Firebase** mientras los demás usan **Supabase**.

**Opciones:**
1. ✅ **Migrar a Supabase** (mantener consistencia)
2. ❌ Mantener Firebase (2 bases de datos diferentes)

**Recomendación:** Migrar a Supabase y usar Express + HTML como los demás.

---

## 🎯 PLAN DE UNIFICACIÓN

### Estrategia: Migración Progresiva

```
┌─────────────────────────────────────────────────────────────┐
│                  FASE 0: PREPARACIÓN                        │
│  Base: summer-festival-sales (el más completo)              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│     FASE 1: INTEGRAR VENTAS INDIVIDUALES (3-4 días)        │
│  Unificar ambos sistemas de ventas en uno solo             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│     FASE 2: CONSTRUIR MÓDULO DE GASTOS (4-5 días)          │
│  Crear desde cero usando mismo stack                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│     FASE 3: CONSTRUIR CALCULADORA (3-4 días)               │
│  Migrar de Firebase a Supabase, crear interfaz             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│     FASE 4: DASHBOARD UNIFICADO (2-3 días)                 │
│  Dashboard principal con navegación entre módulos          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 FASE 0: PREPARACIÓN (1 día)

### Objetivo
Preparar el repositorio `summer-festival-sales` para recibir los otros sistemas.

### Tareas

#### 1. Reestructurar el Proyecto

```bash
# Nueva estructura de carpetas
summer-festival-sales/
├── api/
│   ├── sales.js           ← Mover lógica de ventas aquí
│   ├── expenses.js        ← Nuevo (Fase 2)
│   ├── calculations.js    ← Nuevo (Fase 3)
│   └── index.js           ← Router principal
│
├── public/
│   ├── main.html          ← Dashboard principal (nuevo)
│   │
│   ├── ventas/            ← Módulo de ventas
│   │   ├── paquetes/
│   │   │   ├── index.html
│   │   │   ├── tarija.html
│   │   │   └── ...
│   │   ├── individuales/
│   │   │   ├── index.html
│   │   │   ├── tarija.html
│   │   │   └── ...
│   │   └── dashboard.html ← Dashboard unificado de ventas
│   │
│   ├── gastos/            ← Módulo de gastos (Fase 2)
│   │   ├── index.html
│   │   └── dashboard.html
│   │
│   ├── calculadora/       ← Módulo de calculadora (Fase 3)
│   │   ├── index.html
│   │   └── dashboard.html
│   │
│   └── shared/            ← Recursos compartidos
│       ├── css/
│       │   ├── variables.css
│       │   ├── components.css
│       │   └── dashboard.css
│       ├── js/
│       │   ├── api-client.js
│       │   ├── utils.js
│       │   └── components.js
│       └── images/
│           ├── qr-codes/
│           └── logos/
│
├── db/
│   └── migrations/
│       ├── 001_events.sql
│       ├── 002_packages.sql
│       ├── 003_sales_unified.sql
│       ├── 004_expenses.sql
│       └── 005_calculations.sql
│
├── docs/
│   ├── DESIGN-SYSTEM.md
│   ├── API-REFERENCE.md
│   └── USER-MANUAL.md
│
└── package.json
```

#### 2. Crear Base de Datos Unificada

**Archivo:** `db/migrations/001_unified_schema.sql`

```sql
-- ============================================================================
-- ESQUEMA UNIFICADO - SUMMER FESTIVAL
-- ============================================================================

-- Tabla: events (Eventos individuales)
CREATE TABLE events (
  id SERIAL PRIMARY KEY,
  event_name VARCHAR(200) NOT NULL,
  event_slug VARCHAR(200) UNIQUE NOT NULL,
  event_date DATE NOT NULL,
  city VARCHAR(100),
  venue_name VARCHAR(200),
  capacity INTEGER,
  ticket_price DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'planificacion',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla: packages (Paquetes de eventos)
CREATE TABLE packages (
  id SERIAL PRIMARY KEY,
  package_name VARCHAR(200) NOT NULL,
  package_slug VARCHAR(200) UNIQUE NOT NULL,
  package_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2),
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla: package_events (Eventos incluidos en cada paquete)
CREATE TABLE package_events (
  package_id INTEGER REFERENCES packages(id) ON DELETE CASCADE,
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
  PRIMARY KEY (package_id, event_id)
);

-- Tabla: sales (Ventas unificadas)
CREATE TABLE sales (
  id SERIAL PRIMARY KEY,

  -- Tipo de venta
  sale_type VARCHAR(50) NOT NULL CHECK (sale_type IN ('package', 'individual')),
  package_id INTEGER REFERENCES packages(id),

  -- Información del cliente
  customer_name VARCHAR(200) NOT NULL,
  customer_phone VARCHAR(50),
  customer_email VARCHAR(200),

  -- Información de venta
  ticket_quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,

  -- Vendedor
  team_leader VARCHAR(200),
  rrpp_name VARCHAR(200),

  -- Pago
  payment_method VARCHAR(50) DEFAULT 'transferencia',
  payment_status VARCHAR(50) DEFAULT 'pendiente',
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  -- Entrega
  tickets_delivered BOOLEAN DEFAULT FALSE,
  delivery_date TIMESTAMP,

  -- Metadata
  city VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla: sale_events (Eventos en ventas individuales)
CREATE TABLE sale_events (
  sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
  PRIMARY KEY (sale_id, event_id)
);

-- Tabla: expense_categories
CREATE TABLE expense_categories (
  id SERIAL PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  category_slug VARCHAR(100) NOT NULL UNIQUE,
  icon VARCHAR(50),
  sort_order INTEGER DEFAULT 0
);

-- Tabla: expense_subcategories
CREATE TABLE expense_subcategories (
  id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES expense_categories(id),
  subcategory_name VARCHAR(100) NOT NULL,
  subcategory_slug VARCHAR(100) NOT NULL,
  UNIQUE(category_id, subcategory_slug)
);

-- Tabla: expenses
CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,
  event_id INTEGER REFERENCES events(id),
  category_id INTEGER NOT NULL REFERENCES expense_categories(id),
  subcategory_id INTEGER NOT NULL REFERENCES expense_subcategories(id),

  description TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10,2),

  vendor_name VARCHAR(200),
  invoice_number VARCHAR(100),
  receipt_filename VARCHAR(500),
  receipt_url TEXT,

  status VARCHAR(50) DEFAULT 'pendiente',
  payment_date DATE,

  expense_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla: event_calculations
CREATE TABLE event_calculations (
  id SERIAL PRIMARY KEY,
  event_id INTEGER REFERENCES events(id),

  calculation_name VARCHAR(200) NOT NULL,

  -- Capacidad y precios
  total_capacity INTEGER,
  expected_attendance INTEGER,
  ticket_price_general DECIMAL(10,2),
  ticket_price_vip DECIMAL(10,2),

  -- Costos
  venue_cost DECIMAL(10,2),
  production_cost DECIMAL(10,2),
  marketing_cost DECIMAL(10,2),
  staff_cost DECIMAL(10,2),
  other_costs DECIMAL(10,2),
  total_costs DECIMAL(10,2),

  -- Proyecciones
  projected_revenue DECIMAL(10,2),
  projected_profit DECIMAL(10,2),
  break_even_tickets INTEGER,
  profit_margin DECIMAL(5,2),

  scenario_type VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_sales_sale_type ON sales(sale_type);
CREATE INDEX idx_sales_created_at ON sales(created_at DESC);
CREATE INDEX idx_expenses_event ON expenses(event_id);
CREATE INDEX idx_expenses_category ON expenses(category_id);
```

#### 3. Migrar Datos Existentes

**Script:** `db/migrations/002_migrate_existing_data.sql`

```sql
-- Migrar datos de summer-festival-sales (tabla sales actual)
-- Asumiendo que la tabla vieja se renombró a sales_old

-- 1. Crear eventos desde datos existentes
INSERT INTO events (event_name, event_slug, event_date, ticket_price, status)
SELECT DISTINCT
  event_name,
  LOWER(REPLACE(event_name, ' ', '-')),
  CASE
    WHEN event_name LIKE '%Año Nuevo%' THEN '2025-12-31'::DATE
    WHEN event_name LIKE '%Carnaval%' THEN '2026-02-15'::DATE
    ELSE CURRENT_DATE
  END,
  200.00,
  'finalizado'
FROM sales_old
WHERE event_name IS NOT NULL
ON CONFLICT DO NOTHING;

-- 2. Migrar ventas como tipo 'package'
INSERT INTO sales (
  sale_type,
  customer_name,
  ticket_quantity,
  unit_price,
  total_amount,
  team_leader,
  rrpp_name,
  payment_method,
  payment_status,
  receipt_filename,
  tickets_delivered,
  city,
  created_at
)
SELECT
  'package',
  team_leader,
  ticket_quantity,
  200.00,
  ticket_quantity * 200.00,
  team_leader,
  rrpp_name,
  'transferencia',
  'pagado',
  receipt_filename,
  COALESCE(package_delivered, false),
  city,
  created_at
FROM sales_old;
```

---

## 📋 FASE 1: INTEGRAR VENTAS INDIVIDUALES (3-4 días)

### Objetivo
Unificar los 2 sistemas de ventas en un solo módulo con 2 áreas.

### Día 1: Preparar Estructura

#### Tarea 1.1: Copiar Archivos

```bash
# Copiar formularios de ventas individuales
cp -r /tmp/repos-analysis/ventas-individuales-summer/*.html \
      summer-festival-sales/public/ventas/individuales/

# Copiar sistema de diseño
cp /tmp/repos-analysis/ventas-individuales-summer/DESIGN-REFERENCE.md \
   summer-festival-sales/docs/

# Copiar dashboard
cp /tmp/repos-analysis/ventas-individuales-summer/public/dashboard.html \
   summer-festival-sales/public/ventas/dashboard-individuales.html
```

#### Tarea 1.2: Adaptar API

**Archivo:** `api/sales.js`

```javascript
const express = require('express');
const router = express.Router();
const multer = require('multer');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 4 * 1024 * 1024 }
});

// GET /api/sales - Listar ventas (ambos tipos)
router.get('/', async (req, res) => {
  try {
    const { sale_type, city } = req.query;

    let query = supabase.from('sales').select('*');

    if (sale_type) query = query.eq('sale_type', sale_type);
    if (city) query = query.eq('city', city);

    const { data, error } = await query.order('created_at', { ascending: false });

    if (error) throw error;

    // Agregar URLs de recibos
    const salesWithUrls = data.map(sale => ({
      ...sale,
      receipt_url: sale.receipt_filename
        ? supabase.storage.from('receipts').getPublicUrl(sale.receipt_filename).data.publicUrl
        : null
    }));

    res.json(salesWithUrls);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/sales/package - Crear venta de paquete
router.post('/package', upload.single('receipt'), async (req, res) => {
  try {
    const { team_leader, rrpp_name, ticket_quantity, package_id, city } = req.body;

    // Validar
    if (!team_leader || !rrpp_name || !ticket_quantity || !package_id) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }

    // Obtener precio del paquete
    const { data: pkg } = await supabase
      .from('packages')
      .select('package_price')
      .eq('id', package_id)
      .single();

    if (!pkg) {
      return res.status(404).json({ error: 'Paquete no encontrado' });
    }

    // Upload de recibo
    let receipt_filename = null;
    if (req.file) {
      receipt_filename = `${Date.now()}-${req.file.originalname}`;
      await supabase.storage
        .from('receipts')
        .upload(receipt_filename, req.file.buffer, {
          contentType: req.file.mimetype
        });
    }

    // Crear venta
    const { data, error } = await supabase
      .from('sales')
      .insert([{
        sale_type: 'package',
        package_id: parseInt(package_id),
        customer_name: team_leader,
        ticket_quantity: parseInt(ticket_quantity),
        unit_price: pkg.package_price,
        total_amount: pkg.package_price * parseInt(ticket_quantity),
        team_leader,
        rrpp_name,
        city,
        receipt_filename,
        payment_status: 'pendiente'
      }])
      .select()
      .single();

    if (error) throw error;

    res.json({ success: true, sale: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/sales/individual - Crear venta individual
router.post('/individual', upload.single('receipt'), async (req, res) => {
  try {
    const { customer_name, customer_phone, ticket_quantity, event_ids, city, rrpp_name } = req.body;

    // Validar
    if (!customer_name || !ticket_quantity || !event_ids) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }

    // Parsear event_ids
    const eventIdsArray = typeof event_ids === 'string'
      ? JSON.parse(event_ids)
      : event_ids;

    // Calcular precio total
    const { data: events } = await supabase
      .from('events')
      .select('ticket_price')
      .in('id', eventIdsArray);

    const totalPrice = events.reduce((sum, e) => sum + parseFloat(e.ticket_price), 0);

    // Upload de recibo
    let receipt_filename = null;
    if (req.file) {
      receipt_filename = `${Date.now()}-${req.file.originalname}`;
      await supabase.storage
        .from('receipts')
        .upload(receipt_filename, req.file.buffer, {
          contentType: req.file.mimetype
        });
    }

    // Crear venta
    const { data: sale, error: saleError } = await supabase
      .from('sales')
      .insert([{
        sale_type: 'individual',
        customer_name,
        customer_phone,
        ticket_quantity: parseInt(ticket_quantity),
        unit_price: totalPrice / eventIdsArray.length,
        total_amount: totalPrice * parseInt(ticket_quantity),
        rrpp_name,
        city,
        receipt_filename,
        payment_status: 'pendiente'
      }])
      .select()
      .single();

    if (saleError) throw saleError;

    // Crear relaciones sale_events
    const saleEvents = eventIdsArray.map(eventId => ({
      sale_id: sale.id,
      event_id: parseInt(eventId)
    }));

    const { error: relError } = await supabase
      .from('sale_events')
      .insert(saleEvents);

    if (relError) throw relError;

    res.json({ success: true, sale });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### Día 2: Dashboard Unificado de Ventas

**Archivo:** `public/ventas/dashboard.html`

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Ventas - Summer Festival</title>
    <link rel="stylesheet" href="/shared/css/dashboard.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>💰 Gestión de Ventas</h1>
            <nav>
                <a href="/main.html">← Dashboard Principal</a>
            </nav>
        </header>

        <!-- Tabs -->
        <div class="tabs">
            <button class="tab active" data-type="all">Todas</button>
            <button class="tab" data-type="package">🎁 Paquetes</button>
            <button class="tab" data-type="individual">🎫 Individuales</button>
        </div>

        <!-- Stats -->
        <div class="stats">
            <div class="stat-card">
                <h3 id="totalSales">0</h3>
                <p>Total Ventas</p>
            </div>
            <div class="stat-card">
                <h3 id="packageSales">0</h3>
                <p>Ventas Paquetes</p>
            </div>
            <div class="stat-card">
                <h3 id="individualSales">0</h3>
                <p>Ventas Individuales</p>
            </div>
            <div class="stat-card">
                <h3 id="totalTickets">0</h3>
                <p>Total Tickets</p>
            </div>
        </div>

        <!-- Filtros -->
        <div class="filters">
            <input type="search" id="search" placeholder="🔍 Buscar...">
            <select id="cityFilter">
                <option value="">Todas las ciudades</option>
            </select>
        </div>

        <!-- Tabla -->
        <div class="table-card">
            <table id="salesTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tipo</th>
                        <th>Cliente</th>
                        <th>RRPP</th>
                        <th>Ciudad</th>
                        <th>Tickets</th>
                        <th>Total</th>
                        <th>Estado</th>
                        <th>Fecha</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

        <button id="exportBtn">📥 Exportar CSV</button>
    </div>

    <script src="/shared/js/api-client.js"></script>
    <script>
        const api = new APIClient();
        let allSales = [];

        async function loadSales() {
            try {
                allSales = await api.get('/sales');
                renderSales(allSales);
                updateStats(allSales);
            } catch (error) {
                console.error('Error:', error);
            }
        }

        function renderSales(sales) {
            const tbody = document.querySelector('#salesTable tbody');
            tbody.innerHTML = sales.map(sale => `
                <tr>
                    <td>${sale.id}</td>
                    <td>${sale.sale_type === 'package' ? '🎁 Paquete' : '🎫 Individual'}</td>
                    <td>${sale.customer_name}</td>
                    <td>${sale.rrpp_name || '-'}</td>
                    <td>${sale.city || 'General'}</td>
                    <td>${sale.ticket_quantity}</td>
                    <td>Bs. ${sale.total_amount.toFixed(2)}</td>
                    <td>${sale.payment_status}</td>
                    <td>${new Date(sale.created_at).toLocaleDateString()}</td>
                </tr>
            `).join('');
        }

        function updateStats(sales) {
            document.getElementById('totalSales').textContent = sales.length;
            document.getElementById('packageSales').textContent =
                sales.filter(s => s.sale_type === 'package').length;
            document.getElementById('individualSales').textContent =
                sales.filter(s => s.sale_type === 'individual').length;
            document.getElementById('totalTickets').textContent =
                sales.reduce((sum, s) => sum + s.ticket_quantity, 0);
        }

        // Tabs
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => {
                document.querySelector('.tab.active').classList.remove('active');
                tab.classList.add('active');

                const type = tab.dataset.type;
                const filtered = type === 'all'
                    ? allSales
                    : allSales.filter(s => s.sale_type === type);

                renderSales(filtered);
            });
        });

        // Inicializar
        loadSales();
    </script>
</body>
</html>
```

### Día 3-4: Testing y Ajustes

- ✅ Probar formularios de paquetes
- ✅ Probar formularios individuales
- ✅ Verificar dashboard unificado
- ✅ Exportación CSV
- ✅ Responsive design

---

## 📋 FASE 2: CONSTRUIR MÓDULO DE GASTOS (4-5 días)

### Objetivo
Crear módulo de gastos desde cero usando el mismo stack (Express + HTML).

### Día 1: Estructura y Base de Datos

Ya tenemos la estructura de BD del plan v2.0:
- ✅ Tabla `expense_categories` (13 categorías)
- ✅ Tabla `expense_subcategories` (40+ subcategorías)
- ✅ Tabla `expenses`

### Día 2-3: Formulario y API

**Archivo:** `public/gastos/index.html`

```html
<!-- Formulario similar a ventas -->
<form id="expenseForm">
    <select id="eventId">
        <option value="">Gasto General (no específico de evento)</option>
        <!-- Cargado dinámicamente desde API -->
    </select>

    <select id="categoryId" required>
        <option value="">Selecciona categoría</option>
    </select>

    <select id="subcategoryId" required>
        <option value="">Selecciona subcategoría</option>
    </select>

    <textarea id="description" required></textarea>

    <input type="number" id="quantity" value="1">
    <input type="number" id="unitPrice" step="0.01" required>
    <div class="total">Total: Bs. <span id="totalAmount">0.00</span></div>

    <input type="text" id="vendorName">
    <input type="text" id="invoiceNumber">

    <input type="file" id="receipt" accept="image/*,.pdf">

    <button type="submit">💾 Registrar Gasto</button>
</form>
```

**API:** `api/expenses.js`

```javascript
// Similar a sales.js
// POST /api/expenses - Crear gasto
// GET /api/expenses - Listar gastos
// PATCH /api/expenses/:id/approve - Aprobar gasto
```

### Día 4-5: Dashboard de Gastos

- ✅ Tabla con filtros por categoría
- ✅ Reporte por subcategoría
- ✅ Gráfico de distribución (opcional)
- ✅ Exportación CSV

---

## 📋 FASE 3: CONSTRUIR CALCULADORA (3-4 días)

### Día 1: Migrar de Firebase a Supabase

- ✅ Eliminar Firebase
- ✅ Usar tabla `event_calculations`
- ✅ Crear formulario HTML simple

### Día 2-3: Lógica de Cálculo

**Archivo:** `public/calculadora/index.html`

```javascript
function calculateProjection(data) {
    const {
        capacity,
        attendance_percent,
        ticket_price_general,
        ticket_price_vip,
        distribution,  // { general: 0.6, vip: 0.4 }
        costs
    } = data;

    const attendance = capacity * (attendance_percent / 100);

    // Tickets por tipo
    const tickets = {
        general: Math.round(attendance * distribution.general),
        vip: Math.round(attendance * distribution.vip)
    };

    // Ingresos
    const revenue = {
        general: tickets.general * ticket_price_general,
        vip: tickets.vip * ticket_price_vip,
        total: 0
    };
    revenue.total = revenue.general + revenue.vip;

    // Costos
    const totalCosts = Object.values(costs).reduce((sum, cost) => sum + cost, 0);

    // Análisis
    const profit = revenue.total - totalCosts;
    const margin = (profit / revenue.total) * 100;

    // Punto de equilibrio
    const avgPrice = revenue.total / (tickets.general + tickets.vip);
    const breakEven = Math.ceil(totalCosts / avgPrice);

    return {
        tickets,
        revenue,
        costs: totalCosts,
        profit,
        margin,
        breakEven
    };
}
```

### Día 4: Dashboard y Guardado

- ✅ Guardar cálculos en BD
- ✅ Listar cálculos históricos
- ✅ Comparar escenarios

---

## 📋 FASE 4: DASHBOARD UNIFICADO (2-3 días)

### Dashboard Principal

**Archivo:** `public/main.html`

```html
<header>
    <h1>🎉 SUMMER EVENTS</h1>
    <p>Sistema Integral de Gestión de Eventos</p>
</header>

<!-- Módulos -->
<div class="modules">
    <a href="/ventas/dashboard.html" class="module-card">
        <div class="icon">💰</div>
        <h3>Ventas</h3>
        <p>Paquetes e individuales</p>
    </a>

    <a href="/gastos/dashboard.html" class="module-card">
        <div class="icon">💸</div>
        <h3>Gastos</h3>
        <p>Control de costos</p>
    </a>

    <a href="/calculadora/index.html" class="module-card">
        <div class="icon">🧮</div>
        <h3>Calculadora</h3>
        <p>Proyecciones financieras</p>
    </a>
</div>

<!-- Resumen General -->
<div class="financial-summary">
    <h2>📊 Resumen Financiero</h2>
    <div class="stats">
        <div class="stat">
            <h3 id="totalRevenue">Bs. 0</h3>
            <p>Ingresos Totales</p>
        </div>
        <div class="stat">
            <h3 id="totalExpenses">Bs. 0</h3>
            <p>Gastos Totales</p>
        </div>
        <div class="stat">
            <h3 id="netProfit">Bs. 0</h3>
            <p>Utilidad Neta</p>
        </div>
    </div>
</div>
```

---

## 🗓️ CRONOGRAMA COMPLETO

```
SEMANA 1:
├─ Día 1: Preparación (Fase 0)
├─ Día 2-4: Integrar Ventas Individuales (Fase 1)
└─ Día 5: Testing

SEMANA 2:
├─ Día 6-10: Construir Módulo de Gastos (Fase 2)
└─ Testing continuo

SEMANA 3:
├─ Día 11-14: Construir Calculadora (Fase 3)
└─ Día 15-16: Dashboard Unificado (Fase 4)

SEMANA 4:
├─ Día 17-18: Testing integral
├─ Día 19: Deploy a producción
└─ Día 20: Documentación y capacitación
```

**TOTAL:** 20 días laborales (4 semanas)

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Fase 0: Preparación
- [ ] Reestructurar carpetas del proyecto
- [ ] Crear esquema unificado en Supabase
- [ ] Migrar datos existentes
- [ ] Configurar variables de entorno
- [ ] Actualizar vercel.json

### Fase 1: Ventas
- [ ] Copiar archivos de ventas individuales
- [ ] Adaptar API para ambos tipos de venta
- [ ] Crear dashboard unificado de ventas
- [ ] Probar formularios de paquetes
- [ ] Probar formularios individuales
- [ ] Testing de integración

### Fase 2: Gastos
- [ ] Crear formulario de registro de gastos
- [ ] Implementar API de gastos
- [ ] Crear dashboard de gastos
- [ ] Implementar sistema de aprobaciones
- [ ] Reportes por categoría
- [ ] Testing

### Fase 3: Calculadora
- [ ] Migrar de Firebase a Supabase
- [ ] Crear formulario de cálculo
- [ ] Implementar lógica de proyecciones
- [ ] Dashboard de cálculos históricos
- [ ] Comparación de escenarios
- [ ] Testing

### Fase 4: Unificación
- [ ] Crear dashboard principal
- [ ] Navegación entre módulos
- [ ] Resumen financiero general
- [ ] Reportes consolidados
- [ ] Testing integral
- [ ] Deploy a producción

---

## 🚀 CONCLUSIÓN

Este plan maestro proporciona:

1. ✅ **Análisis completo** de los 4 sistemas existentes
2. ✅ **Arquitectura unificada** con Supabase
3. ✅ **Plan de migración** fase por fase
4. ✅ **Cronograma realista** de 4 semanas
5. ✅ **Reutilización** del 85% del código existente
6. ✅ **Stack consistente** (Express + HTML + Supabase)

### Próximos Pasos

1. **Revisar** este plan y hacer ajustes
2. **Ejecutar** Fase 0 (Preparación)
3. **Comenzar** Fase 1 (Ventas)
4. **Iterar** con testing continuo

**¿Listo para comenzar?** 🎉
