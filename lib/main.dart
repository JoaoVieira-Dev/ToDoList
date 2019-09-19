import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = jsonDecode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["OK"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a["OK"] && !b["OK"])
          return 1;
        else if (!a["OK"] && b["OK"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });
    return null;
  }

  Future<void> _tarefabranco() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('TAREFA EM BRANCO'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Deseja salvar uma tarefa em branco?'),
              Text(''),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Salvar'),
            onPressed: () {
              _addToDo();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _addTarefa() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Nova Tarefa'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
                  TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.redAccent)),
                  ),

            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancelar'),
            textColor: Colors.redAccent,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Salvar'),
            textColor: Colors.redAccent,
            onPressed: () {
              _addToDo();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: (){
              _addTarefa();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.red,
          ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),
          ))
        ],
      ),
      
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["OK"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["OK"] ? Icons.check : Icons.error, color: Colors.white,),
          backgroundColor: Colors.redAccent,
        ),
        activeColor: Colors.redAccent,
        onChanged: (c) {
          setState(() {
            _toDoList[index]["OK"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\"Removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                 _toDoList.insert(_lastRemovedPos, _lastRemoved);
                 _saveData(); 
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }
  // Funções para salvar no App.

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
