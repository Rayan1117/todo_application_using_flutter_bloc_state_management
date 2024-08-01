import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';
import 'package:todo/ui/task_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  runApp(BlocProvider(
    create: (context) => TaskBloc(),
    child: const MaterialApp(
      home: MainApp(),
    ),
  ),);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskPage();
  }
}
