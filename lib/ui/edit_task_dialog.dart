import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';

Widget editDialog(
    BuildContext context,
    TaskBloc blocInstance,
    int index,
    TextEditingController titleController,
    TextEditingController descController,
    GlobalKey titleKey) {
  return Column(
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
                    title: titleController.text,
                    description: descController.text,
                    index: index),
              );
              Navigator.of(context).pop();
            },
            child: const Text("save"),
          ),
        ],
      )
    ],
  );
}
