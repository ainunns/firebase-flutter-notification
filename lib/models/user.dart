import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
