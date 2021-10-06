import 'dart:io';

import 'package:flutter_todo/models/todo_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String todosTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  //Checking if theres existent database
  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  //if not create one
  Future<Database?> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list_db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $todosTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)',
    );
  }

  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(todosTable);
    return result;
  }

  //Get todos from db
  Future<List<Todo>> getTodoList() async {
    final List<Map<String, dynamic>> todoMapList = await getTodoMapList();
    final List<Todo> todoList = [];
    todoMapList.forEach((todoMap) {
      todoList.add(Todo.fromMap(todoMap));
    });
    todoList.sort((todoA, todoB) => todoA.date.compareTo(todoB.date));
    return todoList;
  }

  //Inserting todo
  Future<int> insertTodo(Todo todo) async {
    Database? db = await this.db;
    final int result = await db!.insert(todosTable, todo.toMap());
    return result;
  }

  //Updating todo
  Future<int> updateTodo(Todo todo) async {
    Database? db = await this.db;
    final int result = await db!.update(todosTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return result;
  }

  //Deleting todo
  Future<int> deleteTodo(int id) async {
    Database? db = await this.db;
    final int result =
        await db!.delete(todosTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }
}
