import 'package:flutter/material.dart';
import 'package:flutter_todo/helpers/database_helper.dart';
import 'package:flutter_todo/models/todo_model.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  //const AddTodoScreen({Key? key}) : super(key: key);
  final Function updateTodoList;
  final Todo? todo;
  AddTodoScreen({required this.updateTodoList, this.todo});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  initState() {
    super.initState();

    if (widget.todo != null) {
      _title = widget.todo!.title;
      _date = widget.todo!.date;
      _priority = widget.todo!.priority;
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('$_title, $_date, $_priority');

      //Insert todo
      Todo todo = Todo(title: _title, date: _date, priority: _priority!);
      if (widget.todo == null) {
        todo.status = 0;
        DatabaseHelper.instance.insertTodo(todo);
      } else {
        todo.id = widget.todo!.id;
        todo.status = widget.todo!.status;
        DatabaseHelper.instance.updateTodo(todo);
      }

      widget.updateTodoList();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTodo(widget.todo!.id!);
    widget.updateTodoList();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[                  
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                    
                    
                  ),
                  
                  SizedBox(height: 20.0),
                  Text(
                    widget.todo == null ? 'addTodo' : 'Update Todo',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input!.trim().isEmpty
                                ? 'Enter a ToDo title'
                                : null,
                            onSaved: (input) => _title = input!,
                            initialValue: _title,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            style: TextStyle(fontSize: 18.0),
                            onTap: _handleDatePicker,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: DropdownButtonFormField<String>(
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down_circle),
                            iconSize: 22.0,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18.0),
                                ),
                              );
                            }).toList(),
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            // ignore: unnecessary_null_comparison
                            validator: (input) => _priority == null
                                ? 'Select a priority level'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _priority = value;
                              });
                            },
                            value: _priority,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: TextButton(
                            child: Text(
                              widget.todo == null ? 'Add ToDo' : 'Update Todo',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                        ),
                        widget.todo != null
                            ? Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 20.0,
                                ),
                                height: 60.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  onPressed: _delete,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
