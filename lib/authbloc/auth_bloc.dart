import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final todo = Hive.box("TODO");

  AuthBloc() : super(AuthInitial()) {
    on<ShowLoginPageEvent>(
      (event, emit) => emit(
        ShowLoginPageState(),
      ),
    );
    on<ShowRegistrationPageEvent>(
      (event, emit) => emit(
        ShowRegistrationPageState(),
      ),
    );

    on<LoginEvent>((event, emit) async {
      try {
        if (event.key.currentState!.validate()) {
          final http.Response response = await http
              .post(
                Uri.parse("http://192.168.7.62:5000/todo/login"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(
                  {"email": event.email, "password": event.password},
                ),
              )
              .catchError(
                (err) => throw err,
              );

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            final token = body['token'];
            todo.put("token", token);
            emit(LoggedInState());
            todo.put("state", 1);
          }
        }
      } catch (err) {
        emit(
          AuthErrorState(
            error: err.toString(),
          ),
        );
      }
    });

    on<RegisterEvent>((event, emit) async {
      try {
        final http.Response redirectRes;
        if (event.key.currentState!.validate()) {
          final response = await http.post(
              Uri.parse("http://192.168.1.62:5000/todo/register"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "user": event.name,
                "email": event.email,
                "password": event.password
              }));
          if (response.statusCode == 308) {
            final redirectUrl = response.headers["location"];
            redirectRes = await http
                .post(Uri.parse("http://192.168.1.62:5000$redirectUrl"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "user": event.name,
                      "email": event.email,
                      "password": event.password
                    }))
                .catchError((err) => throw err);
            if (redirectRes.statusCode == 200) {
              final token = jsonDecode(redirectRes.body)['token'];
              todo.put("token", token);
              todo.put("state", 1);
              emit(
                LoggedInState(),
              );
              todo.put("state", 1);
            }
          }
        }
      } catch (err) {
        emit(
          AuthErrorState(
            error: err.toString(),
          ),
        );
      }
    });
    on<LogoutEvent>((event,emit){
      todo.put("state", 0);
      todo.delete("token");
      emit(LoggedOutState());
    });
  }
}
