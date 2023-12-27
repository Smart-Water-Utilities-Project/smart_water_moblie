import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import 'package:smart_water_moblie/core/counter.dart';

class RowIndicator extends StatelessWidget {
  const RowIndicator({
    super.key,
    required this.unit,
    required this.listenable,
    this.fractionDigits = 0
  });

  final CounterModel listenable;
  final String unit;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ListenableBuilder(
      listenable: listenable,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedFlipCounter(
            value: listenable.value,
            fractionDigits: fractionDigits,
            curve: Curves.easeInOutSine,
            duration: const Duration(milliseconds: 600),
            textStyle: themeData.textTheme.titleLarge
          ),
          Text(
            " $unit",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey
            )
          )
        ]
      )
    );
  }
}

class ColumnIndicator extends StatelessWidget {
  const ColumnIndicator({
    super.key,
    required this.unit,
    required this.listenable,
  });

  final CounterModel listenable;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ListenableBuilder(
      listenable: listenable,
      builder: (context, child) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedFlipCounter(
            value: listenable.value,
            curve: Curves.easeInOutSine,
            duration: const Duration(milliseconds: 600),
            textStyle: themeData.textTheme.titleLarge
          ),
          Text(
            " $unit",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey
            )
          )
        ]
      )
    );
  }
}