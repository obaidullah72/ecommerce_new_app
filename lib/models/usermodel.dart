// models/usermodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String gender;
  final String imageUrl;

  UserModel({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.dateOfBirth,
    required this.gender,
    required this.imageUrl,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      dateOfBirth: data['date_of_birth'] != null
          ? (data['date_of_birth'] as Timestamp).toDate()
          : null,
      gender: data['gender'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}
