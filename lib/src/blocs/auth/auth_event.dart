// lib/src/blocs/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthAddressUpdateRequested extends AuthEvent {
  final String address;
  const AuthAddressUpdateRequested(this.address);
  @override
  List<Object?> get props => [address];
}
