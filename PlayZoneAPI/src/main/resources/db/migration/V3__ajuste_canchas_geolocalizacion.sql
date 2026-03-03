-- ======================================================
-- V3__ajuste_canchas_geolocalizacion.sql
-- ======================================================

-- 1) Agregar coordenadas a la tabla canchas
ALTER TABLE canchas 
  ADD COLUMN latitud DOUBLE PRECISION,
  ADD COLUMN longitud DOUBLE PRECISION;

-- 2) Hacer que las coordenadas sean obligatorias (opcional, si ya tienes datos pon un default primero)
-- UPDATE canchas SET latitud = 4.6097, longitud = -74.0817 WHERE latitud IS NULL; -- Default Bogotá

-- 3) Limpiar redundancia: 
-- Si ya tienes la latitud/longitud, podrías querer mantener la dirección como texto 
-- descriptivo pero eliminar 'ciudad' si vas a manejar todo por coordenadas.
-- Por ahora la dejamos pero aseguramos consistencia.

-- 4) Ajuste en Tarifas Horarias (Si es necesario)
-- Tu tabla V1 ya es bastante limpia. La restricción uq_tarifa evita que 
-- una misma cancha tenga dos precios distintos para la misma hora y día.