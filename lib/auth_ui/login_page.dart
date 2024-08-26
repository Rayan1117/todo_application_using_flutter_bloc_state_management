import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:todo/authbloc/auth_bloc.dart";
import "package:todo/ui/task_page.dart";

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoggedInState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const TaskPage(),
            ),(route)=>route.isFirst,
          );
        }
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(70),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      validator: (val)=>(val!.trim().isEmpty)?"email must be entered":null,
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: "enter  your email",
                        label: Text(
                          "Email",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                       validator: (val)=>(val!.trim().isEmpty)?"password must be entered":null,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        hintText: "enter your password",
                        label: Text(
                          "Password",
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context).add(
                        LoginEvent(
                          key: formKey,
                          email: emailController.text,
                          password: passwordController.text,
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context).add(
                        ShowRegistrationPageEvent(),
                      );
                    },
                    child: const Text("create new account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
