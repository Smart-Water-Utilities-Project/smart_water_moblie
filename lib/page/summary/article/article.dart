import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/summary/article/article_cover.dart';

class Article extends StatelessWidget {
  const Article({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("相關文章", style: themeData.textTheme.titleMedium),
        const SizedBox(height: 10),
        ArticleCover(
          title: "測試",
          lore: "震驚一萬年",
        ),
      ]
    );
  }
}