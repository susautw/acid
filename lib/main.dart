import 'dart:io';

import 'package:acid/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database.dart';
import 'transaction.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const AccountingApp());
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<AccountingTransaction>> transactions;

  @override
  void initState() {
    super.initState();
    transactions = DatabaseHelper.instance.getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounting App'),
      ),
      body: FutureBuilder<List<AccountingTransaction>>(
        future: transactions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double balance = 0;
            for (var transaction in snapshot.data!) {
              balance += transaction.type == 'income'
                  ? transaction.amount
                  : -transaction.amount;
            }

            return Column(
              children: [
                Text('Balance: \$${balance.toStringAsFixed(2)}'),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].description),
                        subtitle: Text(
                            '\$${snapshot.data![index].amount.toStringAsFixed(2)} (${snapshot.data![index].date})'),
                        trailing: snapshot.data![index].type == 'income'
                            ? const Icon(Icons.arrow_upward,
                                color: Colors.green)
                            : const Icon(Icons.arrow_downward,
                                color: Colors.red),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return const CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionForm(
                onSubmit: (transaction) async {
                  await DatabaseHelper.instance.insertTransaction(transaction);
                  setState(() {
                    transactions = DatabaseHelper.instance.getAllTransactions();
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
