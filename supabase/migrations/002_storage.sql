-- ============================================================
-- SUPABASE STORAGE BUCKETS & POLICIES
-- Run this AFTER 001_schema.sql
-- ============================================================

-- Create buckets
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('product-images', 'product-images', true),
  ('offer-images',   'offer-images',   true);

-- ============================================================
-- PRODUCT IMAGES STORAGE POLICIES
-- ============================================================

-- Anyone can view product images (public bucket)
CREATE POLICY "Public read product images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

-- Only admins can upload product images
CREATE POLICY "Admin uploads product images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'product-images'
    AND is_admin()
  );

-- Only admins can delete product images
CREATE POLICY "Admin deletes product images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'product-images'
    AND is_admin()
  );

-- ============================================================
-- OFFER IMAGES STORAGE POLICIES
-- ============================================================

CREATE POLICY "Public read offer images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'offer-images');

CREATE POLICY "Admin uploads offer images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'offer-images'
    AND is_admin()
  );

CREATE POLICY "Admin deletes offer images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'offer-images'
    AND is_admin()
  );
