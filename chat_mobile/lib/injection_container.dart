//

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/db_manager/database_helper.dart';
import 'core/network/network.dart';
import 'features/auth/data/datasources/local_data/user_local_data_source.dart';
import 'features/auth/data/datasources/local_data/user_local_data_source_impl.dart';
import 'features/auth/data/datasources/remote_data/user_remote_data_source.dart';
import 'features/auth/data/datasources/remote_data/user_remote_data_source_impl.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/get_all_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/data/datasources/localdata/local_data_source.dart';
import 'features/chat/data/datasources/localdata/local_data_source_impl.dart';
import 'features/chat/data/datasources/remotdata/remot_data_source.dart';
import 'features/chat/data/datasources/remotdata/remot_data_source_impl.dart';
import 'features/chat/data/datasources/socketio/chat_socket_service.dart';
import 'features/chat/data/datasources/socketio/socket_io_chat_socket_service.dart';
import 'features/chat/data/repositories/chat_repositorie_impl.dart';
import 'features/chat/data/repositories/chat_socket_repository_impl.dart';
import 'features/chat/domain/repositories/chat_reositorie.dart';
import 'features/chat/domain/repositories/chat_socket_repository.dart';
import 'features/chat/domain/usecases/Chat_usecase/creat_chat_usecase.dart';
import 'features/chat/domain/usecases/Chat_usecase/delet_message_usecase.dart';
import 'features/chat/domain/usecases/Chat_usecase/delete_chat_usecase.dart';
import 'features/chat/domain/usecases/Chat_usecase/get_chat_usecase.dart';
import 'features/chat/domain/usecases/Chat_usecase/get_message_usecase.dart';
import 'features/chat/domain/usecases/socket/connect_socket.dart';
import 'features/chat/domain/usecases/socket/join_chat_room.dart';
import 'features/chat/domain/usecases/socket/markMessageAsRead_usecase.dart';
import 'features/chat/domain/usecases/socket/on_get_suggestions_usecase.dart';
import 'features/chat/domain/usecases/socket/on_message_stream.dart';
import 'features/chat/domain/usecases/socket/send_realtime_message.dart';
import 'features/chat/domain/usecases/socket/start_typing_usecase.dart';
import 'features/chat/domain/usecases/socket/stop_typing_usecase.dart';
import 'features/chat/presentation/bloc/bloc/chat_bloc.dart';
// chat socket
// ...existing code...

//chat

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Product Catalog

  initAuth();
  initChat();
  initChatSocket();
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  ///auth + chat
  
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
}

void initAuth() {
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerLazySingleton(() => LoginUserUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUserUsecase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUsecase(sl()));

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // ...existing code...

  // Data Source
  //auth
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(flutterSecureStorage: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl(), secureStorage: sl()),
  );
}

void initChat() {
  // Register other dependencies here if needed

  sl.registerFactory(() => ChatBloc(sl() , sl()));
  // Use cases
  sl.registerLazySingleton(() => GetChatsUsecase(sl()));
  sl.registerLazySingleton(() => CreateChatUsecase(sl()));
  sl.registerLazySingleton(() => DeleteChatUsecase(sl()));
  sl.registerLazySingleton(() => GetMessagesUsecase(sl()));
  sl.registerLazySingleton(() => DeleteMessageUsecase(sl()));
  

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositorieImpl(remoteDataSource: sl(), networkInfo: sl() , localDataSource: sl()),
  );
  // Data Source
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemotDataSourceImpl(client: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());

}
void initChatSocket() {
  // Register other dependencies here if needed

  // sl.registerFactory(() => ChatBloc(sl(), sl()));
  // Use cases
  sl.registerLazySingleton(() => ConnectSocket(sl() , sl()));
  sl.registerLazySingleton(() => JoinChatRoom(sl()));
  sl.registerLazySingleton(() => OnMessageStream(sl()));
  sl.registerLazySingleton(() => SendRealtimeMessage(sl()));
  sl.registerLazySingleton(() => StartTyping(sl()));
  sl.registerLazySingleton(() => StopTyping(sl()));
  sl.registerLazySingleton(() => MarkMessageAsRead_usecase(sl()));
  sl.registerLazySingleton(() => OnGetSuggestionsUsecase(sl()));

  // Repository
  sl.registerLazySingleton<ChatSocketRepository>(
    () => ChatSocketRepositoryImpl(
      socketService: sl(),
      userLocal: sl(),
    
    ),
  );
  // sl.registerLazySingleton<ChatRepository>(
  //   () => ChatRepositorieImpl(remoteDataSource: sl(), networkInfo: sl()),
  // );
  // Data Source
  sl.registerLazySingleton<ChatSocketService>(
    () => SocketIoChatSocketService(),
  );
}
