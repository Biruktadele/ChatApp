


import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_reositorie.dart';
import '../datasources/remotdata/remot_data_source.dart';

class ChatRepositorieImpl extends ChatRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositorieImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  }); 

  @override
  Future<Either<Failure, List<Chat>>> getChats() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChat = await remoteDataSource.getChats();
        return Right(remoteChat);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(Failure('user is offline'));
    }
  }
  @override
  Future<Either<Failure, List<Message>>> getMessages(int chatId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMessages = await remoteDataSource.getMessages(chatId);
        return Right(remoteMessages);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(Failure('user is offline'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(int messageId, int chatId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMessage(messageId, chatId);
        return Right(null);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(Failure('user is offline'));
    }
  }

  @override
  Future<Either<Failure, Chat>> createChat(int userId) async {
    if (await networkInfo.isConnected) {
      try {
        final createdChat = await remoteDataSource.createChat(userId);
        return Right(createdChat);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(Failure('user is offline'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(int chatId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteChat(chatId);
        return Right(null);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(Failure('user is offline'));
    }
  }
  

  }