import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/appearance/presentation/pages/appearance_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/menu/presentation/pages/menu_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

enum UserRole { guest, registered, admin }

class AuthController extends ChangeNotifier {
  AuthController._(this._client);

  factory AuthController.guest() => AuthController._(null);

  factory AuthController.registered() {
    final controller = AuthController._(null);
    controller._role = UserRole.registered;
    controller._displayName = 'Alex';
    return controller;
  }

  final SupabaseClient? _client;
  UserRole _role = UserRole.guest;
  String _displayName = 'Alex';
  bool _loading = false;

  UserRole get role => _role;
  bool get isGuest => _role == UserRole.guest;
  bool get isAdmin => _role == UserRole.admin;
  bool get isRegistered => _role == UserRole.registered;
  bool get isLoading => _loading;
  String get displayName => _displayName;
  String? get userId => _client?.auth.currentUser?.id;
  SupabaseClient? get client => _client;

  static Future<AuthController> create() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (url.isEmpty || anonKey.isEmpty) return AuthController._(null);
    await Supabase.initialize(url: url, publishableKey: anonKey);
    final controller = AuthController._(Supabase.instance.client);
    await controller.refreshSession();
    return controller;
  }

  Future<void> refreshSession() async {
    final user = _client?.auth.currentUser;
    if (user == null) {
      _role = UserRole.guest;
      _displayName = 'Alex';
      notifyListeners();
      return;
    }
    _setDisplayName(user.email, user.userMetadata);
    await _loadRole(user.id);
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      if (email.toLowerCase() == 'abi@gmail.com') {
        _role = UserRole.admin;
        _displayName = 'Abi';
        notifyListeners();
        return null;
      }
      if (email.toLowerCase() == 'john@gmail.com') {
        _role = UserRole.registered;
        _displayName = 'John';
        notifyListeners();
        return null;
      }
      return 'Supabase is not configured.';
    }
    _loading = true;
    notifyListeners();
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return 'Unable to sign in.';
      _setDisplayName(response.user!.email, response.user!.userMetadata);
      await _loadRole(response.user!.id);
      return null;
    } on AuthException catch (error) {
      return error.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
    _role = UserRole.guest;
    _displayName = 'Alex';
    notifyListeners();
  }

  void _setDisplayName(String? email, Map<String, dynamic>? metadata) {
    final metadataName = metadata?['full_name'] ?? metadata?['name'];
    if (metadataName is String && metadataName.trim().isNotEmpty) {
      _displayName = metadataName.trim().split(' ').first;
      return;
    }
    final localPart = email?.split('@').first.trim();
    if (localPart == null || localPart.isEmpty) return;
    _displayName = localPart[0].toUpperCase() + localPart.substring(1);
  }

  Future<void> _loadRole(String userId) async {
    final value = await _client!
        .from('Users')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    _role = value?['role'] == 'admin' ? UserRole.admin : UserRole.registered;
    notifyListeners();
  }

  Route<dynamic>? routeGuard(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/':
        page = const HomePage();
        break;
      case '/login':
        page = const LoginPage();
        break;
      case '/menu':
        page = const MenuPage();
        break;
      case '/cart':
        page = const CartPage();
        break;
      case '/orders':
        page = const OrdersPage();
        break;
      case '/order-detail':
        final orderId = settings.arguments as String?;
        if (orderId == null) return null;
        page = OrderDetailPage(orderId: orderId);
        break;
      case '/profile':
        page = const ProfilePage();
        break;
      case '/appearance':
        page = const AppearancePage();
        break;
      case '/admin':
        page = const AdminPage();
        break;
      default:
        return null;
    }
    final restricted = <String>{
      '/cart',
      '/orders',
      '/profile',
      '/admin',
    };
    if (restricted.contains(settings.name)) {
      if (isGuest) {
        page = const HomePage();
      }
      if (settings.name == '/admin' && !isAdmin) {
        page = const HomePage();
      }
      if (settings.name != '/admin' &&
          isAdmin &&
          !{'/menu', '/orders', '/profile'}.contains(settings.name)) {
        page = const AdminPage();
      }
    }
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }
}
