import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_example/models/grocery.dart';

/// 3. Create our database helper class
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// 4. Singleton instance of database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  /// 5. Initial the database
  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "groceries.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// 6. Database does not exist so we create it
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groceries(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
  }

  /// 7. Below we create CRUD methods to work with database
  Future<List<Grocery>> getGroceries() async {
    Database db = await instance.database;
    var groceries = await db.query('groceries', orderBy: 'name');
    List<Grocery> groceryList = groceries.isNotEmpty
        ? groceries.map((e) => Grocery.fromMap(e)).toList()
        : [];
    return groceryList;
  }

  Future<int> addGrocery(Grocery grocery) async {
    Database db = await instance.database;
    return await db.insert('groceries', grocery.toMap());
  }

  Future<int> removeGrocery(int id) async {
    Database db = await instance.database;
    return await db.delete('groceries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateGrocery(Grocery grocery) async {
    Database db = await instance.database;
    return await db.update(
      'groceries',
      grocery.toMap(),
      where: 'id = ?',
      whereArgs: [grocery.id],
    );
  }
}
