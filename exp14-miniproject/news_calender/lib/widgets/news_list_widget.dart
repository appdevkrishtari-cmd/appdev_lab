import 'package:flutter/material.dart';
import '../models/news_article.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsListWidget extends StatelessWidget {
  final List<NewsArticle> articles;
  const NewsListWidget({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (_, i) {
        final a = articles[i];
        return ListTile(
          title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text("${a.source} • ${a.pubDate.toLocal()}"),
          onTap: () async {
            final uri = Uri.tryParse(a.link);
            if (uri != null) {
              await launchUrl(uri);
            }
          },
        );
      },
    );
  }
}
