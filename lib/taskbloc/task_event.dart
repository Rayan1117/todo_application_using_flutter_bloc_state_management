part of 'task_bloc.dart';

@immutable
sealed class TaskEvent {}

class AddNewTaskEvent extends TaskEvent {
  final TextEditingController title;
  final TextEditingController description;
  final GlobalKey<FormState> formKey;
  final bool check;
  int? statusCode;
  int? taskid;

  AddNewTaskEvent(
      {required this.formKey,required this.title,required this.description, this.check = false});
}

class DeleteTaskEvent extends TaskEvent {
  final int index;

  DeleteTaskEvent({required this.index});
}

class EditTaskEvent extends TaskEvent {
  final int index;
  final TextEditingController title;
  final TextEditingController description;
  final GlobalKey<FormFieldState>? formKey;
  final bool check;
  int? statusCode;

  EditTaskEvent(
      {required this.title,
      required this.description,
      required this.index,
      this.check = false, required this.formKey});
}

class TaskCheckedEvent extends TaskEvent {
  final int index;

  TaskCheckedEvent({required this.index});
}

class ShowCompletedTaskEvent extends TaskEvent {}

class DeleteCompTaskEvent extends TaskEvent {
  final int index;
  DeleteCompTaskEvent({required this.index});
}

class TaskUncheckEvent extends TaskEvent {
  final int index;
  TaskUncheckEvent({required this.index});
}


class InitialFetchEvent extends TaskEvent{
  
}

class ShowTasksEvent extends TaskEvent{
  
}