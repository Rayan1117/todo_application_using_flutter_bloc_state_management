import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/json_model/json_model.dart';
import 'package:todo/ui/completed_task.dart';
import 'package:todo/taskbloc/bloc/task_bloc.dart';
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
    BlocProvider.of<TaskBloc>(context).add(
      AddNewTaskEvent(),
    );
    try {
      getTasks();
    } catch (e) {
      print(e);
    }
  }

  getTasks() async {
    var task = await FirebaseFirestore.instance.collection('Tasks').get();
    var taskModel = task.docs.map((value) =>
        TaskModel(name: value['name'], description: value["description"]));
    print(taskModel.toList()[0].description);
  }

  final GlobalKey<FormFieldState> titleKey = GlobalKey<FormFieldState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final blocInstance = BlocProvider.of<TaskBloc>(context);
    return BlocConsumer<TaskBloc, TaskState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Tasks"),
          ),
          body: (state is AddNewTaskState)
              ? (blocInstance.title.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: blocInstance.title.length,
                        itemBuilder: (context, index) => Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
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
                                            blocInstance.title[index];
                                        descController.text =
                                            blocInstance.description[index];
                                        return SizedBox(
                                          height: 50,
                                          child: Dialog(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
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
                                      blocInstance.title[index],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text(blocInstance.description[index]),
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
                      blocInstance.add(AddNewTaskEvent()),
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
    );
  }
}
