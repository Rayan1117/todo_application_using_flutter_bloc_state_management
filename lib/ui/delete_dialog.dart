import "package:flutter/material.dart";

class DeleteDialog extends StatelessWidget{
  final VoidCallback deleteTask;
  final BuildContext context;
  const DeleteDialog({super.key,  required this.deleteTask,required this.context});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("do you want to delete?"),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('no'),
        ),
        ElevatedButton(
          onPressed: () {
            deleteTask.call();
            Navigator.of(context).pop();
          },
          child: const Text('yes'),
        )
      ],
    );
  }
}
