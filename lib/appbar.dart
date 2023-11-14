import 'dart:ui';

import 'package:flutter/material.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget{
  const GeneralAppBar({
    super.key,
    required this.title,
    required this.appBar
  });

  final String title;
  final AppBar appBar;
  

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    return AppBar(
      elevation: 0,
      centerTitle: true,
      excludeHeaderSemantics: true,
      surfaceTintColor: themeData.colorScheme.background,
      backgroundColor: themeData.colorScheme.background.withOpacity(0.75),
      title: Text(title,
        style: themeData.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold
        )
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(color: Colors.transparent)
        )
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}