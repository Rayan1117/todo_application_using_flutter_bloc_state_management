import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/authbloc/auth_bloc.dart';
import 'package:todo/ui/task_page.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController cPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(70),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Text(
                      "Create An Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    buildRegistration(
                      registration: [
                        {
                          "helper": "Enter username",
                          "controller": nameController,
                          "label": "Username",
                          "validator": (String val) => (val.trim().isEmpty)
                              ? "Username must be entered"
                              : null,
                        },
                        {
                          "helper": "Enter your email",
                          "controller": emailController,
                          "label": "Email",
                          "validator": (String val) => (val.trim().isEmpty)
                              ? "Email must be entered"
                              : null,
                        },
                        {
                          "helper": "Enter your password",
                          "controller": passController,
                          "label": "Password",
                          "validator": (String val) => (val.trim().isEmpty)
                              ? "Password must be entered"
                              : null,
                        },
                        {
                          "helper": "Confirm your password",
                          "controller": cPassController,
                          "label": "Confirm Password",
                          "validator": (String val) => (val.trim().isEmpty)
                              ? "Password must be entered"
                              : (val.trim() != passController.text)
                                  ? "Passwords does not match"
                                  : null,
                        },
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(
                          RegisterEvent(
                            key: formKey,
                            email: emailController.text,
                            password: passController.text,
                            name: nameController.text,
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(
                          ShowLoginPageEvent(),
                        );
                      },
                      child: const Text("Already have an account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, AuthState state) {
        if (state is LoggedInState) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TaskPage(),
            ),
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
    );
  }

  Widget buildRegistration({
    required List<Map<String, dynamic>> registration,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: registration.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            validator: (value) => registration[index]['validator']!(value),
            controller: registration[index]['controller'],
            decoration: InputDecoration(
              hintText: registration[index]['helper'],
              labelText: registration[index]['label'],
            ),
          ),
        ),
      ),
    );
  }
}
