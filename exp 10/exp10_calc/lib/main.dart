import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 10: Firestore Calculator',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String input = '';
  String result = '';
  final CollectionReference calcRef =
      FirebaseFirestore.instance.collection('calculations');

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '';
      } else if (value == '=') {
        _calculateResult();
      } else {
        input += value;
      }
    });
  }

  void _calculateResult() {
    try {
      // safe evaluation using Dart's built-in expression
      final exp = input.replaceAll('×', '*').replaceAll('÷', '/');
      final res = double.parse(_evaluate(exp).toStringAsFixed(2));
      setState(() => result = res.toString());
      _saveCalculation(input, result);
    } catch (e) {
      setState(() => result = 'Error');
    }
  }

  dynamic _evaluate(String expr) {
    // quick and dirty parser: supports + - * /
    List<String> tokens =
        expr.split(RegExp(r'([+\-*/])')).map((e) => e.trim()).toList();
    double total = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length - 1; i += 2) {
      String op = tokens[i];
      double next = double.parse(tokens[i + 1]);
      if (op == '+')
        total += next;
      else if (op == '-')
        total -= next;
      else if (op == '*')
        total *= next;
      else if (op == '/') total /= next;
    }
    return total;
  }

  Future<void> _saveCalculation(String expression, String res) async {
    await calcRef.add({
      'expression': expression,
      'result': res,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteCalculation(String id) async {
    await calcRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Calculator'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: calcRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox.shrink();
                  final total = snapshot.data!.docs.length;
                  return Text('Saved: $total', style: TextStyle(fontSize: 16));
                },
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(input, style: TextStyle(fontSize: 28)),
                  SizedBox(height: 10),
                  Text(result,
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Divider(),
          _buildKeypad(),
          Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  calcRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error loading history'));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text('No history yet'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title:
                            Text('${data['expression']} = ${data['result']}'),
                        subtitle: data['timestamp'] != null
                            ? Text(data['timestamp']
                                .toDate()
                                .toString()
                                .split('.')[0])
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCalculation(doc.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final buttons = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['0', '.', '=', '+'],
      ['C']
    ];

    return Column(
      children: buttons.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((text) {
            return Padding(
              padding: const EdgeInsets.all(6),
              child: ElevatedButton(
                onPressed: () => _onButtonPressed(text),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20), minimumSize: Size(70, 60)),
                child: Text(text, style: TextStyle(fontSize: 22)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
