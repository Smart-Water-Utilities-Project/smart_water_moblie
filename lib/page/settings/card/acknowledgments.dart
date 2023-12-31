import 'package:flutter/material.dart';
import 'package:smart_water_moblie/page/settings/basic.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class Acknowledgements extends StatelessWidget {
  const Acknowledgements({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10)
      ),
      child: const Column(
        children: [
          SectionHeading(
            title: "開發人員名單",
            icon: Icons.person
          ),
          Column(
            children: [
              PersonCard(
                name: "YFHD",
                message: "我抄愛蘋果設計風格",
                image: "assets/dev_avatar/yfhd.png",
                url: "https://github.com/YFHD-osu"
              ),
              PersonCard(
                name: "NightFeather",
                message: "ㄔㄐㄐ",
                image: "assets/dev_avatar/nightfeather.png",
                url: "https://github.com/NightFeather0615"
              ),
              PersonCard(
                name: "yuva",
                message: "圖表Code大師，我的抄人",
                image: "assets/dev_avatar/yuva.png",
                url: "https://stackoverflow.com/users/11774056/yuva"
              )
            ]
          ),
          SizedBox(height: 10)
        ]
      )
    );
  }
}

class PersonCard extends StatefulWidget {
  const PersonCard({
    super.key,
    required this.name,
    required this.image,
    required this.url,
    required this.message
  });

  final String url;
  final String name;
  final String image;
  final String message;

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  ToastificationItem toast = ToastificationItem(
    builder: (context, a) => const SizedBox(),
    alignment: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Container(
            height: 35,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000)
            ),
            child: Image.asset(widget.image),
          ),
          const SizedBox(width: 10),
          Text(widget.name),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              if (toast.isRunning) return;
              toast = toastification.show(
                context: context,
                pauseOnHover: true,
                showProgressBar: false,
                title: widget.message,
                autoCloseDuration: const Duration(seconds: 5),
                type: ToastificationType.info,
                alignment: Alignment.bottomCenter,
              );
            }, 
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            onPressed: () async {
              final Uri uri = Uri.parse(widget.url);
              if (!await launchUrl(uri)) {
                throw Exception('Could not launch ${widget.url}');
              }
            }, 
          )
        ],
      ),
    );
  }
}