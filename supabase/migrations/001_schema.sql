-- ============================================================
-- FLUTTERZON SUPABASE MIGRATION
-- Run this in your Supabase SQL Editor
-- ============================================================

-- Enable UUID extension (already enabled in Supabase by default)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================
CREATE TABLE profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL DEFAULT '',
  email       TEXT NOT NULL,
  address     TEXT NOT NULL DEFAULT '',
  type        TEXT NOT NULL DEFAULT 'user' CHECK (type IN ('user', 'admin')),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE products (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  description   TEXT NOT NULL DEFAULT '',
  price         DOUBLE PRECISION NOT NULL,
  quantity      INTEGER NOT NULL DEFAULT 0,
  category      TEXT NOT NULL,
  images        TEXT[] NOT NULL DEFAULT '{}',
  avg_rating    DOUBLE PRECISION NOT NULL DEFAULT 0,
  rating_count  INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RATINGS
-- ============================================================
CREATE TABLE ratings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating      DOUBLE PRECISION NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, user_id)
);

-- ============================================================
-- CART ITEMS
-- ============================================================
CREATE TABLE cart_items (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity    INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ============================================================
-- SAVE FOR LATER
-- ============================================================
CREATE TABLE save_for_later (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  total_price     DOUBLE PRECISION NOT NULL,
  status          INTEGER NOT NULL DEFAULT 0,
  -- 0=processing, 1=shipped, 2=delivered
  address         TEXT NOT NULL DEFAULT '',
  ordered_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ORDER ITEMS
-- ============================================================
CREATE TABLE order_items (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id    UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE SET NULL,
  quantity    INTEGER NOT NULL DEFAULT 1,
  price       DOUBLE PRECISION NOT NULL
);

-- ============================================================
-- WISHLISTS
-- ============================================================
CREATE TABLE wishlists (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ============================================================
-- BROWSING HISTORY
-- ============================================================
CREATE TABLE browsing_history (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  viewed_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ============================================================
-- OFFERS (4 image offers managed by admin)
-- ============================================================
CREATE TABLE offers (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  image_url   TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_name ON products USING gin(to_tsvector('english', name));
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_wishlists_user ON wishlists(user_id);
CREATE INDEX idx_browsing_user ON browsing_history(user_id);
CREATE INDEX idx_ratings_product ON ratings(product_id);

-- ============================================================
-- FUNCTION: auto-create profile on signup
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, name, email, address, type)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    NEW.email,
    '',
    'user'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- FUNCTION: update avg_rating on products after rating insert/update
-- ============================================================
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products SET
    avg_rating = (
      SELECT COALESCE(AVG(rating), 0) FROM ratings WHERE product_id = NEW.product_id
    ),
    rating_count = (
      SELECT COUNT(*) FROM ratings WHERE product_id = NEW.product_id
    )
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_rating_change
  AFTER INSERT OR UPDATE ON ratings
  FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- ============================================================
-- RLS (Row Level Security)
-- ============================================================
ALTER TABLE profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE products         ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE save_for_later   ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders           ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items      ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists        ENABLE ROW LEVEL SECURITY;
ALTER TABLE browsing_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers           ENABLE ROW LEVEL SECURITY;

-- Helper function: is current user admin?
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND type = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- PROFILES
CREATE POLICY "Users read own profile"       ON profiles FOR SELECT USING (id = auth.uid() OR is_admin());
CREATE POLICY "Users update own profile"     ON profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Admin full access profiles"   ON profiles FOR ALL USING (is_admin());

-- PRODUCTS (public read, admin write)
CREATE POLICY "Anyone reads products"        ON products FOR SELECT USING (true);
CREATE POLICY "Admin manages products"       ON products FOR ALL USING (is_admin());

-- RATINGS
CREATE POLICY "Anyone reads ratings"         ON ratings FOR SELECT USING (true);
CREATE POLICY "User rates own orders only"   ON ratings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "User updates own rating"      ON ratings FOR UPDATE USING (auth.uid() = user_id);

-- CART
CREATE POLICY "User manages own cart"        ON cart_items FOR ALL USING (auth.uid() = user_id);

-- SAVE FOR LATER
CREATE POLICY "User manages save_for_later"  ON save_for_later FOR ALL USING (auth.uid() = user_id);

-- ORDERS
CREATE POLICY "User reads own orders"        ON orders FOR SELECT USING (auth.uid() = user_id OR is_admin());
CREATE POLICY "User creates own orders"      ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admin updates orders"         ON orders FOR UPDATE USING (is_admin());

-- ORDER ITEMS
CREATE POLICY "User reads own order items"   ON order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND (orders.user_id = auth.uid() OR is_admin()))
);
CREATE POLICY "User creates order items"     ON order_items FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);

-- WISHLISTS
CREATE POLICY "User manages wishlist"        ON wishlists FOR ALL USING (auth.uid() = user_id);

-- BROWSING HISTORY
CREATE POLICY "User manages history"         ON browsing_history FOR ALL USING (auth.uid() = user_id);

-- OFFERS (public read, admin write)
CREATE POLICY "Anyone reads offers"          ON offers FOR SELECT USING (true);
CREATE POLICY "Admin manages offers"         ON offers FOR ALL USING (is_admin());
