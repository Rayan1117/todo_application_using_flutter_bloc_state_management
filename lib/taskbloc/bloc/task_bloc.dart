import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  int pageIndex = 0;
  final todo=Hive.box('TODO');
  final List<String> title = [];
  final List<String> description = [];
  final List<String> compTitle = [];
  final List<String> compDescription = [];
  final List<bool> check = [];
  TaskBloc() : super(TaskInitial()) {
    on<AddNewTaskEvent>(
      (event, emit) {
        int saveTask() {
          if (event.titleKey!.currentState!.validate()) {
            title.add(event.title!.text.toString());
            description.add(
              event.description!.text.toString(),
            );
            check.add(event.check);
            event.title!.clear();
            event.description!.clear();
            event.titleKey!.currentState!.save();
            return 1;
          }
          return 0;
        }

        (event.title != null &&
                event.description != null &&
                event.titleKey != null)
            ? (saveTask() == 1)
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
        emit(
          DeleteTaskState(),
        );
        emit(AddNewTaskState(
            title: title, description: description, check: check));
      },
    );
    on<EditTaskEvent>(
      (event, emit) {
        title[event.index] = event.title;
        description[event.index] = event.description;
        emit(EditTaskState());
        emit(
          AddNewTaskState(title: title, description: description, check: check),
        );
      },
    );
    on<TaskCheckedEvent>(
      (event, emit) {
        check.removeAt(event.index);
        compTitle.add(title[event.index]);
        compDescription.add(description[event.index]);
        title.removeAt(event.index);
        description.removeAt(event.index);
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
