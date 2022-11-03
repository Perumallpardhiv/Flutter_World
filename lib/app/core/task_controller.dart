import 'dart:ffi';
import 'dart:io';

import 'package:get/get.dart';
import 'package:todo_firebase/app/model/task.dart';
import 'package:todo_firebase/data/local/db_helper.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }

  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((e) => Task.fromJson(e)).toList());
  }

  void delete(Task _) {
    DBHelper.delete(_);
    getTasks();
  }

  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }

  void markTaskNotCompleted(int id) async {
    await DBHelper.notUpdate(id);
    getTasks();
  }
}
