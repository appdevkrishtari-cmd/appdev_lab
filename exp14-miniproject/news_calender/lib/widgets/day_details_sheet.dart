import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'news_list_widget.dart';

class DayDetailsSheet extends StatefulWidget {
  final DateTime date;
  final String initialProvider;

  const DayDetailsSheet({
    super.key,
    required this.date,
    required this.initialProvider,
  });

  @override
  State<DayDetailsSheet> createState() => _DayDetailsSheetState();
}

class _DayDetailsSheetState extends State<DayDetailsSheet> {
  final NewsService _newsService = NewsService();
  final StorageService _storage = StorageService();
  final AuthService _auth = AuthService();

  late String provider;
  List<NewsArticle> articles = [];
  bool loadingNews = false;

  final TextEditingController _noteCtrl = TextEditingController();
  String uid = '';

  @override
  void initState() {
    super.initState();
    provider = widget.initialProvider;
    _initialize();
  }

  Future<void> _initialize() async {
    // Ensure user exists (anon or logged in)
    final user = _auth.currentUser ?? await _auth.ensureAnonymous();
    uid = user?.uid ?? "unknown";

    // Load notes + news
    await _loadNote();
    await _loadNews();
  }

  // ---------------------- NOTES ----------------------

  Future<void> _loadNote() async {
    final stored = await _storage.getNote(uid, widget.date);
    _noteCtrl.text = stored ?? "";
    setState(() {});
  }

  Future<void> _saveNote() async {
    final text = _noteCtrl.text.trim();

    await _storage.setNote(uid, widget.date, text);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Note saved")));
  }

  Future<void> _deleteNote() async {
    _noteCtrl.clear();
    await _storage.deleteNote(uid, widget.date);
    setState(() {});
  }

  // ---------------------- NEWS ----------------------

  Future<void> _loadNews() async {
    setState(() => loadingNews = true);
    articles =
        await _newsService.fetchForProviderAndDate(provider, widget.date);
    setState(() => loadingNews = false);
  }

  // ---------------------- UI ----------------------

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMMd().format(widget.date);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Provider selector
            Row(
              children: [
                const Text("Provider: "),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: provider,
                  items: _newsService.providers.keys
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) async {
                    if (v != null) {
                      provider = v;
                      setState(() {});
                      await _loadNews();
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _loadNews,
                  child: const Text("Refresh"),
                )
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 180,
              child: loadingNews
                  ? const Center(child: CircularProgressIndicator())
                  : articles.isEmpty
                      ? const Center(child: Text("No news for this date"))
                      : NewsListWidget(articles: articles),
            ),

            const SizedBox(height: 12),

            // Notes
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Notes or reminders for this date",
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text("Save note"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _deleteNote,
                  child: const Text("Delete"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
