import 'package:flutter/material.dart';
import 'package:flutter_todo/helpers/database_helper.dart';
import 'package:flutter_todo/models/todo_model.dart';
import 'package:flutter_todo/screens/add_todo_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Todo>>? _todoList;
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _updateTodoList();
  }

  _updateTodoList() {
    setState(() {
      _todoList = DatabaseHelper.instance.getTodoList();
    });
  }

  Widget _buildTodo(Todo todo) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                  fontSize: 18.0,
                  decoration: todo.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            subtitle: Text(
              '${_dateFormatter.format(todo.date)} • ${todo.priority}',
              style: TextStyle(
                  fontSize: 15.0,
                  decoration: todo.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
                  
            ),
            trailing: Checkbox(
              onChanged: (value) {
                todo.status = value! ? 1 : 0;
                DatabaseHelper.instance.updateTodo(todo);
                _updateTodoList();
              },
              activeColor: Colors.green.shade100,
              value: todo.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => AddTodoScreen(
                  updateTodoList: _updateTodoList,
                  todo: todo,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTodoScreen(
              updateTodoList: _updateTodoList,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _todoList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('sup ${snapshot.hasData}');
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var snapshotData = (snapshot.data as List<Todo>).toList();
          final int completedTodoCount = snapshotData
              .where((Todo todo) => todo.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 80.0),
            itemCount: 1 + snapshotData.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "My todo's",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        '$completedTodoCount of ${snapshotData.length}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                );
              }
              return _buildTodo(snapshotData[index - 1]);
            },
          );
        },
      ),
    );
  }
}
