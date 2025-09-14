// ignore: file_names
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? avatar;
  final String? firstName;
  final String? lastName;
  final String? lastlogin;
  final String? dateJoined;
  final String? phoneNumber;
  final String? bio;
  final String? birthDate;
  final String? gender;

  const User({
    this.id,
    this.username,
    this.email,
    this.password,
    this.avatar,
    this.firstName,
    this.lastName,
    this.lastlogin,
    this.dateJoined,
    this.phoneNumber,
    this.bio,
    this.birthDate,
    this.gender,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    password,
    avatar,
    firstName,
    lastName,
    lastlogin,
    dateJoined,
    phoneNumber,
    bio,
    birthDate,
    gender,
  ];
}
