import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/authbloc/auth_bloc.dart';
import 'package:todo/ui/completed_task.dart';
import 'package:todo/taskbloc/task_bloc.dart';
import 'package:todo/ui/add_task_page.dart';
import 'package:todo/ui/delete_dialog.dart';
import 'package:todo/ui/edit_task_dialog.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final slidableKey = GlobalKey<State>();
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TaskBloc>(context).add(InitialFetchEvent());
  }

  final GlobalKey<FormFieldState> titleKey = GlobalKey<FormFieldState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final blocInstance = BlocProvider.of<TaskBloc>(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoggedOutState) {
          Navigator.of(context).pop();
        }
      },
      child: BlocConsumer<TaskBloc, TaskState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                  },
                )
              ],
              title: const Text("Tasks"),
            ),
            body: (state is AddNewTaskState)
                ? (state.title.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: state.title.length,
                          itemBuilder: (context, index) => Slidable(
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => DeleteDialog(
                                            deleteTask: () {
                                              blocInstance.add(
                                                DeleteTaskEvent(index: index),
                                              );
                                            },
                                            context: context));
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          titleController.text =
                                              state.title[index];
                                          descController.text =
                                              state.description[index];
                                          return SizedBox(
                                            height: 50,
                                            child: Dialog(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: editDialog(
                                                    context,
                                                    blocInstance,
                                                    index,
                                                    titleController,
                                                    descController,
                                                    titleKey),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(30),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: (state.check.isNotEmpty)
                                            ? state.check[index]
                                            : false,
                                        onChanged: (value) {
                                          blocInstance.add(
                                            TaskCheckedEvent(index: index),
                                          );
                                        },
                                      ),
                                      Text(
                                        state.title[index],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Text(state.description[index]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "no tasks found",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                : const CompletedTask(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (value) => {
                (value == 1)
                    ? {
                        blocInstance.add(ShowCompletedTaskEvent()),
                        blocInstance.pageIndex = 1
                      }
                    : {
                        blocInstance.add(ShowTasksEvent()),
                        blocInstance.pageIndex = 0
                      }
              },
              currentIndex: (state is ShowCompletedTaskState) ? 1 : 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.task), label: "tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.verified), label: "completed")
              ],
            ),
          );
        },
        listener: (BuildContext context, TaskState state) {
          (state is DeleteTaskState)
              ? Fluttertoast.showToast(msg: "deleted task")
              : null;
          (state is EditTaskState)
              ? Fluttertoast.showToast(msg: "edited task")
              : null;
          if (state is ShowCompletedTaskState) {
            setState(() {});
          }
        },
      ),
    );
  }
}
