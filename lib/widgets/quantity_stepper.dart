import 'package:flutter/material.dart';

import '../core/theme.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged; // null = disabled while busy
  final int min;
  final double buttonSize;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.buttonSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, String label, int next, bool enabled) => SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: EdgeInsets.zero,
            tooltip: label,
            onPressed: enabled && onChanged != null ? () => onChanged!(next) : null,
            icon: Icon(icon, size: 18, color: AppColors.ink),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, 'Decrease quantity', value - 1, value > min),
          SizedBox(
            width: 30,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          btn(Icons.add_rounded, 'Increase quantity', value + 1, true),
        ],
      ),
    );
  }
}
