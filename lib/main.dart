import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? idContato;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> _contatos = [];

  _openBanco() async {
    var dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, 'banco.db');
    
    var bd = await openDatabase(path, version: 1,
    onCreate: (db, versaoRecente) async{
      String sql =
      "CREATE TABLE contatos (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, email VARCHAR)";
      await db.execute(sql);
    });

    return bd;
  }

  _salvar(Map<String, dynamic> dadosContato) async {
    Database db = await _openBanco();
    int id = await db.insert('contatos', dadosContato);

    setState(() {
      idContato = id;
    });
  }

  _verContatos() async {
    Database db = await _openBanco();
    List<Map<String, dynamic>> contatos = await db.query('contatos');

    setState(() {
      _contatos = contatos;
    });
  }

  @override
  void initState() {
    super.initState();
    _verContatos();
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar Widget'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.add_box_outlined),
              ),
              Tab(
                icon: Icon(Icons.view_list_outlined),
              ),
              Tab(
                icon: Icon(Icons.account_box_outlined),
              ),
            ]
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            // Tab 1
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(width: 100, 'https://cdn-icons-png.freepik.com/512/1144/1144760.png?ga=GA1.1.177399096.1709223240&'),
                Container(
                  margin: const EdgeInsets.all(15),
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nome'
                    ),
                    controller: _nomeController,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'E-mail'
                    ),
                    controller: _emailController,
                  ),
                ),
                ElevatedButton(
                  child: const Text('Salvar'),
                  onPressed: () async {
                    String nome = _nomeController.text;
                    String email = _emailController.text;
                    Map<String, dynamic> dadosContato = {
                        'nome': nome,
                        'email': email
                      };
                    await _salvar(dadosContato);
                    _verContatos();
                  },
                ),
              ]
            ),
            // Tab 2
            ListView.builder(
              itemCount: _contatos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_contatos[index]['nome']),
                );
              },
            ),
            // Tab 3
            Center(
              child: Text('Tab 3')
            ),
          ]
        )
      ),
    );
  }
}
