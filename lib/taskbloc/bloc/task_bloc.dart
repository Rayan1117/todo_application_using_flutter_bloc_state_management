import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

  int saveTask(event) {
    if (event.titleKey!.currentState!.validate()) {
      (event is AddNewTaskEvent)
          ? {
              title.add(event.title!.text.toString()),
              description.add(
                event.description!.text.toString(),
              ),
              check.add(event.check)
            }
          : {
              title[event.index] = event.title.text,
              description[event.index] = event.description.text,
            };
      event.title!.clear();
      event.description!.clear();
      event.titleKey!.currentState!.save();
      updateTask(title: title, description: description, check: check);
      return 1;
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
      (event, emit) {
        (event.title != null &&
                event.description != null &&
                event.titleKey != null)
            ? (saveTask(event) == 1)
                ? {
                    emit(
                      AddNewTaskState(
                          title: title, description: description, check: check),
                    )
                  }
                : emit(
                    ErrorState(msg: 'something went wrong'),
                  )
            : emit(
                AddNewTaskState(
                  title: const [],
                  description: const [],
                  check: const [],
                ),
              );
      },
    );
    on<DeleteTaskEvent>(
      (event, emit) {
        title.removeAt(event.index);
        description.removeAt(event.index);
        check.removeAt(event.index);
        updateTask(title: title, description: description, check: check);
        emit(
          DeleteTaskState(),
        );
        emit(AddNewTaskState(
            title: title, description: description, check: check));
      },
    );
    on<EditTaskEvent>(
      (event, emit) {
        if (saveTask(event) == 1) {
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
