import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';
import 'package:todo/ui/delete_dialog.dart';

class CompletedTask extends StatelessWidget {
  const CompletedTask({super.key});

  @override
  Widget build(BuildContext context) {
    final blocInstance = BlocProvider.of<TaskBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BlocConsumer<TaskBloc, TaskState>(
          builder: (context, state) => (state is ShowCompletedTaskState)
              ? (state.compTitle.isNotEmpty)
                  ? ListView.builder(
                      itemCount: state.compTitle.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Slidable(
                            endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  Checkbox(
                                      value: (state is TaskUncheckState)
                                          ? true
                                          : false,
                                      onChanged: (_) {
                                        blocInstance
                                            .add(TaskUncheckEvent(index: index));
                                      })
                                ]),
                            child: InkWell(
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return DeleteDialog(
                                    context: context,
                                    deleteTask: () => blocInstance.add(
                                      DeleteCompTaskEvent(index: index),
                                    ),
                                  );
                                },
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(30),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.compTitle[index],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Text(state.compDescription[index]),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text("no task completed"),
                    )
              : const Center(
                  child: Text("something went wrong"),
                ),
          listener: (previous, current) {}),
    );
  }
}
