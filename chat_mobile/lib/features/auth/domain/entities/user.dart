// ignore: file_names
import 'package:equatable/equatable.dart';

class User extends Equatable {
  String? username;
  int? id;
  String? email;
  String? password;
  String? avatar;
  String? firstName;
  String? lastName;
  String? lastlogin;
  String? dateJoined;
  String? phoneNumber;
  String? bio;
  String? birthDate;
  String? gender;

  User({
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
