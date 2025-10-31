# Summer Festival Sales

Sistema de registro de ventas de tickets para festivales.

## 🎨 Nuevo: Sistema de Diseño UI/UX

Este proyecto ahora incluye un **sistema completo de diseño UI/UX** con:

- 📚 **[Guía de Diseño Completa](UI-UX-DESIGN-GUIDE.md)** - Documentación exhaustiva del sistema de diseño
- 🎨 **[Showcase Interactivo](design-showcase.html)** - Biblioteca de componentes en vivo
- 📋 **[Referencia Rápida](DESIGN-REFERENCE.md)** - Cheat sheet para desarrolladores
- 📖 **[Resumen de Implementación](IMPLEMENTATION-SUMMARY.md)** - Guía de cambios realizados

### Recursos de Diseño

| Recurso | Descripción | Audiencia |
|---------|-------------|-----------|
| UI-UX-DESIGN-GUIDE.md | Sistema de diseño completo | Diseñadores, PMs |
| design-showcase.html | Componentes interactivos | Todos |
| DESIGN-REFERENCE.md | Código y snippets | Desarrolladores |
| IMPLEMENTATION-SUMMARY.md | Overview de cambios | Todos |

## Estructura

- `index.html` - Formulario de registro (mejorado con accesibilidad)
- `dashboard.html` - Panel de administración (con búsqueda y filtros)
- `design-showcase.html` - 🆕 Showcase del sistema de diseño
- `api/index.js` - API endpoints
- Ciudad-specific pages: `tarija.html`, `santa-cruz.html`, `cochabamba.html`, `la-paz.html`, `sucre.html`
- Vercel para deploy
- Supabase para base de datos

## Mejoras de UI/UX Implementadas

### Accesibilidad ♿
- ✅ ARIA labels en todos los inputs
- ✅ HTML semántico con roles apropiados
- ✅ Soporte para navegación con teclado
- ✅ Compatible con lectores de pantalla
- ✅ Contraste de color WCAG AA

### Experiencia de Usuario 🚀
- ✅ Copiar al portapapeles (número de cuenta)
- ✅ Validación de formularios en tiempo real
- ✅ Validación de tamaño de archivo (4MB)
- ✅ Búsqueda con filtrado instantáneo
- ✅ Exportar CSV con datos filtrados
- ✅ Mensajes de error mejorados

## Variables de entorno necesarias

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Desarrollo

```bash
# Instalar dependencias
npm install

# Desarrollo local
npm run dev
```

## Guía Rápida de Diseño

### Paleta de Colores
```
Primary:    #E91E63
Secondary:  #880E4F
Accent:     #4A148C
Success:    #4CAF50
Error:      #f44336
```

### Tipografía
```
Logo:  3.5rem, weight 900
H1:    1.8rem, weight 700
Body:  1rem, weight 400
```

### Espaciado
```
8px  → Tiny
16px → Medium
20px → Large
35px → Card padding
```

Para más detalles, consulta la **[Guía de Diseño Completa](UI-UX-DESIGN-GUIDE.md)**.

## 📸 Capturas de Pantalla

### Registro de Ventas
![Registration](https://github.com/user-attachments/assets/def2ad87-1aa1-45df-9f32-67e98d11e2a2)

### Dashboard
![Dashboard](https://github.com/user-attachments/assets/a7be6d00-fa89-4591-8824-1dcc78d20f93)

### Design Showcase
![Design System](https://github.com/user-attachments/assets/6f4257da-a638-4c43-bf06-a42249151b97)

## 🎯 Próximas Mejoras

Ver la [Guía de Diseño](UI-UX-DESIGN-GUIDE.md) para el roadmap completo de mejoras propuestas, incluyendo:
- Visualización de datos con gráficos
- Filtros avanzados
- Modo oscuro
- PWA capabilities

## Licencia

MIT
