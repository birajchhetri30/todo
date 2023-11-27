import 'package:todo/task_database.dart';
import 'package:todo/user_database.dart';

class User {
  final int? id;
  final String fname;
  final String lname;
  final String email;
  final String password;
  late TaskDatabase userTasks;

  User({
    this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.password,
  }) {
    userTasks = TaskDatabase(id.toString());
  }

  Map<String, Object?> toJson() {
    return {
      UserFields.id: id,
      UserFields.fname: fname,
      UserFields.lname: lname,
      UserFields.email: email,
      UserFields.password: password
    };
  }

  static User fromJson(Map<String, Object?> json) {
    return User(
      id: json[UserFields.id] as int,
      fname: json[UserFields.fname] as String,
      lname: json[UserFields.lname] as String,
      email: json[UserFields.email] as String,
      password: json[UserFields.password] as String,
    );
  }

  User copy({
    int? id,
    String? fname,
    String? lname,
    String? email,
    String? password,
  }) {
    return User(
      id: this.id,
      fname: this.fname,
      lname: this.lname,
      email: this.email,
      password: this.password,
    );
  }

  void deleteUser() async {
    await userTasks.deleteAllTasks();
    await UserDatabase.instance.deleteUser(id!);
  }
}

final String userTable = 'Users';

class UserFields {
  static final List<String> values = [id, fname, lname, email, password];

  static final String id = '_id';
  static final String fname = 'fname';
  static final String lname = 'lname';
  static final String email = 'email';
  static final String password = 'password';
}
