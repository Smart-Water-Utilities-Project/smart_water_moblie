import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> with AutomaticKeepAliveClientMixin{

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("相關文章", style: themeData.textTheme.titleMedium),
        const SizedBox(height: 10),
        ArticleCover(
          title: "省水妙招",
          lore: "每天省一點，能帶來不一樣的改變",
          url: "https://www-ws.wra.gov.tw/001/Upload/401/relpic/9029/7241/3ccad84a-cd88-4eb6-9e17-5b3cfc38fce0.png"
        ),
      ]
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class ArticleCover extends StatelessWidget {
  const ArticleCover({
    super.key,
    required this.title,
    required this.lore,
    required this.url
  });

  final String title, lore, url;

  Future<Uint8List?> getImage() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final response = await http.get(uri);
    return response.bodyBytes;
  }

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
                child: FutureBuilder(
                  future: getImage(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(snapshot.data!),
                            fit: BoxFit.cover,
                        )),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  }
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
                      child: Text(lore, style: themeData.textTheme.labelMedium?.copyWith(
                        color: Colors.grey
                      ))
                    )
                  ]
                )
              )
            ]
          ),
          onTap: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)
                ),
              ),
              clipBehavior: Clip.hardEdge,
              context: context,
              enableDrag: true,
              useSafeArea: true,
              isScrollControlled: true,
              isDismissible: true,
              backgroundColor: Colors.transparent,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 100
              ),
              builder: (context) {
                return const ArticleDialog();
              }
            );
          },
        )
      )
    );
  }
}

class ArticleDialog extends StatelessWidget {
  const ArticleDialog({super.key});

  
  
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget buildJson() {
      final widgetJson = {
        "type": "container",
        "args": {
          "child": {
            "type": "text",
            "args": {
              "text": "經濟部水利署在此特別針對日常生活上提供幾種省水小妙招，洗澡前的冷水可以收集利用外，在家人洗澡時，淋浴取代盆浴，且應連續不要間斷，可節省熱水流出前的水量又可節省能源；另外洗碗、洗菜用適量水在盆槽洗濯，避免直接沖洗；至於洗衣水、洗澡水、洗碗、洗菜、洗水果或洗米等用水，均可收集起來作為洗車、拖地及沖洗馬桶用；而在新購洗衣機應選用有省水標章洗衣機，衣物適量選擇洗衣流程較短行程，不必選擇標準行程，均可輕鬆省水。\n至於在用水查漏方面，除了養成定期紀錄用水度數的好習慣外，應隨時觀察家裡的用水設備，如水龍頭、馬桶是否有漏水的情況，牆面、地下或天花板是否有忽然潮濕的現象，都有可能是漏水的警訊，一定要馬上處理喔！最後，大家一起養成隨手關緊水龍頭的好習慣，更是可以於無形之中好好珍惜我們的水資源。"
            }
          }
        }
      };
      final widget = JsonWidgetData.fromDynamic(widgetJson);
      return widget.build(context: context);
    }

    return DraggableScrollableSheet(
      snap: true,
      expand: false,
      maxChildSize: 1,
      minChildSize: 0.9999999,
      initialChildSize: 1.0,
      snapSizes: const [0.9999999, 1.0],
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            excludeHeaderSemantics: true,
            automaticallyImplyLeading: false,
            surfaceTintColor: themeData.colorScheme.background,
            backgroundColor: themeData.colorScheme.background.withOpacity(0.75),
            title: Text("文章標題", style: themeData.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Container(color: Colors.transparent)
              )
            )
          ),
          body: Container(
            color: themeData.inputDecorationTheme.fillColor,
            child: ListView(
              controller: scrollController,
              children: [
                buildJson()
                
              ]
            )
          )
        );
      }
    );
  }
}