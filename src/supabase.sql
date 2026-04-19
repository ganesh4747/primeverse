-- Creates the required table
CREATE TABLE consultations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    full_name TEXT NOT NULL,
    whatsapp TEXT NOT NULL,
    city TEXT NOT NULL,
    age INTEGER NOT NULL,
    status TEXT NOT NULL,
    income TEXT NOT NULL,
    experience TEXT NOT NULL,
    purchased_course TEXT NOT NULL,
    problems JSONB,
    goal TEXT NOT NULL,
    invest TEXT NOT NULL,
    source TEXT NOT NULL,
    availability TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enables row level security
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;

-- Creates a policy to allow public, unauthorized users to submit the form
CREATE POLICY "Allow public inserts" ON public.consultations 
FOR INSERT 
WITH CHECK (true);
