/*
  # Migración a torneo de 26 PAREJAS · 9 RONDAS · 13 PARTIDOS por ronda

  Cambios:
    - Constraint `partido_idx`: pasa de 0..9 a 0..12 (ahora hay 13 partidos por ronda).
    - Constraint `ronda`: pasa de 1..12 a 1..9 (formato compacto al nuevo torneo).
    - TRUNCATE de `resultados`: el formato anterior (4 jugadoras por partido,
      7 partidos por ronda) ya no es compatible con el nuevo esquema (26 parejas
      con nombre, 13 partidos por ronda). Las claves (ronda, partido_idx)
      apuntan ahora a enfrentamientos distintos, así que conservar los datos
      antiguos los mostraría asignados a los partidos equivocados.

  Idempotencia: todas las operaciones son seguras de ejecutar varias veces.
*/

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

TRUNCATE TABLE resultados;
