
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id; // MongoDB _id.$oid
  final String userId; // UUID
  final String userName;
  final String firstName;
  final String lastName;
  final String password;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String email;
  final bool isEmailVerified;
  final String emailOtp;
  final String phoneOtp;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.email,
    required this.isEmailVerified,
    required this.emailOtp,
    required this.phoneOtp,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List <Object> get props {
    return [
      id,
      userId,
      userName,
      firstName,
      lastName,
      password,
      phoneNumber,
      isPhoneVerified,
      email,
      isEmailVerified,
      emailOtp,
      phoneOtp,
      role,
      createdAt,
      updatedAt,
    ];
  }
}
