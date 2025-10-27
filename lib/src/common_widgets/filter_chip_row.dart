// lib/src/common_widgets/filter_chip_row.dart

import 'package:flutter/material.dart';

/// A universal widget for displaying horizontally scrollable filter chips.
///
/// This widget handles the layout and styling, requiring the parent screen
/// to manage the state and logic when a chip is selected.
class FilterChipRow extends StatelessWidget {
  /// The list of items to display.
  final List<String> options;

  /// The currently selected value (used to highlight the chip).
  final String selectedValue;

  /// Callback function when a chip is tapped.
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedValue;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSelected(option);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
