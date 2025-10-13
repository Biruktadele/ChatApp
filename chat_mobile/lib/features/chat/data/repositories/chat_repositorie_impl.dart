import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_reositorie.dart';
import '../datasources/localdata/local_data_source.dart';
import '../datasources/remotdata/remot_data_source.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepositorieImpl extends ChatRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  ChatRepositorieImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Chat>>> getChats() async {
    try {
      final cachedChats = await localDataSource.getCachedChats();
      debugPrint('🏵️🏵️🏵️Cached chats: $cachedChats');
      if (cachedChats.isNotEmpty) {
        return Right(cachedChats);
      }
    } catch (e) {
      debugPrint('No cached chats found: $e');
    }
    debugPrint('User is offline or no cached chats, fetching from remote.');
    if (await networkInfo.isConnected) {
      try {
        final remoteChat = await remoteDataSource.getChats();
        // Convert List<Chat> to List<ChatModel> before caching
        debugPrint('🎉🎉🎉Fetched chats from remote: $remoteChat');

        final chatModels = remoteChat
            .map((chat) => ChatModel.fromEntity(chat))
            .toList();
        await localDataSource.cacheChats(chatModels);
        return Right(remoteChat);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        final localChat = await localDataSource.getCachedChats();
        return Right(localChat);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(int chatId) async {
    try {
      final cachedMessages = await localDataSource.getCachedMessages(chatId);
      debugPrint('🎉🎉🎉Cached messages: $cachedMessages');
      if (cachedMessages.isNotEmpty) {
        return Right(cachedMessages);
      }
    } catch (e) {
      debugPrint('No cached messages found: $e');
    }

    if (await networkInfo.isConnected) {
      try {
        final remoteMessages = await remoteDataSource.getMessages(chatId);
        final messageModels = remoteMessages
            .map((msg) => MessageModel.fromEntity(msg))
            .toList();
        await localDataSource.cacheMessages(chatId, messageModels);
        return Right(remoteMessages);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        final remoteMessages = await remoteDataSource.getMessages(chatId);
        // Convert List<Message> to List<MessageModel> before caching
        final messageModels = remoteMessages
            .map((msg) => MessageModel.fromEntity(msg))
            .toList();
        await localDataSource.cacheMessages(chatId, messageModels);
        return Right(remoteMessages);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(int messageId, int chatId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMessage(messageId, chatId);
        await localDataSource.removeMessage(messageId);
        return const Right(null);
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
        final chatModel = ChatModel.fromEntity(createdChat);
        await localDataSource.cacheChats([chatModel]);
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
        await localDataSource.removeChat(chatId);
        return const Right(null);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(Failure('user is offline'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorite(int chatId) async {
    try {
      await localDataSource.addFavoriteChat(chatId);
      debugPrint('✨✨✨✨Error in addToFavorite: Successfully added to favorite $chatId');
      return const Right(null);
    } catch (e) {
      debugPrint('✨✨✨✨Error in addToFavorite: $e');
      return Left(Failure(e.toString()));
    }
  }
  @override
  Future <Either<Failure, void>> removeFromFavorite(int chatId) async {
    try {
      await localDataSource.removeFavoriteChat(chatId);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getFavoriteChats() async {
    try {
      final favoriteChats = await localDataSource.getFavoriteChats();
      return Right(favoriteChats);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
