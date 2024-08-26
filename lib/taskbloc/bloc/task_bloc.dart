import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  int pageIndex = 0;
  final todo = Hive.box('TODO');
  late List<String> title = [];
  late List<String> description = [];
  late List<String> compTitle = [];
  late List<String> compDescription = [];
  late List<bool> check = [];

  void nullTheDuplicates() {
    title = [];
    description = [];
    compTitle = [];
    compDescription = [];
    check = [];
    print(title + description + compTitle + compDescription);
  }

  Future<int> checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    return (connectivityResult.first == ConnectivityResult.mobile ||
            connectivityResult.first == ConnectivityResult.wifi ||
            connectivityResult.first == ConnectivityResult.ethernet)
        ? 1
        : 0;
  }

  Future<Map<String, dynamic>> deleteTask(int taskId) async {
    final http.Response response = await http.delete(
        Uri.parse("http://192.168.1.62:5000/todo/auth/deletetask?id=$taskId"),
        headers: {"authorization": "Bearer ${todo.get("token")}"});
    final msg = jsonDecode(response.body)['message'];
    if (response.statusCode == 200) {
      return {"returned": 1, "msg": msg};
    }
    return {"returned": 0, "msg": msg};
  }

  Future<String> postTask(AddNewTaskEvent event) async {
    final http.Response response = await http.post(
      Uri.parse("http://192.168.1.62:5000/todo/auth/addtask"),
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer ${todo.get("token")}"
      },
      body: jsonEncode(
        {"title": event.title.text, "description": event.description.text},
      ),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return "posted";
    }
    return body['message'];
  }

  Future<int> saveTask(event, emit) async {
    try {
      if (event is AddNewTaskEvent) {
        if (event.formKey.currentState!.validate()) {
          if (await checkConnectivity() == 1) {
            final upload = await postTask(event);
            if (upload == "posted") {
              title.add(
                event.title.text.toString(),
              );
              description.add(
                event.description.text.toString(),
              );
              check.add(event.check);
            } else {
              emit(
                ErrorState(msg: upload),
              );
              return 0;
            }
            event.title.clear();
            event.description.clear();
            event.formKey.currentState!.save();
            updateTask(title: title, description: description, check: check);
            return 1;
          } else {
            emit(
              ErrorState(msg: "no internet"),
            );
          }
        }
      }
    } catch (err) {
      emit(
        ErrorState(
          msg: err.toString(),
        ),
      );
    }
    return 0;
  }

  void updateTask(
      {required List title, required List description, required List check}) {
    todo.put('title', title);
    todo.put('description', description);
    todo.put('check', check);
  }

  void updateCompletedTask(
      {required List compTitle, required List compDescription}) {
    todo.put('compTitle', compTitle);
    todo.put('compDescription', compDescription);
  }

  TaskBloc() : super(TaskInitial()) {
    on<ShowTasksEvent>((event, emit) {
      emit(AddNewTaskState(
          title: title, description: description, check: check));
    });

    on<InitialFetchEvent>((event, emit) {
      nullTheDuplicates();
      title.addAll((todo.get('title') ?? []).cast<String>());
      description.addAll((todo.get('description') ?? []).cast<String>());
      check.addAll((todo.get('check') ?? []).cast<bool>());
      compTitle.addAll((todo.get('compTitle') ?? []).cast<String>());
      compDescription
          .addAll((todo.get('compDescription') ?? []).cast<String>());
      emit(AddNewTaskState(
          title: title, description: description, check: check));
    });
    on<AddNewTaskEvent>(
      (event, emit) async {
        (await saveTask(event, emit) == 1)
            ? {
                emit(
                  AddNewTaskState(
                      title: title, description: description, check: check),
                )
              }
            : null;
      },
    );
    on<DeleteTaskEvent>(
      (event, emit) async {
        try{
        if (await checkConnectivity() == 1) {
          final result = await deleteTask(7);
          final returned = result['returned'];
          if (returned==1) {
            title.removeAt(event.index);
            description.removeAt(event.index);
            check.removeAt(event.index);
            updateTask(title: title, description: description, check: check);
            emit(
              DeleteTaskState(),
            );
            emit(AddNewTaskState(
                title: title, description: description, check: check));
          } else {
            ErrorState(msg: result['msg']);
          }
        } else {
          ErrorState(msg: "no internet");
        }}catch(err){
          print(err);
        }
      },
    );
    on<EditTaskEvent>(
      (event, emit) async {
        if (await saveTask(event, emit) == 1) {
          emit(EditTaskState());
          emit(
            AddNewTaskState(
                title: title, description: description, check: check),
          );
        }
      },
    );
    on<TaskCheckedEvent>(
      (event, emit) {
        check.removeAt(event.index);
        compTitle.add(title[event.index]);
        compDescription.add(description[event.index]);
        title.removeAt(event.index);
        description.removeAt(event.index);
        updateCompletedTask(
            compTitle: compTitle, compDescription: compDescription);
        updateTask(title: title, description: description, check: check);
        emit(
          AddNewTaskState(
            title: title,
            description: description,
            check: check,
          ),
        );
      },
    );
    on<ShowCompletedTaskEvent>(
      (event, emit) => emit(
        ShowCompletedTaskState(
          compTitle: compTitle,
          compDescription: compDescription,
        ),
      ),
    );
    on<DeleteCompTaskEvent>(
      (event, emit) {
        compTitle.removeAt(event.index);
        compDescription.removeAt(event.index);
        updateCompletedTask(
            compTitle: compTitle, compDescription: compDescription);
        emit(
          ShowCompletedTaskState(
              compTitle: compTitle, compDescription: compDescription),
        );
      },
    );
    on<TaskUncheckEvent>(
      (event, emit) {
        title.add(compTitle[event.index]);
        description.add(compDescription[event.index]);
        check.add(false);
        compTitle.removeAt(event.index);
        compDescription.removeAt(event.index);
        updateTask(title: title, description: description, check: check);
        updateCompletedTask(
            compTitle: compTitle, compDescription: compDescription);
        emit(TaskUncheckState());
        emit(
          ShowCompletedTaskState(
            compTitle: compTitle,
            compDescription: compDescription,
          ),
        );
      },
    );
  }
}
