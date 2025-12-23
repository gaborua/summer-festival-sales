-- Agregar columna package_delivered a la tabla sales
-- Ejecutar este comando en el SQL Editor de Supabase

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS package_delivered BOOLEAN DEFAULT FALSE;

-- Comentario opcional: El campo package_delivered indica si el paquete fue entregado a la persona
COMMENT ON COLUMN sales.package_delivered IS 'Indica si el paquete fue entregado a la persona registrada';
