import 'package:coaching_fit_coach/core/network/api_interceptor.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/core/router/app_router.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/features/auth/data/repositories/auth_repository.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:coaching_fit_coach/features/profile/data/repositories/profile_repository.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorage(sl()));

  // 2. Router (depends on SecureStorage only)
  sl.registerLazySingleton(() => AppRouter(sl()));
  sl.registerLazySingleton<GoRouter>(() => sl<AppRouter>().router);

  // 3. Network (depends on SecureStorage + GoRouter)
  sl.registerLazySingleton(() => ApiInterceptor(sl<SecureStorage>(), sl<GoRouter>()));
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl<Dio>(), sl<ApiInterceptor>()));

  // 4. Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));

  // 5. Cubits
  sl.registerFactory(() => AuthCubit(sl(), sl<SecureStorage>()));
  sl.registerFactory(() => ProfileCubit(sl()));
}
