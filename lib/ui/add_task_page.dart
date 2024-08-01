import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';

class AddTaskPage extends StatelessWidget {
  AddTaskPage({super.key});

  final GlobalKey<FormFieldState> titleKey = GlobalKey<FormFieldState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            BlocProvider.of<TaskBloc>(context).add(
              AddNewTaskEvent(),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "New Task",
        ),
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          (state is AddNewTaskState) ? Navigator.of(context).pop() : null;
        },
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              TextFormField(
                key: titleKey,
                validator: (value) {
                  return (value!.trim() == "") ? "do not leave empty" : null;
                },
                onSaved: (_) => Fluttertoast.showToast(msg: "task saved"),
                controller: titleController,
                decoration: const InputDecoration(
                  label: Text("Title"),
                  hintText: "enter a task title",
                ),
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  label: Text("Description"),
                  hintText: "enter about your task",
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          BlocProvider.of<TaskBloc>(context).add(
            AddNewTaskEvent(
                title: titleController,
                description: descController,
                titleKey: titleKey),
          );
        },
        child: const Text("save"),
      ),
    );
  }
}
