import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';

class NewsPage extends StatefulWidget {
  final DateTime? date;

  const NewsPage({super.key, this.date});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  String provider = "gnews"; // default provider

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  void loadNews() async {
    final result = await NewsService().fetch(provider);
    articles = result
        .map((a) => {
              "title": a.title,
              "desc": a.description ?? "",
              "url": a.url,
            })
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton(
          value: provider,
          items: const [
            DropdownMenuItem(value: "gnews", child: Text("GNews Free")),
            DropdownMenuItem(value: "reddit", child: Text("Reddit News")),
            DropdownMenuItem(value: "hackernews", child: Text("Hacker News")),
          ],
          onChanged: (v) {
            provider = v!;
            loadNews();
          },
        ),
        Expanded(
          child: articles.isEmpty
              ? const Center(child: Text("No news available"))
              : ListView(
                  children: articles
                      .map((e) => NewsCard(
                            title: e["title"],
                            description: e["desc"],
                            url: e["url"],
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
