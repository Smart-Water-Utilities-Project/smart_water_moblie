import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Acknowledgements extends StatelessWidget {
  const Acknowledgements({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10 ,10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10)
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 35),
              SizedBox(width: 5),
              Text("開發人員名單")
            ],
          ),
          SizedBox(height: 5),
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
          )
        ]
      )
    );
  }
}

class PersonCard extends StatelessWidget {
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
            child: Image.asset(image),
          ),
          const SizedBox(width: 10),
          Text(name),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Fluttertoast.showToast(
                msg: message,
                fontSize: 16.0,
                timeInSecForIosWeb: 1,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.grey.shade800
              );
            }, 
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              if (!await launchUrl(uri)) {
                throw Exception('Could not launch $url');
              }
            }, 
          )
        ],
      ),
    );
  }
}