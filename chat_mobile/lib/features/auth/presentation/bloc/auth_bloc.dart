import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc(this.userRepository) : super(const AuthInitial()) {
    on<LogoutUser>(_onLogoutUser);
    on<LoginUser>(_onLoginUser);
    on<RegisterUser>(_onRegisterUser);
    on<GetAllUsers>(_onGetAllUsers);
    on<LoadMeEvent>(_onLoadMeEvent);
    on<UpdatePhotoEvent>(_onUpdatePhotoEvent);
    on<UpdateMeEvent>(_onUpdateMeEvent);
  }



  Future<void> _onLoginUser(LoginUser event, Emitter<AuthState> emit) async {
    emit(const loginLoading());

    final user = User(username: event.username, password: event.password);

    final userModel = UserModel.fromEntity(user);
    final result = await userRepository.loginUser(userModel);

    result.fold(
      (failure) => emit(loginFailure(failure)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(const RegisterLoading());
    final user = User(
      username: event.username,
      email: event.email,
      password: event.password,
    );
    final userModel = UserModel.fromEntity(user);
    final result = await userRepository.registerUser(userModel);
    result.fold(
      (failure) => emit(RegisterFailure(failure)),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<AuthState> emit) async {
    emit(const LogoutLoading());

    final result = await userRepository.logoutUser();
    result.fold(
      (failure) => emit(LogoutFailure(failure)),
      (_) => emit(const LogoutSuccess()),
    );
  }

  Future<void> _onGetAllUsers(GetAllUsers event, Emitter<AuthState> emit) async {
    emit(const GetAllUsersLoading());

    final result = await userRepository.getAllUsers();

    result.fold(
      (failure) => emit(GetAllUsersFailure(failure)),
      (users) => emit(GetAllUsersSuccess(users)),
    );
  }
  Future<void> _onLoadMeEvent(LoadMeEvent event, Emitter<AuthState> emit) async {
    emit(const MeLoadingState());
    debugPrint('🪂 Loading current user data');
    final result = await userRepository.me();

    result.fold(
      (failure) => emit(MeFailureState(failure)),
      (user) => emit(MeSuccessState(user)),
    );
  }

  Future<void> _onUpdatePhotoEvent(UpdatePhotoEvent event, Emitter<AuthState> emit) async {
    emit(const MeLoadingState());

    final result = await userRepository.updatePhoto(event.photoBytes);

    result.fold(
      (failure) => emit(MeFailureState(failure)),
      (user) => emit(UpdatePhotoState(user)),
    );
  }
  Future<void> _onUpdateMeEvent(UpdateMeEvent event, Emitter<AuthState> emit) async {
    emit(const MeLoadingState());

    final result = await userRepository.updateMe(event.field, event.value);

    result.fold(
      (failure) => emit(MeFailureState(failure)),
      (user) => emit(UpdateMeState(user)),
    );
  }

}
