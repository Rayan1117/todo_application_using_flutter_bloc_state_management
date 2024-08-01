import 'dart:convert';

TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
  String name;
  String description;

  TaskModel({
    required this.name,
    required this.description,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
      };
}
