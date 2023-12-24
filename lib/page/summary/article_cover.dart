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
                  fit: BoxFit.fitHeight,
                  image: const NetworkImage(
                    "https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2023/12/19/realtime/28384171.jpg&x=0&y=0&sw=0&sh=0&sl=W&fw=800&exp=3600",
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
                ),
              )
              
            ]
          ),
          onTap: () {},
        )
      )
    );
  }
}