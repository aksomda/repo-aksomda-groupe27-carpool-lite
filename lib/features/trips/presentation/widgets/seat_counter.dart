import 'package:flutter/material.dart';

class SeatCounter extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const SeatCounter({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  State<SeatCounter> createState() => _SeatCounterState();
}

class _SeatCounterState extends State<SeatCounter> {
  late int value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue.clamp(
      1,
      widget.maxValue,
    );
  }

  void _decrease() {
    if (value > 1) {
      setState(() {
        value--;
      });

      widget.onChanged(value);
    }
  }

  void _increase() {
    if (value < widget.maxValue) {
      setState(() {
        value++;
      });

      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value > 1 ? _decrease : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Container(
          width: 55,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: value < widget.maxValue ? _increase : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}