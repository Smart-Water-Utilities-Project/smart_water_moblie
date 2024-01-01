import 'package:flutter/material.dart';

class BottomDetailSheet extends StatefulWidget {
  const BottomDetailSheet({super.key});

  @override
  State<BottomDetailSheet> createState() => _BottomDetailSheetState();
}

class _BottomDetailSheetState extends State<BottomDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return DraggableScrollableSheet(
      minChildSize: 0.235,
      maxChildSize: 0.9,
      initialChildSize: 0.235,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 150),
      snapSizes: const <double>[0.235, 0.9],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width,
          
          clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: themeData.inputDecorationTheme.fillColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            ),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.9,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      ...List.generate(
                        50,
                        (index) => SizedBox(height: 50, child: Text('Container $index')))
                    ],
                  ),
                )
              ),
              IgnorePointer(
                child: Container(
                  color: themeData.inputDecorationTheme.fillColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        height: 8,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey
                        ),
                      )
                    ]
                  )
                )
              )
            ],
          ),
        );
      },
    );
  }
}