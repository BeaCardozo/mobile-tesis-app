# Merge HEAD vs `front-end` (mobile-tesis-app)

## Ramas / contexto

- **HEAD**: integración con **ca-api** (`Api`, `ApiClient`, JWT + refresh, `CartManager` con carritos remotos, `lib/models/api_models.dart`).
- **`front-end`**: UI y flujos con datos locales / `ApiService` + `AuthService` legacy, sin la capa unificada `Api.instance`.

## Criterio aplicado

1. **API primero**: imports y llamadas a `Api.instance.*`, manejo de sesión con `Api.instance.client` / `auth`, mismos contratos que el backend Nest (`/api` prefix).
2. **Tipos de catálogo**: en JSON, `id` de producto y `category.id` llegan como **string** (UUID OLTP o numérico serializado). En UI:
   - `Product.id` y `Product.categoryId` → **String**.
   - `Category.id` → **int** para compatibilidad con grids/filtros; se parsea con `int.tryParse` desde string o número.
3. **UI de `front-end`**: se incorporó donde no chocaba con la API (badge de tiendas en `ProductCard`, sufijo de unidad en precios, bloque “Contáctanos” en ayuda, columna precio + unidad en detalle de producto).

## Archivos tocados de forma destacada

- **`category_detail_screen.dart`**: reescrito por corrupción de marcadores; `products.list(categoryId: widget.category.id.toString())`.
- **`cart_screen.dart`**: eliminado el cuerpo legacy basado en `widget.cartItems`; queda solo la versión con `CartManager`.
- **`lib/services/api_models.dart`**: duplicado no referenciado; eliminado (el canónico es `lib/models/api_models.dart`).

## Comandos post-merge

```bash
flutter pub get
flutter analyze
```
