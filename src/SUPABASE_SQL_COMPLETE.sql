-- ============================================================================
-- PRIMEVERSE PAYMENT SYSTEM - SUPABASE SQL SETUP
-- ============================================================================
-- COPY THIS ENTIRE FILE AND PASTE INTO SUPABASE SQL EDITOR
-- NO AUTHENTICATION REQUIRED - PUBLIC ACCESS ENABLED
-- ============================================================================

-- ============================================================================
-- 1. CREATE PAYMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.payments (
  id BIGSERIAL PRIMARY KEY,
  program VARCHAR(50) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  transaction_id VARCHAR(255) NOT NULL UNIQUE,
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',
  payment_method VARCHAR(50) DEFAULT 'UPI',
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_payments_email ON public.payments(email);
CREATE INDEX IF NOT EXISTS idx_payments_phone ON public.payments(phone);
CREATE INDEX IF NOT EXISTS idx_payments_transaction_id ON public.payments(transaction_id);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at);
CREATE INDEX IF NOT EXISTS idx_payments_program ON public.payments(program);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);

-- ============================================================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS) - NO AUTHENTICATION NEEDED
-- ============================================================================
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Public INSERT policy - anyone can insert payments
DROP POLICY IF EXISTS "Allow public insert" ON public.payments;
CREATE POLICY "Allow public insert" ON public.payments
  FOR INSERT
  WITH CHECK (true);

-- Public SELECT policy - anyone can read payments
DROP POLICY IF EXISTS "Allow public select" ON public.payments;
CREATE POLICY "Allow public select" ON public.payments
  FOR SELECT
  USING (true);

-- ============================================================================
-- 3. CREATE CONTACT LOGS TABLE (OPTIONAL - for tracking contact attempts)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.contact_logs (
  id BIGSERIAL PRIMARY KEY,
  program VARCHAR(50) NOT NULL,
  contact_method VARCHAR(20) NOT NULL,
  user_ip VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_contact_logs_program ON public.contact_logs(program);
CREATE INDEX IF NOT EXISTS idx_contact_logs_created_at ON public.contact_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_contact_logs_method ON public.contact_logs(contact_method);

-- Enable RLS for contact logs
ALTER TABLE public.contact_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert contact logs" ON public.contact_logs;
CREATE POLICY "Allow public insert contact logs" ON public.contact_logs
  FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- 4. CREATE PROGRAMS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.programs (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  price DECIMAL(10, 2),
  original_price DECIMAL(10, 2),
  description TEXT,
  contact_phone VARCHAR(20),
  whatsapp_number VARCHAR(20),
  features JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert program data
INSERT INTO public.programs (name, price, original_price, description, contact_phone, whatsapp_number)
VALUES 
  ('PrimeStart', 5000, 10000, 'Perfect for beginners. $5K and $10K traders.', '+91-9876543210', '+91-9876543210'),
  ('PrimeAdvance', NULL, NULL, 'Advanced program for $25K and $50K traders.', '+91-9876543210', '+91-9876543210'),
  ('PrimeElite', NULL, NULL, 'Premium program for $100K and $200K traders.', '+91-8765432109', '+91-8765432109')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- 5. CREATE STATS TABLE (OPTIONAL - for analytics)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.stats (
  id BIGSERIAL PRIMARY KEY,
  metric_name VARCHAR(50) NOT NULL,
  metric_value DECIMAL(10, 2),
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stats_metric ON public.stats(metric_name);
CREATE INDEX IF NOT EXISTS idx_stats_date ON public.stats(date);

-- ============================================================================
-- MONITORING & ADMIN QUERIES
-- ============================================================================

-- Query 1: Get all payments with details
-- SELECT * FROM payments ORDER BY created_at DESC;

-- Query 2: Get total revenue
-- SELECT COUNT(*) as total_payments, SUM(amount) as total_revenue FROM payments;

-- Query 3: Get today's payments
-- SELECT * FROM payments WHERE DATE(created_at) = CURRENT_DATE ORDER BY created_at DESC;

-- Query 4: Get payments by program
-- SELECT program, COUNT(*) as transaction_count, SUM(amount) as total_revenue 
-- FROM payments GROUP BY program ORDER BY total_revenue DESC;

-- Query 5: Get daily revenue breakdown
-- SELECT DATE(created_at) as date, COUNT(*) as transactions, SUM(amount) as revenue 
-- FROM payments GROUP BY DATE(created_at) ORDER BY date DESC LIMIT 30;

-- Query 6: Get payment trends (hourly)
-- SELECT DATE_TRUNC('hour', created_at) as hour, COUNT(*) as count, SUM(amount) as total
-- FROM payments GROUP BY DATE_TRUNC('hour', created_at) ORDER BY hour DESC LIMIT 24;

-- Query 7: Check for duplicate transactions (fraud detection)
-- SELECT transaction_id, COUNT(*) as duplicates FROM payments 
-- GROUP BY transaction_id HAVING COUNT(*) > 1;

-- Query 8: Get customer contact info
-- SELECT full_name, email, phone, program, amount, created_at 
-- FROM payments WHERE program = 'PrimeStart' ORDER BY created_at DESC;

-- Query 9: Get recent payments (last 7 days)
-- SELECT * FROM payments 
-- WHERE created_at > NOW() - INTERVAL '7 days'
-- ORDER BY created_at DESC;

-- Query 10: Get payment statistics
-- SELECT 
--   COUNT(*) as total_payments,
--   SUM(amount) as total_revenue,
--   AVG(amount) as avg_amount,
--   MIN(amount) as min_amount,
--   MAX(amount) as max_amount
-- FROM payments;

-- ============================================================================
-- VERIFICATION QUERIES (Run these to verify setup)
-- ============================================================================

-- Check if tables exist
-- SELECT * FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_name IN ('payments', 'contact_logs', 'programs');

-- Check RLS policies
-- SELECT schemaname, tablename, policyname FROM pg_policies 
-- WHERE schemaname = 'public' AND tablename IN ('payments', 'contact_logs');

-- Check if you can insert (test public access)
-- INSERT INTO payments (program, full_name, email, phone, transaction_id, amount, currency, payment_method)
-- VALUES ('PrimeStart', 'Test User', 'test@example.com', '9876543210', 'TEST-123-456', 5000, 'INR', 'UPI');

-- ============================================================================
-- USEFUL FUNCTIONS (Optional - Advanced)
-- ============================================================================

-- Create function to calculate daily revenue
-- CREATE OR REPLACE FUNCTION get_daily_revenue(p_date DATE)
-- RETURNS DECIMAL AS $$
-- SELECT SUM(amount) FROM payments 
-- WHERE DATE(created_at) = p_date;
-- $$ LANGUAGE SQL;

-- Create function to get total paid customers
-- CREATE OR REPLACE FUNCTION get_total_customers()
-- RETURNS INT AS $$
-- SELECT COUNT(DISTINCT email) FROM payments;
-- $$ LANGUAGE SQL;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
-- 
-- Tables created:
-- ✅ payments - Stores all payment transactions
-- ✅ contact_logs - Tracks contact attempts (optional)
-- ✅ programs - Program information
-- ✅ stats - Analytics data (optional)
--
-- RLS Policies enabled:
-- ✅ Public INSERT - No authentication needed
-- ✅ Public SELECT - View payments
--
-- Indexes created for performance:
-- ✅ email, phone, transaction_id, created_at, program, status
--
-- Ready to use!
-- ============================================================================

