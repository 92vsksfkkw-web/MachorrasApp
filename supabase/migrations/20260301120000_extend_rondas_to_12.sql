/*
  # Update resultados table constraint to allow up to 12 rounds

  Cambios:
    - Eliminamos la restricción anterior `ronda <= 10` y la sustituimos por `ronda <= 12`
      para alinear la base de datos con el nuevo formato del torneo (12 rondas).
    - Mantenemos la restricción de partido_idx (0-9) ya que sigue siendo válida (7 partidos por ronda).
    - Idempotente: solo se aplica si la restricción antigua existe.
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'resultados_ronda_check'
  ) THEN
    ALTER TABLE resultados DROP CONSTRAINT resultados_ronda_check;
  END IF;
END $$;

ALTER TABLE resultados
  ADD CONSTRAINT resultados_ronda_check CHECK (ronda >= 1 AND ronda <= 12);
