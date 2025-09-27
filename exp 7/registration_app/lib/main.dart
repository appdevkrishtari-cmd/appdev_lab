import 'package:flutter/material.dart';

void main() => runApp(const RegistrationApp());

class RegistrationApp extends StatelessWidget {
  const RegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  String? _selectedDept;
  DateTime? _selectedDate;

  final List<String> _departments = [
    'Mechanical Engineering',
    'Computer/IT Engineering',
    'Civil Engineering',
    'Telecommunication Engineering',
    'Electrical Engineering',
  ];

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedDept != null &&
        _selectedDate != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Info'),
          content: Text(
            'Name: ${_nameController.text}\n'
            'Roll Number: ${_rollController.text}\n'
            'Department: $_selectedDept\n'
            'Date of Birth: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              // Roll Number
              TextFormField(
                controller: _rollController,
                decoration: const InputDecoration(labelText: 'Roll Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your roll number'
                    : null,
              ),
              const SizedBox(height: 16),

              // Department Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDept,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDept = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a department' : null,
              ),
              const SizedBox(height: 16),

              // Date of Birth Picker
              InkWell(
                onTap: () => _pickDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select your date of birth'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
