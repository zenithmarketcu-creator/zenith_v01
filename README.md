# Flutterzon — Supabase Edition 🛒

Amazon Clone full-stack app migrated from Node.js + MongoDB + Cloudinary → **100% Supabase**.

## Stack

| Antes | Ahora |
|---|---|
| Node.js + Express | ❌ Eliminado |
| MongoDB / Mongoose | ✅ Supabase PostgreSQL |
| Cloudinary | ✅ Supabase Storage |
| JWT custom auth | ✅ Supabase Auth |
| HTTP calls al server | ✅ `supabase_flutter` SDK directo |

---

## Setup en 5 pasos

### 1. Crear proyecto en Supabase
1. Ve a [supabase.com](https://supabase.com) y crea un proyecto nuevo
2. Espera a que se inicialice (~2 min)

### 2. Ejecutar migraciones SQL
En el **SQL Editor** de tu proyecto Supabase, corre en orden:

```
supabase/migrations/001_schema.sql   ← Tablas, RLS, funciones y triggers
supabase/migrations/002_storage.sql  ← Buckets y políticas de storage
```

### 3. Crear usuario admin
Después de correr los migrations, en SQL Editor:

```sql
-- Crea el usuario primero desde la app (Sign Up) con email admin@tuapp.com
-- Luego actualiza su tipo a 'admin':
UPDATE profiles SET type = 'admin' WHERE email = 'admin@tuapp.com';
```

### 4. Configurar credenciales en Flutter
En `lib/main.dart`, reemplaza:

```dart
const _supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
const _supabaseAnonKey = 'YOUR_ANON_KEY';
```

Tus valores están en: **Supabase Dashboard → Settings → API**

### 5. Instalar dependencias y correr

```bash
flutter pub get
flutter run
```

---

## Estructura del proyecto

```
lib/
├── main.dart                          # Entry point, Supabase init, BLoC providers
└── src/
    ├── blocs/
    │   ├── auth/                      # HydratedBloc - persiste sesión
    │   ├── product/                   # Productos, búsqueda, historial, ratings
    │   ├── cart/                      # Carrito + save for later
    │   ├── order/                     # Órdenes de usuario
    │   ├── wishlist/                  # Lista de deseos
    │   └── admin/                     # Panel admin
    ├── data/
    │   ├── datasources/
    │   │   └── supabase_client.dart   # Singleton del cliente Supabase
    │   ├── models/                    # UserModel, ProductModel, OrderModel, etc.
    │   └── repositories/
    │       ├── auth_repository.dart
    │       ├── product_repository.dart
    │       ├── cart_repository.dart
    │       ├── order_repository.dart
    │       ├── wishlist_repository.dart
    │       └── admin_repository.dart  # CRUD + Supabase Storage uploads
    ├── presentation/
    │   ├── screens/
    │   │   ├── auth/                  # SignIn, SignUp
    │   │   ├── home/                  # HomeScreen con carousel, categorías, deals
    │   │   ├── product/               # Detail, CategoryProducts, Search
    │   │   ├── cart/                  # Cart con swipe actions
    │   │   ├── order/                 # Orders list, Order detail con rating
    │   │   ├── account/               # Account, Wishlist, BrowsingHistory
    │   │   └── admin/                 # Dashboard, AddProduct, Orders, Offers
    │   └── widgets/                   # ProductCard, LoadingWidget, etc.
    └── utils/
        ├── constants/app_constants.dart
        └── router/app_router.dart     # go_router con redirect auth/admin
supabase/
├── migrations/001_schema.sql          # Todas las tablas + RLS + triggers
└── migrations/002_storage.sql         # Storage buckets + políticas
```

---

## Tablas en Supabase

| Tabla | Descripción |
|---|---|
| `profiles` | Extiende auth.users — nombre, dirección, tipo (user/admin) |
| `products` | Nombre, precio, categoría, imágenes[], avg_rating auto-calculado |
| `ratings` | Rating por usuario/producto — trigger actualiza avg en products |
| `cart_items` | Carrito por usuario con cantidad |
| `save_for_later` | Guardado para después |
| `orders` | Órdenes con estado (0=Processing, 1=Shipped, 2=Delivered) |
| `order_items` | Ítems de cada orden |
| `wishlists` | Wishlist por usuario |
| `browsing_history` | Historial de productos vistos |
| `offers` | 4 imágenes de ofertas gestionadas desde admin |

---

## Storage Buckets

| Bucket | Uso | Acceso |
|---|---|---|
| `product-images` | Imágenes de productos | Público (lectura), Admin (escritura) |
| `offer-images` | Imágenes de ofertas | Público (lectura), Admin (escritura) |

---

## Notas importantes

- **Auth persistida** con `hydrated_bloc` — el usuario queda logueado al cerrar la app
- **Admin redirect** automático — si el usuario tiene `type = 'admin'`, el router lo manda al panel admin
- **RLS habilitado** en todas las tablas — seguridad a nivel de base de datos
- **Trigger automático** crea el perfil al registrarse en Supabase Auth
- **Trigger automático** recalcula `avg_rating` y `rating_count` al calificar un producto
- El campo `order_items.product_id` usa `ON DELETE SET NULL` para preservar el historial aunque se elimine el producto

---

## Test credentials

Crea los usuarios manualmente desde la app y luego usa el SQL de arriba para hacer admin.

| Role | Cómo crear |
|---|---|
| User | Registro normal en la app |
| Admin | Registro normal → SQL UPDATE profiles SET type = 'admin' |
