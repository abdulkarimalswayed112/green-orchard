import 'package:flutter/material.dart';

import '../../core/theme.dart';

class ProductFilter {
  final double? minPrice;
  final double? maxPrice;
  final bool availableOnly;

  const ProductFilter({this.minPrice, this.maxPrice, this.availableOnly = false});

  bool get isActive => minPrice != null || maxPrice != null || availableOnly;
}

/// FR4 — price range + availability. Category is handled by the chips.
class FilterSheet extends StatefulWidget {
  final ProductFilter initial;

  const FilterSheet({super.key, required this.initial});

  static const maxSliderPrice = 200.0;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late RangeValues _range;
  late bool _availableOnly;

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      widget.initial.minPrice ?? 0,
      widget.initial.maxPrice ?? FilterSheet.maxSliderPrice,
    );
    _availableOnly = widget.initial.availableOnly;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final max = FilterSheet.maxSliderPrice;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: t.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Price', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  'SAR ${_range.start.round()} – ${_range.end.round()}${_range.end >= max ? '+' : ''}',
                  style: t.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
            RangeSlider(
              values: _range,
              min: 0,
              max: max,
              divisions: 40,
              activeColor: AppColors.leaf,
              inactiveColor: AppColors.leafTint,
              onChanged: (v) => setState(() => _range = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.leaf,
              title: const Text('Available only'),
              subtitle: const Text('Hide out-of-stock items'),
              value: _availableOnly,
              onChanged: (v) => setState(() => _availableOnly = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context, const ProductFilter()),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      ProductFilter(
                        minPrice: _range.start > 0 ? _range.start : null,
                        maxPrice: _range.end < max ? _range.end : null,
                        availableOnly: _availableOnly,
                      ),
                    ),
                    child: const Text('Show results'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
