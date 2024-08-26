import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:todo/auth_ui/login_page.dart";
import "package:todo/auth_ui/registration_page.dart";
import "package:todo/authbloc/auth_bloc.dart";

class MainAuthPage extends StatelessWidget {
  const MainAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => (state is ShowRegistrationPageState)
          ? RegistrationPage()
          : LoginPage(),
    );
  }
}
