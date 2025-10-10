/*
  # Expense Tracker Schema

  1. New Tables
    - `expenses`
      - `id` (uuid, primary key) - Unique identifier for each expense
      - `user_id` (uuid, foreign key) - References auth.users, owner of the expense
      - `amount` (decimal) - The expense amount
      - `category` (text) - Expense category (Food, Travel, Entertainment, etc.)
      - `description` (text) - Optional description of the expense
      - `date` (date) - Date when the expense occurred
      - `created_at` (timestamptz) - Timestamp when record was created
      - `updated_at` (timestamptz) - Timestamp when record was last updated

  2. Security
    - Enable RLS on `expenses` table
    - Add policy for authenticated users to view their own expenses
    - Add policy for authenticated users to insert their own expenses
    - Add policy for authenticated users to update their own expenses
    - Add policy for authenticated users to delete their own expenses

  3. Indexes
    - Index on user_id for faster queries
    - Index on date for date-based filtering
    - Index on category for category-based filtering
*/

CREATE TABLE IF NOT EXISTS expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount decimal(10, 2) NOT NULL CHECK (amount > 0),
  category text NOT NULL,
  description text DEFAULT '',
  date date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own expenses"
  ON expenses FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses"
  ON expenses FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses"
  ON expenses FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses"
  ON expenses FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS expenses_user_id_idx ON expenses(user_id);
CREATE INDEX IF NOT EXISTS expenses_date_idx ON expenses(date);
CREATE INDEX IF NOT EXISTS expenses_category_idx ON expenses(category);