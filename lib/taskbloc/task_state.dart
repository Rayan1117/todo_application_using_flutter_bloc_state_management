part of 'task_bloc.dart';

@immutable
sealed class TaskState {}

final class TaskInitial extends TaskState {}

final class AddNewTaskState extends TaskState {
  final List<String> title;
  final List<String> description;
  final List<bool> check;
  final List<int> taskid;
  final bottomIndex=0;
  AddNewTaskState( {required this.taskid,required this.title, required this.description, required this.check});
}

final class DeleteTaskState extends TaskState {}

final class ErrorState extends TaskState {
  final String? msg;

  ErrorState({required this.msg});
}
final class EditTaskState extends TaskState{
  
}

final class ShowCompletedTaskState extends TaskState{
  final bottomIndex=1;
  final List<String> compTitle;
  final List<String> compDescription;

  ShowCompletedTaskState({required this.compTitle, required this.compDescription});
  
}

class TaskUncheckState extends TaskState{
  
}