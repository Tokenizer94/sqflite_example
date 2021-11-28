import 'package:flutter/material.dart';
import 'package:sqflite_example/models/grocery.dart';
import 'package:sqflite_example/services/local/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Main(),
    );
  }
}

/// 1. Create our widget
class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  final _textController = TextEditingController();
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textController,
        ),
      ),
      /// 8. Handle all states with Future builder or any other state managment
      body: FutureBuilder<List<Grocery>>(
        future: DatabaseHelper.instance.getGroceries(),
        builder: (BuildContext context, AsyncSnapshot<List<Grocery>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Loading...'),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Groceries in list.'),
            );
          }
          /// 9. There is data so show list of data
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Center(
                child: ListTile(
                  title: Text(snapshot.data![index].name),
                  onTap: () {
                    /// 10. Select item for editting
                    setState(() {
                      _textController.text = snapshot.data![index].name;
                      selectedId = snapshot.data![index].id;
                    });
                  },
                  onLongPress: () {
                    /// 11. Remove item from database
                    setState(() {
                      DatabaseHelper.instance.removeGrocery(
                        snapshot.data![index].id!,
                      );
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /// 12. If we are in edit mode then update the item
          /// If not then add it to database
          selectedId != null
              ? await DatabaseHelper.instance.updateGrocery(
                  Grocery(
                    id: selectedId,
                    name: _textController.text,
                  ),
                )
              : await DatabaseHelper.instance.addGrocery(
                  Grocery(name: _textController.text),
                );
          setState(() {
            _textController.clear();
            selectedId = null;
          });
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
