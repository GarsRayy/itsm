-- Insert Dummy User for Bot Testing
INSERT INTO public.user_profiles (full_name, phone_number, division, email)
VALUES ('Garis Rayya Rabbani', '0895423021051', 'IT', 'garis@example.com')
ON CONFLICT (phone_number) DO NOTHING;

-- Also add an INSERT policy for authenticated users so the CSV import works!
DROP POLICY IF EXISTS "profiles_insert_auth" ON public.user_profiles;
CREATE POLICY "profiles_insert_auth" ON public.user_profiles FOR INSERT TO authenticated WITH CHECK (true);
