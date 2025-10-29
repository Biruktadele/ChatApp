import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.password,
    required super.avatar,
    required super.firstName,
    required super.lastName,
    required super.lastlogin,
    required super.dateJoined,
    required super.phoneNumber,
    required super.bio,
    required super.birthDate,
    required super.gender,
  });
  //product model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
      avatar: user.avatar,
      firstName: user.firstName,
      lastName: user.lastName,
      lastlogin: user.lastlogin,
      dateJoined: user.dateJoined,
      phoneNumber: user.phoneNumber,
      bio: user.bio,
      birthDate: user.birthDate,
      gender: user.gender,
    );
  }
  //factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '', // Add only if password is returned (usually it's not)
      avatar: json['avatar'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      lastlogin: json['lastlogin'] ?? '',
      dateJoined: json['dateJoined'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      bio: json['bio'] ?? '',
      birthDate: json['birthday'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
  //to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'avatar': avatar,
      'firstName': firstName,
      'lastName': lastName,
      'lastlogin': lastlogin,
      'dateJoined': dateJoined,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'birthDate': birthDate,
      'gender': gender,
    };
  }

  UserModel fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
      avatar: user.avatar,
      firstName: user.firstName,
      lastName: user.lastName,
      lastlogin: user.lastlogin,
      dateJoined: user.dateJoined,
      phoneNumber: user.phoneNumber,
      bio: user.bio,
      birthDate: user.birthDate,
      gender: user.gender,
    );
  }
  Map<String, dynamic> toLoginJson() {
    return {'username': username, 'password': password};
  }
  Map<String, dynamic> toRegisterJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'avatar': avatar,
      'first_name': firstName,
      'last_name': lastName,
      'last_login': lastlogin,
      'date_joined': dateJoined,
      'phone_number': phoneNumber,
      'bio': bio,
      'birthday': birthDate,
      'gender': gender,
    };
  }
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      password: password,
      avatar: avatar,
      firstName: firstName,
      lastName: lastName,
      lastlogin: lastlogin,
      dateJoined: dateJoined,
      phoneNumber: phoneNumber,
      bio: bio,
      birthDate: birthDate,
      gender: gender,
    );
  }
  
}
