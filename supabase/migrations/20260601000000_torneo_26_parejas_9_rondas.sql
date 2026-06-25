/*
  # Migración a torneo de 26 PAREJAS · 9 RONDAS · 13 PARTIDOS por ronda

  Cambios:
    - TRUNCATE de `resultados`: el formato anterior (4 jugadoras por partido,
      7 partidos por ronda, 12 rondas) no es compatible con el nuevo esquema
      (26 parejas con nombre, 13 partidos por ronda, 9 rondas). Las claves
      (ronda, partido_idx) apuntan a enfrentamientos distintos.
    - Constraint `partido_idx`: pasa de 0..9 a 0..12 (ahora hay 13 partidos por ronda).
    - Constraint `ronda`: pasa de 1..12 a 1..9 (formato compacto del nuevo torneo).

  IMPORTANTE — Orden de ejecución:
    El TRUNCATE debe ir ANTES de añadir las nuevas constraints. Si se añade
    una constraint sobre datos existentes que la violan, falla. Por eso primero
    se vacía la tabla y luego se aplican las restricciones más estrictas.

  Idempotencia: todas las operaciones son seguras de ejecutar varias veces.
*/

TRUNCATE TABLE resultados;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'resultados_partido_idx_check'
  ) THEN
    ALTER TABLE resultados DROP CONSTRAINT resultados_partido_idx_check;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'resultados_ronda_check'
  ) THEN
    ALTER TABLE resultados DROP CONSTRAINT resultados_ronda_check;
  END IF;
END $$;

ALTER TABLE resultados
  ADD CONSTRAINT resultados_partido_idx_check CHECK (partido_idx >= 0 AND partido_idx <= 12);

ALTER TABLE resultados
  ADD CONSTRAINT resultados_ronda_check CHECK (ronda >= 1 AND ronda <= 9);
