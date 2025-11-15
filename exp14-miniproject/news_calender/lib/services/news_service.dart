import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/news_article.dart';

class NewsService {
  // Providers: displayName -> URL (RSS or JSON)
  final Map<String, String> providers = {
    'Inshorts': 'https://inshortsapi.vercel.app/news?category=national',
    'NDTV (RSS)': 'https://feeds.feedburner.com/ndtvnews-top-stories',
    'IndiaToday (RSS)': 'https://www.indiatoday.in/rss/home',
  };

  Future<List<NewsArticle>> fetchForProviderAndDate(
      String provider, DateTime date) async {
    final url = providers[provider];
    if (url == null) return [];
    final uri = Uri.parse(url);
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];

    final body = res.body;
    if (url.contains('inshortsapi')) {
      // JSON endpoint
      return _parseInshortsJson(body, provider, date);
    } else {
      // RSS XML
      return _parseRss(body, provider, date);
    }
  }

  List<NewsArticle> _parseInshortsJson(
      String body, String source, DateTime date) {
    final data = jsonDecode(body);
    final arr = data['data'] as List? ?? data['news'] as List? ?? [];
    final List<NewsArticle> items = [];
    for (final e in arr) {
      final title = e['title'] ?? e['title'] ?? '';
      final content = e['content'] ?? e['content'] ?? '';
      final timeString = e['date'] ?? e['date'];
      DateTime pub = DateTime.now();
      try {
        if (timeString != null) pub = DateTime.parse(timeString);
      } catch (_) {}
      final item = NewsArticle(
        title: title,
        link: e['readMoreUrl'] ?? '',
        description: content,
        pubDate: pub,
        source: source,
      );
      if (_sameLocalDay(pub, date)) items.add(item);
    }
    return items;
  }

  List<NewsArticle> _parseRss(String xmlString, String source, DateTime date) {
    final doc = XmlDocument.parse(xmlString);
    final items = doc.findAllElements('item');
    final List<NewsArticle> out = [];
    for (final item in items) {
      final title = item.getElement('title')?.innerText ?? '';
      final link = item.getElement('link')?.innerText ?? '';
      final desc = item.getElement('description')?.innerText ?? '';
      final pubStr = item.getElement('pubDate')?.innerText ??
          item.getElement('dc:date')?.innerText ??
          '';
      DateTime pub = DateTime.now();
      try {
        pub = DateTime.parse(pubStr);
      } catch (_) {
        // Try to parse common RFC format manually fallback: try to parse last resort by DateTime.parse
        try {
          pub = DateTime.parse(pubStr.replaceAll(RegExp(r' GMT|\+0000'), ''));
        } catch (_) {
          pub = DateTime.now();
        }
      }
      final article = NewsArticle(
        title: title,
        link: link,
        description: desc,
        pubDate: pub,
        source: source,
      );
      if (_sameLocalDay(pub, date)) out.add(article);
    }
    return out;
  }

  bool _sameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
