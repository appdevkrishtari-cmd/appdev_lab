import 'dart:io';

void main() {
  // Input: name
  stdout.write("Enter your name: ");
  String? name = stdin.readLineSync();

  // Input: number
  stdout.write("Enter a number: ");
  int number = int.parse(stdin.readLineSync()!);

  // Output: Greeting
  print("\nHello, $name!");
  print("Here is the multiplication table of $number:\n");

  // Loop: print table
  for (int i = 1; i <= 10; i++) {
    print("$number x $i = ${number * i}");
  }
}
