import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'transaction.dart';

class DatabaseHelper {
  static const _dbName = 'accounting.db';
  static const _dbVersion = 1;
  static const _tableName = 'transactions';

  // Column names
  static const columnId = 'id';
  static const columnDate = 'date';
  static const columnDescription = 'description';
  static const columnAmount = 'amount';
  static const columnType = 'type';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = p.join(Directory.current.absolute.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnDate TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnType TEXT NOT NULL
      )
    ''');
  }

// Insert a transaction
  Future<int> insertTransaction(AccountingTransaction transaction) async {
    Database db = await instance.database;
    return await db.insert(_tableName, transaction.toMap());
  }

// Update a transaction
  Future<int> updateTransaction(AccountingTransaction transaction) async {
    Database db = await instance.database;
    int id = transaction.id!;
    return await db.update(_tableName, transaction.toMap(),
        where: '$columnId = ?', whereArgs: [id]);
  }

// Delete a transaction
  Future<int> deleteTransaction(int id) async {
    Database db = await instance.database;
    return await db.delete(_tableName, where: '$columnId = ?', whereArgs: [id]);
  }

// Get all transactions
  Future<List<AccountingTransaction>> getAllTransactions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return AccountingTransaction(
        id: maps[i]['id'],
        date: maps[i]['date'],
        description: maps[i]['description'],
        amount: maps[i]['amount'],
        type: maps[i]['type'],
      );
    });
  }
}
