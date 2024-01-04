import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class RowIndicator extends StatelessWidget {
  const RowIndicator({
    super.key,
    required this.unit,
    required this.value,
    this.fractionDigits = 0
  });

  final String unit;
  final int fractionDigits;
  final double value;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFlipCounter(
          value: value,
          fractionDigits: fractionDigits,
          curve: Curves.easeInOutSine,
          duration: const Duration(milliseconds: 600),
          textStyle: themeData.textTheme.titleLarge
        ),
        Text(
          " $unit",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            overflow: TextOverflow.ellipsis
          )
        )
      ]
    );
  }
}

class ColumnIndicator extends StatelessWidget {
  const ColumnIndicator({
    super.key,
    required this.unit,
    required this.value,
  });

  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFlipCounter(
          value: value,
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
    );
  }
}