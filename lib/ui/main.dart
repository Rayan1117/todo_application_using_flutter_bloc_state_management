import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/auth_ui/main_auth_page.dart';
import 'package:todo/authbloc/auth_bloc.dart';
import 'package:todo/taskbloc/task_bloc.dart';
import 'package:todo/ui/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('TODO');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TaskBloc()),
        BlocProvider(create: (context) => AuthBloc())
      ],
      child: const MaterialApp(
        home: MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkAppState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else if (snapshot.data == 1) {
          return const TaskPage();
        } else {
          return const MainAuthPage();
        }
      },
    );
  }

  Future<int> checkAppState() async {
    final state = await Hive.box("TODO").get("state", defaultValue: 0); 
    return state;
  }
}
