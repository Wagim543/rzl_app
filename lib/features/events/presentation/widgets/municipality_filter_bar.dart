import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/events_providers.dart';

/// Horizontal municipality selector (FR-02).
///
/// Deliberately renders nothing while municipalities load or fail: the feed
/// below already communicates loading and error states, and a second skeleton
/// in the filter bar would be noise. A guest can always browse unfiltered.
class MunicipalityFilterBar extends ConsumerWidget {
  const MunicipalityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final municipalities = ref.watch(municipalitiesProvider);
    final selected = ref.watch(selectedMunicipalityProvider);

    return municipalities.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return ChoiceChip(
                  label: const Text('All'),
                  selected: selected == null,
                  onSelected: (_) =>
                      ref.read(selectedMunicipalityProvider.notifier).clear(),
                );
              }

              final municipality = items[index - 1];
              return ChoiceChip(
                label: Text(municipality.name),
                selected: selected == municipality.id,
                onSelected: (isSelected) {
                  ref
                      .read(selectedMunicipalityProvider.notifier)
                      .select(isSelected ? municipality.id : null);
                },
              );
            },
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
