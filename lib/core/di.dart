import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/test_repository.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // 1. External Services
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPrefs);

  // 2. Repositories (Lazy Singletons)
  getIt.registerLazySingleton<BaseAuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton(() => OrderRepository());
  getIt.registerLazySingleton(() => NotificationRepository());
  getIt.registerLazySingleton(() => TestRepository());
}
