import 'package:flutter/material.dart';

class InfoCard extends StatefulWidget {
  const InfoCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.textSpan,
      required this.color,
      this.onTap
    }) ;

  final Widget icon;
  final String title;
  final Color color;
  final List<Widget> textSpan;
  final Function()? onTap;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {

    final textLength = widget.textSpan.length;
    return ListTile(
      titleAlignment: ListTileTitleAlignment.top,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      shape: RoundedRectangleBorder(
        //<-- SEE HERE
        borderRadius: BorderRadius.circular(15),
      ),
      leading: widget.icon,
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 20,
          color: widget.color
        )
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Icon(
          size: 20,
          Icons.arrow_forward_ios,
          color: widget.color
        )
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.textSpan,
      ),
      onTap: widget.onTap
    );
  }
}
