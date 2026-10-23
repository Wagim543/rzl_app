import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/format/date_formats.dart';
import '../../domain/event.dart';

/// One event in the feed.
///
/// The whole card is the tap target (>= 48 dp), with a semantic label so screen
/// readers announce the event rather than "button".
class EventCard extends StatelessWidget {
  const EventCard({required this.event, super.key});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.eventDetail(event.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Thumbnail(event: event),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _CategoryLabel(name: event.categoryName),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _IconLine(
                      icon: Icons.event_outlined,
                      text: DateFormats.schedule(event.startsAt, event.endsAt),
                    ),
                    const SizedBox(height: 2),
                    _IconLine(
                      icon: Icons.place_outlined,
                      text: event.venue.isEmpty
                          ? event.locationLabel
                          : '${event.venue} · ${event.locationLabel}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_activity_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 84,
        height: 84,
        child: event.coverImageUrl == null
            ? placeholder
            : Image.network(
                event.coverImageUrl!,
                fit: BoxFit.cover,
                // A broken image URL must not break the card (FR-34).
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      name.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
