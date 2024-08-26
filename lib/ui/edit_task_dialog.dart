import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';

Widget editDialog(
    BuildContext context,
    TaskBloc blocInstance,
    int index,
    TextEditingController titleController,
    TextEditingController descController,
    GlobalKey<FormFieldState> titleKey) {
  return BlocListener<TaskBloc, TaskState>(
    listener: (context, state) {
      (state is EditTaskState) ? Navigator.of(context).pop() : null;
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: titleController,
          key: titleKey,
          validator: (value) {
            return (value!.trim() == "") ? "do not leave empty" : null;
          },
          onSaved: (_) => Fluttertoast.showToast(msg: "task saved"),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("no"),
            ),
            ElevatedButton(
              onPressed: () {
                blocInstance.add(
                  EditTaskEvent(
                      formKey: titleKey,
                      title: titleController,
                      description: descController,
                      index: index),
                );
              },
              child: const Text("save"),
            ),
          ],
        )
      ],
    ),
  );
}
