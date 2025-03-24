import 'dart:convert';

import 'package:flutter/material.dart';
import 'models/item.dart';
import 'models/appcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Adicionando 'key' ao construtor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.secondary),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  late List<Item> items = []; // Corrigido para ser 'final'

  MyHomePage({super.key}) {
    // Adicionando 'key' ao construtor
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  final TextEditingController newTaskCtrl = TextEditingController();
  List<Item> items = [];
  bool isLoading = true; // Para evitar que a UI fique instável ao carregar

  @override
  void initState() {
    super.initState();
    load();
  }

  void add() {
    if (newTaskCtrl.text.isEmpty) return;

    setState(() {
      items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      items.removeAt(index);
      save();
    });
  }

  Future<void> load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null && data.isNotEmpty) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        items = result;
      });
    }

    setState(() {
      isLoading = false; // Indica que terminou de carregar
    });
  }

  Future<void> save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: AppColors.colorTextPrimary,
            fontSize: 24,
          ),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(color: AppColors.colorTextPrimary),
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Mostra carregamento
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = items[index];
          return Dismissible(
            key: Key(item.title),
            background: Container(
              color: Colors.red.withAlpha((0.2 * 255).toInt()),
            ),
            onDismissed: (direction) {
              remove(index);
            },
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value!;
                  save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.add,
          color: AppColors.colorTextPrimary,
        ),
      ),
    );
  }
}


