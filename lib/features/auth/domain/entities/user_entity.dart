import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'employee' | 'employer'
  final bool phoneVerified;
  final String status;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.phoneVerified,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, phoneVerified, status];
}
