-- Insert the 628 version just in case Fonnte sends it with country code
INSERT INTO public.user_profiles (full_name, phone_number, division, email)
VALUES ('Garis Rayya Rabbani', '62895423021051', 'IT', 'garis2@example.com')
ON CONFLICT (phone_number) DO NOTHING;
