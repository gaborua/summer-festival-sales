# Quick Design Reference Card

## 🎨 Colors

```css
/* Primary Colors */
--primary: #E91E63;
--primary-dark: #C2185B;
--secondary: #880E4F;
--accent: #4A148C;

/* Status Colors */
--success: #4CAF50;
--error: #f44336;
--warning: #FF9800;
--info: #2196F3;

/* Neutral Colors */
--gray-light: #f5f5f5;
--gray-medium: #666;
--gray-dark: #333;

/* Gradients */
--gradient-bg: linear-gradient(135deg, #E91E63 0%, #880E4F 50%, #4A148C 100%);
--gradient-primary: linear-gradient(135deg, #E91E63 0%, #C2185B 100%);
--gradient-success: linear-gradient(135deg, #4CAF50 0%, #388E3C 100%);
--gradient-error: linear-gradient(135deg, #f44336 0%, #c62828 100%);
```

## 📏 Spacing Scale

```
8px  - Tiny (between related elements)
12px - Small 
16px - Medium (input padding, small margins)
20px - Large (form group margin)
24px - XLarge
32px - 2XLarge
40px - 3XLarge
```

## 🔤 Typography

```css
/* Font Family */
font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;

/* Font Sizes */
--logo: 3.5rem;      /* 56px */
--h1: 1.8rem;        /* 28.8px */
--h2: 1.5rem;        /* 24px */
--h3: 1.3rem;        /* 20.8px */
--body: 1rem;        /* 16px */
--small: 0.9rem;     /* 14.4px */

/* Font Weights */
--light: 400;
--medium: 600;
--bold: 700;
--black: 900;
```

## 📐 Border Radius

```
8px  - Small elements (badges, tags)
12px - Medium elements (inputs, buttons)
16px - Large elements (qr containers)
20px - Cards, sections
```

## ☁️ Shadows

```css
/* Small - Subtle elevation */
box-shadow: 0 2px 4px rgba(0,0,0,0.1);

/* Medium - Buttons, hover states */
box-shadow: 0 6px 20px rgba(233, 30, 99, 0.4);

/* Large - Cards, modals */
box-shadow: 0 20px 60px rgba(0,0,0,0.3);
```

## 🔘 Button Styles

```css
.btn-primary {
  padding: 18px;
  background: linear-gradient(135deg, #E91E63 0%, #C2185B 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 700;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 1px;
  box-shadow: 0 6px 20px rgba(233, 30, 99, 0.4);
  transition: all 0.3s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(233, 30, 99, 0.5);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
```

## 📝 Form Input Styles

```css
input, select {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #f0f0f0;
  border-radius: 12px;
  font-size: 16px;
  background: #fafafa;
  transition: all 0.3s;
}

input:focus {
  outline: none;
  border-color: #E91E63;
  background: white;
  box-shadow: 0 0 0 4px rgba(233, 30, 99, 0.1);
}

/* Validation states */
input:valid:not(:focus):not(:placeholder-shown) {
  border-color: #4CAF50;
}

input:invalid:not(:focus):not(:placeholder-shown) {
  border-color: #f44336;
}
```

## 🃏 Card Component

```css
.card {
  background: white;
  padding: 35px;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
  transition: transform 0.3s;
}

.card:hover {
  transform: translateY(-5px);
}
```

## 💬 Message/Alert Styles

```css
.message {
  padding: 16px;
  border-radius: 12px;
  text-align: center;
  font-weight: 600;
  margin: 10px 0;
}

.message-success {
  background: linear-gradient(135deg, #4CAF50 0%, #388E3C 100%);
  color: white;
}

.message-error {
  background: linear-gradient(135deg, #f44336 0%, #c62828 100%);
  color: white;
}
```

## 🎯 Common Icons (Emoji)

```
👤 - Usuario / User
🎯 - Target / Goal
🎫 - Ticket
💳 - Pago / Payment
📎 - Archivo / File
📝 - Registro / Register
📊 - Estadísticas / Stats
📋 - Lista / List
✅ - Success
❌ - Error
⏳ - Loading
🔍 - Buscar / Search
📥 - Descargar / Download
```

## 📱 Breakpoints

```css
/* Mobile */
@media (max-width: 480px) { }

/* Tablet */
@media (max-width: 768px) { }

/* Desktop */
@media (max-width: 1024px) { }

/* Large Desktop */
@media (max-width: 1440px) { }
```

## ⚡ Transitions

```css
/* Default transition for interactive elements */
transition: all 0.3s ease;

/* Hover effects */
transform: translateY(-2px);

/* Active/Click effects */
transform: scale(0.95);
```

## ♿ Accessibility Checklist

- [ ] Add `aria-label` to all form inputs
- [ ] Use `aria-required="true"` for required fields
- [ ] Add `role` attributes where appropriate
- [ ] Ensure color contrast meets WCAG AA (4.5:1)
- [ ] Add descriptive `alt` text to images
- [ ] Use semantic HTML (`<nav>`, `<main>`, `<section>`)
- [ ] Test keyboard navigation (Tab, Enter, Esc)
- [ ] Add focus indicators (outline or box-shadow)
- [ ] Use `aria-live` for dynamic content updates

## 🚀 Performance Tips

1. **Images**: Compress and use appropriate formats (WebP when possible)
2. **CSS**: Minimize use of expensive properties (box-shadow, gradients)
3. **Animations**: Use `transform` and `opacity` (GPU accelerated)
4. **Fonts**: Use `font-display: swap` to prevent FOIT
5. **Load order**: Critical CSS inline, defer non-critical
6. **Lazy load**: Images below the fold
7. **Minify**: CSS and JS in production

## 📖 Resources

- Full Guide: `UI-UX-DESIGN-GUIDE.md`
- Design Showcase: `design-showcase.html`
- Main Registration: `index.html`
- Dashboard: `dashboard.html`

## 🎨 Design Principles

1. **Consistency**: Use the same patterns throughout
2. **Feedback**: Always inform users of their actions
3. **Simplicity**: Keep interfaces clean and intuitive
4. **Accessibility**: Design for everyone
5. **Performance**: Fast load times improve UX
6. **Mobile-first**: Design for small screens first
7. **Visual Hierarchy**: Use size, color, and spacing effectively

---

## Quick Copy-Paste Snippets

### Basic Button
```html
<button class="btn">Registrar Venta</button>
```

### Form Group
```html
<div class="form-group">
  <label for="fieldName">📝 Label *</label>
  <input type="text" id="fieldName" required aria-required="true" aria-label="Description">
</div>
```

### Success Message
```html
<div class="message message-success">
  ✅ Operación exitosa
</div>
```

### Stat Card
```html
<div class="stat-card">
  <h3>145</h3>
  <p>📝 Total Ventas</p>
</div>
```

### Search Box
```html
<input type="search" placeholder="🔍 Buscar..." aria-label="Buscar">
```

---

**Remember**: When in doubt, check `design-showcase.html` for live examples!
