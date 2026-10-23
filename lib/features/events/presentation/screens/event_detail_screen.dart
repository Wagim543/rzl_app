import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/message_of.dart';
import '../../../../core/format/date_formats.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/events_providers.dart';
import '../../domain/event.dart';

/// Event detail, readable without an account (FR-06).
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: event.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: messageOf(error),
          onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
        ),
        data: (data) => _EventDetailBody(event: data),
      ),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (event.coverImageUrl != null) _CoverImage(url: event.coverImageUrl!),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _Pill(label: event.categoryName),
                  _Pill(label: event.locationLabel, muted: true),
                  if (event.isFree) const _Pill(label: 'Free', muted: true),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.event_outlined,
                label: DateFormats.fullDate(event.startsAt),
                detail: DateFormats.schedule(event.startsAt, event.endsAt),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.place_outlined,
                label: event.venue.isEmpty
                    ? 'Venue to be announced'
                    : event.venue,
                detail: event.address ?? event.locationLabel,
              ),
              const SizedBox(height: 24),
              Text('About this event', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                event.blurb,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              if (event.summary != null &&
                  event.summary!.trim().isNotEmpty &&
                  event.description.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  event.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = muted
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.primaryContainer;
    final foreground = muted
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(color: foreground),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
