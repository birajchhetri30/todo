class Task {
  final int? index;
  final bool status;
  final String task;

  const Task({
    this.index,
    required this.status,
    required this.task,
  });

  Map<String, Object?> toJson() => {
        TaskFields.index: index,
        TaskFields.status: status ? 1 : 0,
        TaskFields.task: task,
      };

  static Task fromJson(Map<String, Object?> json) => Task(
        index: json[TaskFields.index] as int,
        status: json[TaskFields.status] == 1,
        task: json[TaskFields.task] as String,
      );

  Task copy({int? index, bool? status, String? task}) =>
      Task(index: this.index, status: this.status, task: this.task);
}

final String taskTable = 'Tasks';

class TaskFields {
  static final List<String> values = [index, status, task];

  static final String index = '_index';
  static final String status = 'status';
  static final String task = 'task';
}
