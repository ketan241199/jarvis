import 'package:flutter/material.dart';
import '../../domain/entities/tag_entity.dart';

/// Reusable tag chip for selecting task tags.
class TagChip extends StatelessWidget {
  final TagEntity tag;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(tag.colorValue);

    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: tagColor.withAlpha(40),
      checkmarkColor: tagColor,
      labelStyle: TextStyle(
        color: isSelected ? tagColor : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? tagColor : Theme.of(context).colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
