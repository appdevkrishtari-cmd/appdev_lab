import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(TodoFirestoreApp());
}

class TodoFirestoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp10: Firestore To-Do CRUD',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final CollectionReference todosRef =
      FirebaseFirestore.instance.collection('todos');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final title = _titleCtrl.text.trim();
    final details = _detailsCtrl.text.trim();
    if (title.isEmpty) return;

    await todosRef.add({
      'title': title,
      'details': details,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _titleCtrl.clear();
    _detailsCtrl.clear();
  }

  Future<void> _toggleComplete(String id, bool current) async {
    await todosRef.doc(id).update({'completed': !current});
  }

  Future<void> _deleteTodo(String id) async {
    await todosRef.doc(id).delete();
  }

  Future<void> _showEditDialog(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final editTitle = TextEditingController(text: data['title'] ?? '');
    final editDetails = TextEditingController(text: data['details'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: editTitle,
                decoration: InputDecoration(labelText: 'Title')),
            TextField(
                controller: editDetails,
                decoration: InputDecoration(labelText: 'Details')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newTitle = editTitle.text.trim();
              final newDetails = editDetails.text.trim();
              if (newTitle.isNotEmpty) {
                await todosRef.doc(doc.id).update({
                  'title': newTitle,
                  'details': newDetails,
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    editTitle.dispose();
    editDetails.dispose();
  }

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do Firestore CRUD'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: todosRef.snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return SizedBox.shrink();
                  final total = snap.data!.docs.length;
                  return Text('Tasks: $total', style: TextStyle(fontSize: 16));
                },
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                  labelText: 'Task title', border: OutlineInputBorder()),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _detailsCtrl,
              decoration: InputDecoration(
                  labelText: 'Details (optional)',
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                    onPressed: _addTodo,
                    icon: Icon(Icons.add),
                    label: Text('Add Task')),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _titleCtrl.clear();
                    _detailsCtrl.clear();
                  },
                  icon: Icon(Icons.clear),
                  label: Text('Clear'),
                  style: ElevatedButton.styleFrom(primary: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    todosRef.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(child: Text('Error loading tasks'));
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty)
                    return Center(child: Text('No tasks yet. Add one!'));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final d = doc.data() as Map<String, dynamic>;
                      final title = d['title'] ?? '';
                      final details = d['details'] ?? '';
                      final completed = d['completed'] == true;
                      final ts = d['createdAt'] as Timestamp?;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: completed,
                            onChanged: (_) =>
                                _toggleComplete(doc.id, completed),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (details.isNotEmpty) Text(details),
                              SizedBox(height: 4),
                              Text(_formatTimestamp(ts),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          isThreeLine: details.isNotEmpty,
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(doc),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTodo(doc.id),
                            ),
                          ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
