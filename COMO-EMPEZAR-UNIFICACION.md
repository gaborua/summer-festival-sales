# 🚀 Cómo Empezar con la Unificación

Esta guía te ayudará a comenzar la implementación del sistema unificado paso a paso.

---

## 📁 Archivos Creados

Se han generado los siguientes documentos de planificación:

1. **`PLAN-UNIFICACION-DETALLADO.md`** - Plan completo con mockups, arquitectura y cronograma
2. **`database-migration.sql`** - Script SQL para crear todas las tablas necesarias
3. **`dashboard-main-preview.html`** - Vista previa del dashboard principal unificado
4. **Este archivo** - Guía de inicio rápido

---

## ✅ Paso 1: Revisar el Plan Detallado

Antes de comenzar, revisa el archivo **`PLAN-UNIFICACION-DETALLADO.md`** que contiene:

- ✅ Mockups en ASCII de todos los módulos
- ✅ Esquema completo de base de datos
- ✅ Plan de implementación en 4 fases (10-14 días)
- ✅ Diagramas de flujo
- ✅ Recomendaciones técnicas
- ✅ Checklist final

```bash
# Abrir el plan detallado
cat PLAN-UNIFICACION-DETALLADO.md
# o
code PLAN-UNIFICACION-DETALLADO.md
```

---

## 🗄️ Paso 2: Configurar la Base de Datos

### 2.1 Ejecutar el Script SQL

1. Abre tu proyecto en **Supabase Dashboard**
2. Ve a **SQL Editor**
3. Copia y pega el contenido de `database-migration.sql`
4. Ejecuta el script completo

```bash
# Ver el script
cat database-migration.sql
```

El script creará:
- ✅ Tabla `events` (central del sistema)
- ✅ Modificaciones a `sales` (agregar `event_id`)
- ✅ Tabla `individual_sales` (nuevo módulo)
- ✅ Tabla `expenses` (nuevo módulo)
- ✅ Tabla `event_calculations` (nuevo módulo)
- ✅ 5 vistas para reportes
- ✅ Funciones útiles
- ✅ Triggers para `updated_at`

### 2.2 Verificar la Migración

Después de ejecutar el script, verifica que todo se creó correctamente:

```sql
-- En Supabase SQL Editor
SELECT * FROM events;
SELECT COUNT(*) FROM sales WHERE event_id IS NOT NULL;
```

---

## 📂 Paso 3: Preparar tu Entorno Local

### 3.1 Antes de Empezar

Prepara los otros 3 sistemas que quieres integrar:

1. **Sistema de Registro de Gastos**
   - Anota qué campos tiene
   - Exporta datos existentes si los hay
   - Ten listo el código fuente

2. **Calculadora de Eventos**
   - Documenta qué cálculos realiza
   - Lista las fórmulas que usa
   - Ten listo el código fuente

3. **Registro de Ventas Individuales**
   - Lista los campos del formulario
   - Exporta datos existentes si los hay
   - Ten listo el código fuente

### 3.2 Respaldar el Sistema Actual

**IMPORTANTE:** Antes de modificar cualquier cosa, haz un backup completo:

```bash
# En tu proyecto actual
git add .
git commit -m "backup: estado antes de unificación"
git push

# Exportar datos de Supabase (opcional pero recomendado)
# Ve a Supabase Dashboard > Database > Backups
```

---

## 🏗️ Paso 4: Elegir tu Estrategia de Implementación

Tienes 3 opciones:

### Opción A: Implementación Completa (Recomendado)
**Tiempo:** 10-14 días
**Mejor para:** Quieres hacerlo bien desde el principio

Sigue el plan de 4 fases del documento detallado:
1. Preparación (2-3 días)
2. Integración de módulos (4-5 días)
3. Unificación y reportes (3-4 días)
4. Testing y deploy (1-2 días)

### Opción B: Migración Progresiva
**Tiempo:** 3-4 semanas
**Mejor para:** No puedes parar el sistema actual

1. Semana 1: Crear infraestructura base (tablas, dashboard principal)
2. Semana 2: Migrar primer módulo (ventas individuales)
3. Semana 3: Migrar segundo módulo (gastos)
4. Semana 4: Migrar tercer módulo (calculadora) + testing

Durante este tiempo, ambos sistemas conviven.

### Opción C: Piloto con un Solo Módulo
**Tiempo:** 3-5 días
**Mejor para:** Quieres probar primero con algo pequeño

1. Crear solo la tabla `individual_sales`
2. Implementar solo ese módulo
3. Probarlo en producción
4. Si funciona bien, migrar los demás módulos

---

## 🎯 Paso 5: Empezar con la Fase 1 (Preparación)

