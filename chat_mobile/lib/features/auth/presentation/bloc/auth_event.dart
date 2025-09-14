part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class LoginUser extends AuthEvent {
  final String username;
  final String password;
  const LoginUser(this.username,this.password);

  @override
  List<Object?> get props => [username,password];
}

final class CheckToken extends AuthEvent {
  const CheckToken();
}


final class RegisterUser extends AuthEvent {
  final String username;
  final String email;
  final String password;


  const RegisterUser(this.username ,this.email,this.password);

  @override
  List<Object?> get props => [username,email,password];
}

final class LogoutUser extends AuthEvent {
  const LogoutUser();

  @override
  List<Object?> get props => [];
}
