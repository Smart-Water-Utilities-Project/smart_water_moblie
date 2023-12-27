import 'package:flutter/material.dart';

class ArticleCover extends StatelessWidget {
  const ArticleCover({
    super.key,
    required this.title,
    required this.lore
  });

  final String title, lore;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Material(
      color: themeData.inputDecorationTheme.fillColor,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(15),
      child: AspectRatio(
        aspectRatio: 1,
        child: InkWell(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Ink.image(
                  fit: BoxFit.fitWidth,
                  image: const NetworkImage(
                    "https://www-ws.wra.gov.tw/001/Upload/401/relpic/9029/7241/3ccad84a-cd88-4eb6-9e17-5b3cfc38fce0.png",
                  )
                )
                
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(15, 4, 10, 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: themeData.textTheme.titleMedium),
                    Flexible(
                      child: Text(lore, style: themeData.textTheme.labelMedium,)
                    )
                  ]
                )
              )
            ]
          ),
          onTap: () {},
        )
      )
    );
  }
}