


import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local_data/user_local_data_source.dart';
import '../datasources/remote_data/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

 @override
 Future<Either<Failure, void>> logoutUser() async {
   if (await networkInfo.isConnected) {
     try {
       await remoteDataSource.deleteToken();
       return const Right(null);
     } catch (e) {
       return Left(Failure(e.toString()));
     }
   } else {
     return  Left(Failure('user is offline'));
   }
 }

 @override
 Future<Either<Failure, User>> registerUser(User user) async {
   if (await networkInfo.isConnected) {
     try {
       final userModel = UserModel.fromEntity(user);
       final remoteUser = await remoteDataSource.registerUser(userModel);
       return Right(remoteUser);
     } catch (e) {
       return Left(Failure(e.toString()));
     }
   } else {
     return Left(Failure('user is offline'));
   }
 }

 @override
 Future<Either<Failure, User>> loginUser(User user) async {
   if (await networkInfo.isConnected) {
     try {
      //  final userModel = UserModel.fromEntity(user);
       final remoteUser = await remoteDataSource.loginUser(user);
       debugPrint('user from repo $remoteUser');
       return Right(remoteUser);
     } catch (e) {
       debugPrint(e.toString());
       return Left(Failure(e.toString()));
     }
   } else {
     print('user is offline');
     return Left(Failure('user is offline'));
   }
 }
 @override
 Future<Either<Failure, String>> getToken() async {
   if (await networkInfo.isConnected) {
     try {
       final remoteUser = await remoteDataSource.getToken();
       if (remoteUser != null) {
         return Right(remoteUser);
       } else {
         return Left(Failure('No token found'));
       }
     } catch (e) {
       return Left(Failure(e.toString()));
     }
   } else {
     return Left(Failure('user is offline'));
   }
 }
}