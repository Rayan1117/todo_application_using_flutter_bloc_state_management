part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final GlobalKey<FormState> key;
  final String email;
  final String password;
  final String name;
  RegisterEvent({
    required this.key,
    required this.email,
    required this.password,
    required this.name,
  });
}

class LoginEvent extends AuthEvent {
  final GlobalKey<FormState> key;
  final String email;
  final String password;
  LoginEvent({required this.key, required this.email, required this.password});
}

class ShowLoginPageEvent extends AuthEvent{

}

class ShowRegistrationPageEvent extends AuthEvent{
  
}

class LogoutEvent extends AuthEvent{
  
}