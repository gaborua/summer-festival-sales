-- Agregar columna tickets_picked_up a la tabla sales
-- Ejecutar este comando en el SQL Editor de Supabase

ALTER TABLE sales
ADD COLUMN IF NOT EXISTS tickets_picked_up BOOLEAN DEFAULT FALSE;

-- Comentario opcional: El campo tickets_picked_up indica si la persona recogió sus tickets físicamente
COMMENT ON COLUMN sales.tickets_picked_up IS 'Indica si la persona recogió sus tickets físicamente';
