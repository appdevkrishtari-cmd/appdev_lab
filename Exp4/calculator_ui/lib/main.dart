import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator UI',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatelessWidget {
  // Button Widget
  Widget calcButton(String text, Color color, Color textColor) {
    return Container(
      margin: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          backgroundColor: color,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Display
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.centerRight,
              child: Text(
                "0",
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton("C", Colors.grey, Colors.black),
                    calcButton("+/-", Colors.grey, Colors.black),
                    calcButton("%", Colors.grey, Colors.black),
                    calcButton("/", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton("7", Colors.grey.shade800, Colors.white),
                    calcButton("8", Colors.grey.shade800, Colors.white),
                    calcButton("9", Colors.grey.shade800, Colors.white),
                    calcButton("x", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton("4", Colors.grey.shade800, Colors.white),
                    calcButton("5", Colors.grey.shade800, Colors.white),
                    calcButton("6", Colors.grey.shade800, Colors.white),
                    calcButton("-", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton("1", Colors.grey.shade800, Colors.white),
                    calcButton("2", Colors.grey.shade800, Colors.white),
                    calcButton("3", Colors.grey.shade800, Colors.white),
                    calcButton("+", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.fromLTRB(70, 20, 70, 20),
                          backgroundColor: Colors.grey.shade800,
                        ),
                        child: Text(
                          "0",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    calcButton(".", Colors.grey.shade800, Colors.white),
                    calcButton("=", Colors.orange, Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
