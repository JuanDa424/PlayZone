CREATE TABLE usuarios (
  id BIGSERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(150) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  password VARCHAR(200) NOT NULL,
  rol VARCHAR(50) NOT NULL DEFAULT 'usuario',
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE canchas (
  id BIGSERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(200) NOT NULL,
  ciudad VARCHAR(100),
<<<<<<< HEAD
  disponibilidad BOOLEAN DEFAULT TRUE,
  latitud DOUBLE PRECISION,
  longitud DOUBLE PRECISION
=======
  disponibilidad BOOLEAN DEFAULT TRUE
>>>>>>> 794cc0c7809324433908be8427c4d33f9995c6bb
);

CREATE TABLE reservas (
  id BIGSERIAL PRIMARY KEY,
  id_usuario BIGINT NOT NULL REFERENCES usuarios(id),
  id_cancha  BIGINT NOT NULL REFERENCES canchas(id),
  fecha_reserva DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
<<<<<<< HEAD
  total_pago DECIMAL(19, 2) NOT NULL DEFAULT 0.00,
=======
>>>>>>> 794cc0c7809324433908be8427c4d33f9995c6bb
  estado VARCHAR(50) DEFAULT 'pendiente',
  CONSTRAINT uq_reserva_cancha_fecha_horas
    UNIQUE (id_cancha, fecha_reserva, hora_inicio, hora_fin)
);
<<<<<<< HEAD

=======
>>>>>>> 794cc0c7809324433908be8427c4d33f9995c6bb
-- Eliminar precio fijo en canchas (si existe)
ALTER TABLE canchas DROP COLUMN IF EXISTS precio_hora;

-- Nueva tabla de tarifas por franja horaria
CREATE TABLE tarifas_horarias (
    id BIGSERIAL PRIMARY KEY,
    id_cancha   BIGINT NOT NULL REFERENCES canchas(id) ON DELETE CASCADE,
    dia_semana  SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7), -- 1=Lunes ... 7=Domingo
    hora_inicio TIME NOT NULL,
<<<<<<< HEAD
=======
    hora_fin    TIME NOT NULL,
>>>>>>> 794cc0c7809324433908be8427c4d33f9995c6bb
    precio_hora DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_horas_validas CHECK (hora_inicio < hora_fin),
    CONSTRAINT uq_tarifa UNIQUE (id_cancha, dia_semana, hora_inicio, hora_fin)
);

CREATE INDEX idx_tarifa_cancha_dia ON tarifas_horarias(id_cancha, dia_semana);

