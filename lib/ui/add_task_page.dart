import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';

class AddTaskPage extends StatelessWidget {
  AddTaskPage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            BlocProvider.of<TaskBloc>(context).add(
              ShowTasksEvent(),
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
          (state is ErrorState)
              ? ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.msg.toString(),
                    ),
                  ),
                )
              : null;
        },
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
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
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          print(descController.text);
          BlocProvider.of<TaskBloc>(context).add(
            AddNewTaskEvent(
                title: titleController,
                description: descController,
                formKey: formKey),
          );
        },
        child: const Text("save"),
      ),
    );
  }
}
