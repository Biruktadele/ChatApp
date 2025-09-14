import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/network/network.dart';
import 'features/auth/data/datasources/local_data/user_local_data_source.dart';
import 'features/auth/data/datasources/local_data/user_local_data_source_impl.dart';
import 'features/auth/data/datasources/remote_data/user_remote_data_source.dart';
import 'features/auth/data/datasources/remote_data/user_remote_data_source_impl.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

//chat


final sl = GetIt.instance;

Future<void> init() async {

  //! Features - Product Catalog
  sl.registerFactory(() => AuthBloc(sl()));
  //chat
  // usecase

  //auth
  sl.registerLazySingleton(() => LoginUserUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUserUsecase(sl()));
  //chat

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  //chat


  // Data Source
  //auth
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(flutterSecureStorage: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl(), secureStorage: sl()),
  );
  //chat
 

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  ///auth + chat
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
}
