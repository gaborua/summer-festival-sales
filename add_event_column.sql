-- Script para agregar columna event_name a la tabla sales
-- Ejecutar en Supabase SQL Editor

-- Agregar columna event_name con valor por defecto para registros existentes
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS event_name TEXT DEFAULT 'Año Nuevo 2026';

-- Comentario: Los registros existentes automáticamente tendrán 'Año Nuevo 2026'
-- Los nuevos registros de Carnaval tendrán 'Carnaval Summer 2026'
