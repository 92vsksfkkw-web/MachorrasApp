/*
  # Create resultados table for tournament scores

  1. New Tables
    - `resultados`
      - `id` (uuid, primary key)
      - `ronda` (integer) - Round number (1-10)
      - `partido_idx` (integer) - Match index within round (0-9)
      - `scores` (jsonb) - Array of scores [score1, score2]
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
  
  2. Security
    - Enable RLS on `resultados` table
    - Add policy to allow all authenticated users to read/write (tournament is collaborative)
*/

CREATE TABLE IF NOT EXISTS resultados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ronda integer NOT NULL CHECK (ronda >= 1 AND ronda <= 10),
  partido_idx integer NOT NULL CHECK (partido_idx >= 0 AND partido_idx <= 9),
  scores jsonb DEFAULT '[null, null]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(ronda, partido_idx)
);

ALTER TABLE resultados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all authenticated users to read resultados"
  ON resultados
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow all authenticated users to insert resultados"
  ON resultados
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow all authenticated users to update resultados"
  ON resultados
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
