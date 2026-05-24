import 'api_client.dart';
import 'auth_api_service.dart';
import 'products_api_service.dart';
import 'categories_api_service.dart';
import 'supermarkets_api_service.dart';
import 'carts_api_service.dart';
import 'offers_api_service.dart';
import 'users_api_service.dart';
import 'meta_api_service.dart';

/// Punto de acceso centralizado a todos los servicios de la API.
///
/// Uso:
/// ```dart
/// final products = await Api.instance.products.list(search: 'arroz');
/// final user = await Api.instance.auth.getMe();
/// ```
class Api {
  static Api? _instance;
  static Api get instance => _instance ??= Api._();

  final ApiClient client;
  late final AuthApiService auth;
  late final ProductsApiService products;
  late final CategoriesApiService categories;
  late final SupermarketsApiService supermarkets;
  late final CartsApiService carts;
  late final OffersApiService offers;
  late final UsersApiService users;
  late final MetaApiService meta;

  Api._() : client = ApiClient() {
    auth = AuthApiService(client);
    products = ProductsApiService(client);
    categories = CategoriesApiService(client);
    supermarkets = SupermarketsApiService(client);
    carts = CartsApiService(client);
    offers = OffersApiService(client);
    users = UsersApiService(client);
    meta = MetaApiService(client);
  }
}
