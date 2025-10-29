part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

//// Login ///
final class loginLoading extends AuthState {
  const loginLoading();
}

final class LoginSuccess extends AuthState {
  final User user;
  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class loginFailure extends AuthState {
  final Failure failure;
  const loginFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

//// Register ////
final class RegisterLoading extends AuthState {
  const RegisterLoading();
}

final class RegisterSuccess extends AuthState {
  final User user;
  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class RegisterFailure extends AuthState {
  final Failure failure;
  const RegisterFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

//// Logout ////
final class LogoutLoading extends AuthState {
  const LogoutLoading();
}

final class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

final class LogoutFailure extends AuthState {
  final Failure failure;
  const LogoutFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

//// Get All Users ////
final class GetAllUsersLoading extends AuthState {
  const GetAllUsersLoading();
}

final class GetAllUsersSuccess extends AuthState {
  final List<User> users;
  const GetAllUsersSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

final class GetAllUsersFailure extends AuthState {
  final Failure failure;
  const GetAllUsersFailure(this.failure);

  @override
  List<Object?> get props => [failure]; 
}


//////Me//////
final class MeLoadingState extends AuthState {
  const MeLoadingState();
}
final class MeSuccessState extends AuthState {
  final User user;
  const MeSuccessState(this.user);

  @override
  List<Object?> get props => [user];
}

final class MeFailureState extends AuthState {
  final Failure failure;
  const MeFailureState(this.failure);

  @override
  List<Object?> get props => [failure];
}
final class UpdateMeState extends AuthState {
  final User user;
  const UpdateMeState(this.user);
  @override
  List<Object?> get props => [user];
}
final class UpdatePhotoState extends AuthState {
  final User user;
  const UpdatePhotoState(this.user);
  @override
  List<Object?> get props => [user];
}