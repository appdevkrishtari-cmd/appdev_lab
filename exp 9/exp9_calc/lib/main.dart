import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 9: Calculator (SQLite)',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = "";
  String result = "0";
  Database? database;

  @override
  void initState() {
    super.initState();
    initDB();
  }

  Future<void> initDB() async {
    final path = join(await getDatabasesPath(), 'calc_history.db');
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE history(id INTEGER PRIMARY KEY, expression TEXT, result TEXT)');
      },
    );
  }

  Future<void> insertCalculation(String exp, String res) async {
    if (database == null) return;
    await database!.insert('history', {'expression': exp, 'result': res});
  }

  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        expression = "";
        result = "0";
      } else if (value == "=") {
        try {
          final eval = _evaluate(expression);
          result = eval.toString();
          insertCalculation(expression, result);
        } catch (e) {
          result = "Error";
        }
      } else {
        expression += value;
      }
    });
  }

  double _evaluate(String exp) {
    exp = exp.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      final parsed = exp.split(RegExp(r'(\+|\-|\*|\/)'));
      if (parsed.length < 2) return double.tryParse(exp) ?? double.nan;
      double total = double.parse(parsed[0]);
      final ops = exp.replaceAll(RegExp(r'[0-9\.]'), '').split('');
      for (int i = 0; i < ops.length; i++) {
        double num = double.parse(parsed[i + 1]);
        switch (ops[i]) {
          case '+':
            total += num;
            break;
          case '-':
            total -= num;
            break;
          case '*':
            total *= num;
            break;
          case '/':
            total /= num;
            break;
        }
      }
      return total;
    } catch (_) {
      return double.nan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black,
      padding: EdgeInsets.all(14),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );

    final buttons = [
      ["7", "8", "9", "÷"],
      ["4", "5", "6", "×"],
      ["1", "2", "3", "-"],
      ["0", ".", "=", "+"],
      ["C"]
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Calculator (SQLite)')),
      body: Center(
        child: Container(
          width: 360,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(8),
                child: Text(
                  expression,
                  style: TextStyle(fontSize: 22, color: Colors.black54),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(8),
                child: Text(
                  result,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: buttons.expand((e) => e).length,
                  itemBuilder: (context, index) {
                    final value = buttons.expand((e) => e).toList()[index];
                    return ElevatedButton(
                      style: buttonStyle,
                      onPressed: () => buttonPressed(value),
                      child: Text(value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
