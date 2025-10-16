-- =========================================
-- V2__roles_y_admins.sql
-- - Tabla roles
-- - Migración usuarios.rol (texto) -> usuarios.rol_id (FK)
-- - Tabla cancha_admins + validación de rol
-- =========================================

-- 1) Tabla de roles
CREATE TABLE roles (
  id      BIGSERIAL PRIMARY KEY,
  codigo  VARCHAR(50) NOT NULL UNIQUE,     -- APP_ADMIN | CANCHA_ADMIN | CLIENTE
  nombre  VARCHAR(100)                     -- opcional, para mostrar
);

-- Semilla de roles (id autogenerado)
INSERT INTO roles (codigo, nombre) VALUES
  ('APP_ADMIN',     'Administrador de la aplicación'),
  ('CANCHA_ADMIN',  'Administrador de canchas'),
  ('CLIENTE',       'Cliente/Usuario')
ON CONFLICT (codigo) DO NOTHING;

-- 2) Nueva columna rol_id en usuarios (temporalmente NULL hasta migrar datos)
ALTER TABLE usuarios
  ADD COLUMN rol_id BIGINT;

-- 3) Migrar datos existentes desde usuarios.rol (texto) -> usuarios.rol_id
--    Mapeo legacy: 'usuario' -> CLIENTE; 'admin' -> APP_ADMIN; 'admin_cancha' -> CANCHA_ADMIN
--    Puedes ajustar/completar equivalencias en el CASE inferior.
UPDATE usuarios u
SET rol_id = r.id
FROM roles r
WHERE r.codigo =
  CASE
    WHEN lower(u.rol) IN ('app_admin','admin','administrador') THEN 'APP_ADMIN'
    WHEN lower(u.rol) IN ('cancha_admin','admin_cancha','administrador_cancha') THEN 'CANCHA_ADMIN'
    ELSE 'CLIENTE'  -- 'usuario', valores nulos o desconocidos
  END;

-- 4) Asegurar not null + FK y eliminar la columna antigua
ALTER TABLE usuarios
  ALTER COLUMN rol_id SET NOT NULL;

ALTER TABLE usuarios
  ADD CONSTRAINT fk_usuarios_roles
  FOREIGN KEY (rol_id) REFERENCES roles(id);

-- Índice útil para consultas por rol
CREATE INDEX idx_usuarios_rol_id ON usuarios(rol_id);

-- Eliminar la columna de texto legacy
ALTER TABLE usuarios DROP COLUMN rol;

-- 5) Tabla de relación: qué canchas administra cada usuario CANCHA_ADMIN
CREATE TABLE cancha_admins (
  usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  cancha_id  BIGINT NOT NULL REFERENCES canchas(id)  ON DELETE CASCADE,
  PRIMARY KEY (usuario_id, cancha_id)
);

-- 6) Validación: solo usuarios con rol CANCHA_ADMIN pueden aparecer en cancha_admins
--    Implementamos un trigger BEFORE INSERT/UPDATE.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'enforce_cancha_admin_role'
  ) THEN
    CREATE OR REPLACE FUNCTION enforce_cancha_admin_role()
    RETURNS TRIGGER AS $f$
    DECLARE v_codigo VARCHAR(50);
    BEGIN
      SELECT r.codigo INTO v_codigo
      FROM usuarios u
      JOIN roles r ON r.id = u.rol_id
      WHERE u.id = NEW.usuario_id;

      IF v_codigo IS DISTINCT FROM 'CANCHA_ADMIN' THEN
        RAISE EXCEPTION 'Usuario % no es CANCHA_ADMIN', NEW.usuario_id
          USING ERRCODE = '23514'; -- check_violation
      END IF;

      RETURN NEW;
    END;
    $f$ LANGUAGE plpgsql;

    CREATE TRIGGER trg_cancha_admins_role
    BEFORE INSERT OR UPDATE ON cancha_admins
    FOR EACH ROW EXECUTE FUNCTION enforce_cancha_admin_role();
  END IF;
END$$;

-- 7) (Opcional) vista útil: canchas con sus tarifas y ciudad (para reportes)
-- CREATE OR REPLACE VIEW vw_canchas_tarifas AS
-- SELECT
--   c.id AS cancha_id, c.nombre AS cancha, c.ciudad,
--   th.dia_semana, th.hora_inicio, th.hora_fin, th.precio_hora
-- FROM canchas c
-- JOIN tarifas_horarias th ON th.id_cancha = c.id;
