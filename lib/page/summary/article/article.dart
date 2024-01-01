import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:smart_water_moblie/core/smart_water_api.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> with AutomaticKeepAliveClientMixin{
  bool isFetching = false;
  List<ArticleCover> articleList = [];

  void updateArticles() async {
    setState(() => isFetching = true);
    articleList = await SmartWaterAPI.instance.listArticle();
    setState(() => isFetching = false);
  }

  @override
  void initState() {
    super.initState();
    updateArticles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("相關文章", style: themeData.textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: SizedBox(
                height: 25, width: 25,
                child: isFetching ? const CircularProgressIndicator() : const Icon(Icons.refresh)
              ),
              onPressed: isFetching ? null : () => updateArticles(),
            )
          ]
        ),
        for (final item in articleList) ... [
          const SizedBox(height: 10), item 
        ]
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class ArticleCover extends StatelessWidget {
  const ArticleCover({
    super.key,
    required this.title,
    required this.lore,
    required this.coverUrl,
    required this.articleId
  });

  final String title, lore, coverUrl, articleId;

  Future<Uint8List?> getImage() async {
    final uri = Uri.tryParse(coverUrl);
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
                            fit: BoxFit.cover,
                            image: MemoryImage(snapshot.data!),
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
              backgroundColor: themeData.colorScheme.background,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 100
              ),
              builder: (context) {
                return ArticleDialog(
                  title: title,
                  articleId: articleId
                );
              }
            );
          },
        )
      )
    );
  }
}

class ArticleDialog extends StatefulWidget {
  const ArticleDialog({
    super.key,
    required this.title,
    required this.articleId
  });

  final String title, articleId;

  @override
  State<ArticleDialog> createState() => _ArticleDialogState();
}

class _ArticleDialogState extends State<ArticleDialog> {

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

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
            backgroundColor: themeData.inputDecorationTheme.fillColor!.withOpacity(0.9),
            title: Text(widget.title, style: themeData.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            flexibleSpace: Stack(
              alignment: Alignment.centerRight,
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(color: Colors.transparent)
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                      padding: MaterialStatePropertyAll(EdgeInsets.fromLTRB(0, 3, 0, 5))
                    ),
                    child: Text("完成", style: themeData.textTheme.labelMedium?.copyWith(
                      color: Colors.blue
                    ))
                  )
                )
              ]
            )
          ),
          body: FutureBuilder(
            future: SmartWaterAPI.instance.getArticle(widget.articleId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 55),
                      snapshot.data!.build(context: context)
                    ]
                  )
                );
              }

              return const Center(
                child: CircularProgressIndicator()
              );
            }
          )
        );
      }
    );
  }
}