Si elegiste la **Opción A** (recomendado), empieza con:

### Día 1: Reestructurar el Proyecto

```bash
# Crear nueva estructura de carpetas
mkdir -p public/dashboard public/forms/sales public/forms/individual
mkdir -p api shared/css shared/js

# Mover archivos existentes
mv public/dashboard.html public/dashboard/sales-teams.html
mv public/dashboard.css shared/css/dashboard.css

# Mover formularios
mv index.html public/forms/sales/
mv tarija.html public/forms/sales/
mv santa-cruz.html public/forms/sales/
# ... y así con todos los formularios de ciudades

# Copiar el dashboard principal preview
cp dashboard-main-preview.html public/dashboard/main.html

# Commit
git add .
git commit -m "refactor: reorganize project structure for unified system"
git push
```

### Día 2: Actualizar Referencias

Después de mover los archivos, actualiza las referencias:

1. En `vercel.json`:
```json
{
  "rewrites": [
    { "source": "/", "destination": "/public/dashboard/main.html" },
    { "source": "/dashboard", "destination": "/public/dashboard/main.html" },
    { "source": "/api/(.*)", "destination": "/api/index.js" }
  ]
}
```

2. En los formularios HTML, actualizar rutas de API:
```javascript
// Antes
fetch('/api/sales')

// Después (si moviste los archivos)
fetch('/api/sales')  // Mismo, Vercel maneja el routing
```

### Día 3: Crear API de Eventos

Crear el archivo `api/events.js`:

```javascript
const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// GET /api/events - Listar eventos
router.get('/', async (req, res) => {
  try {
    const { status } = req.query;

    let query = supabase.from('events').select('*');

    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query.order('event_date', { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

Actualizar `api/index.js` para incluir el nuevo router:

```javascript
const express = require('express');
const cors = require('cors');
const eventsRouter = require('./events');

const app = express();

app.use(cors());
app.use(express.json());

// Rutas existentes
// ... (tu código actual)

// Nueva ruta de eventos
app.use('/api/events', eventsRouter);

module.exports = app;
```

---

## 📊 Paso 6: Visualizar el Dashboard Principal

Puedes ver cómo se verá el dashboard principal abriendo:

```bash
# Abrir en navegador
open dashboard-main-preview.html
# o
xdg-open dashboard-main-preview.html
```

Esto te dará una idea visual de cómo quedará el sistema unificado.

---

## 🤔 Preguntas Frecuentes

### ¿Puedo hacer esto sin detener el sistema actual?

**Sí.** Usa la **Opción B** (Migración Progresiva). Las nuevas tablas no afectan las existentes.

### ¿Necesito modificar el código de los otros 3 sistemas?

**Sí, pero solo para adaptar las APIs.** La estructura de base de datos ya está diseñada para recibirlos.

### ¿Qué pasa con los datos existentes?

El script SQL incluye una migración que:
- Crea la tabla `events` con tus eventos actuales
- Agrega `event_id` a la tabla `sales` existente
- Migra los datos automáticamente basándose en `event_name`

### ¿Puedo probar primero en desarrollo?

**¡Absolutamente!** Crea un proyecto nuevo en Supabase para desarrollo:
1. Duplica tu proyecto en Supabase (gratuito)
2. Ejecuta el script SQL allí
3. Prueba todo
4. Cuando esté listo, replica en producción

### ¿Qué hago si algo sale mal?

1. Restaura desde el backup de git:
   ```bash
   git reset --hard HEAD~1
   ```

2. Restaura la base de datos desde Supabase:
   - Dashboard > Database > Backups > Restore

---

## 📞 Próximos Pasos Sugeridos

Una vez que hayas revisado todo:

1. **Decide qué opción elegir** (A, B o C)
2. **Prepara tus otros 3 sistemas** (código + datos)
3. **Ejecuta el script SQL** en Supabase
4. **Comienza la Fase 1** del plan

**¿Necesitas ayuda con algún paso específico?**

Puedo ayudarte con:
- ✅ Implementar un módulo específico
- ✅ Adaptar el código de tus otros sistemas
- ✅ Crear las APIs faltantes
- ✅ Configurar el despliegue en Vercel
- ✅ Resolver problemas específicos

---

## 📚 Recursos Adicionales

- **Plan Completo:** `PLAN-UNIFICACION-DETALLADO.md`
- **Script SQL:** `database-migration.sql`
- **Preview Dashboard:** `dashboard-main-preview.html`
- **Documentación Supabase:** https://supabase.com/docs
- **Documentación Vercel:** https://vercel.com/docs

---

**¡Listo para empezar! 🚀**

Avísame cuando estés listo para comenzar con la implementación o si necesitas aclarar algo del plan.
