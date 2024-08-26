part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthErrorState extends AuthState{
  final String error;

  AuthErrorState({required this.error});
}

final class LoggedInState extends AuthState{

}

final class ShowLoginPageState extends AuthState{
  
}

final class ShowRegistrationPageState extends AuthState{
  
}

final class LoggedOutState extends AuthState{
  
} 