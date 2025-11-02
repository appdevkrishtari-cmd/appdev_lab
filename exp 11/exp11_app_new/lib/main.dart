import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 11: REST API',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List newsList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => loading = true);
    final url = Uri.parse(
        'https://gnews.io/api/v4/top-headlines?category=technology&lang=en&country=in&apikey=b2296bd55c481a7aaadc3d61296a8e53');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          newsList = data['articles'] ?? [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch news: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _openArticle(Map article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchNews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchNews,
              child: ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final article = newsList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      leading: article['image'] != null
                          ? Image.network(article['image'],
                              width: 80, fit: BoxFit.cover)
                          : Icon(Icons.article_outlined, size: 40),
                      title: Text(article['title'] ?? 'No Title'),
                      subtitle: Text(
                        article['description'] ?? 'No Description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openArticle(article),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Map article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  Future<void> _launchURL(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Article'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(article['image']),
              ),
            SizedBox(height: 12),
            Text(
              article['title'] ?? 'No Title',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (article['content'] != null)
              Text(article['content'],
                  style: TextStyle(fontSize: 16, height: 1.4)),
            SizedBox(height: 16),
            if (article['url'] != null)
              ElevatedButton.icon(
                icon: Icon(Icons.open_in_browser),
                label: Text('Read Full Article'),
                onPressed: () => _launchURL(article['url']),
              ),
          ],
        ),
      ),
    );
  }
}
