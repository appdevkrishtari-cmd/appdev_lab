// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TodoSqliteApp());
}

class TodoSqliteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 9: SQLite todo list',
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
  Database? _db;
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    _db?.close();
    super.dispose();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'todos.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            details TEXT,
            completed INTEGER,
            createdAt TEXT
          )
        ''');
      },
    );
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final data = await _db?.query('todos', orderBy: 'datetime(createdAt) DESC');
    setState(() {
      _todos = data ?? [];
    });
  }

  Future<void> _addTodo() async {
    final title = _titleCtrl.text.trim();
    final details = _detailsCtrl.text.trim();
    if (title.isEmpty) return;

    await _db?.insert('todos', {
      'title': title,
      'details': details,
      'completed': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });

    _titleCtrl.clear();
    _detailsCtrl.clear();
    _fetchTodos();
  }

  Future<void> _toggleComplete(int id, bool current) async {
    await _db?.update(
      'todos',
      {'completed': current ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTodos();
  }

  Future<void> _deleteTodo(int id) async {
    await _db?.delete('todos', where: 'id = ?', whereArgs: [id]);
    _fetchTodos();
  }

  Future<void> _showEditDialog(Map<String, dynamic> todo) async {
    final editTitle = TextEditingController(text: todo['title'] ?? '');
    final editDetails = TextEditingController(text: todo['details'] ?? '');

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
                await _db?.update(
                  'todos',
                  {'title': newTitle, 'details': newDetails},
                  where: 'id = ?',
                  whereArgs: [todo['id']],
                );
              }
              Navigator.pop(ctx);
              _fetchTodos();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    editTitle.dispose();
    editDetails.dispose();
  }

  String _formatTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite To-Do List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                'Tasks: ${_todos.length}',
                style: TextStyle(fontSize: 16),
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
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _detailsCtrl,
              decoration: InputDecoration(
                labelText: 'Details (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addTodo,
                  icon: Icon(Icons.add),
                  label: Text('Add Task'),
                ),
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
              child: _todos.isEmpty
                  ? Center(child: Text('No Tasks Found'))
                  : ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final t = _todos[index];
                        final completed = t['completed'] == 1;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Checkbox(
                              value: completed,
                              onChanged: (_) =>
                                  _toggleComplete(t['id'], completed),
                            ),
                            title: Text(
                              t['title'] ?? '',
                              style: TextStyle(
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((t['details'] ?? '').isNotEmpty)
                                  Text(t['details']),
                                SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(t['createdAt']),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            isThreeLine: (t['details'] ?? '').isNotEmpty,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(t),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteTodo(t['id']),
                                ),
                              ],
                            ),
                          ),
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
