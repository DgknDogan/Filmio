import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_spacing.dart';
import '../enums/movie_type.dart';
import '../enums/series_type.dart';
import '../extensions/context_extension.dart';
import '../models/discover_filters.dart';
import 'custom_button.dart';
import 'section_header.dart';

/// The earliest year the year filter reaches back to. Film is older than this,
/// but TMDB's catalogue thins out to nothing well before it.
const _earliestYear = 1900;

/// Genre, rating and year, in a sheet.
///
/// One widget for both catalogues: the three questions are the same and only
/// the genre list differs, so [isSeries] picks the list rather than a second
/// copy of the sheet existing.
///
/// Returns the filters chosen, or null if the reader backed out — which is not
/// the same as clearing them.
class DiscoverFilterSheet extends StatefulWidget {
  final DiscoverFilters filters;
  final bool isSeries;

  const DiscoverFilterSheet({super.key, required this.filters, this.isSeries = false});

  static Future<DiscoverFilters?> show(
    BuildContext context, {
    required DiscoverFilters filters,
    bool isSeries = false,
  }) {
    return showModalBottomSheet<DiscoverFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) => DiscoverFilterSheet(filters: filters, isSeries: isSeries),
    );
  }

  @override
  State<DiscoverFilterSheet> createState() => _DiscoverFilterSheetState();
}

class _DiscoverFilterSheetState extends State<DiscoverFilterSheet> {
  /// The sheet edits a copy and hands it back on apply: a filter changed and
  /// then backed out of should not have reached the list.
  late Set<int> _genreIds = {...widget.filters.genreIds};
  late RangeValues _rating = RangeValues(widget.filters.minRating ?? 0, widget.filters.maxRating ?? 10);
  late RangeValues _years = RangeValues(
    (widget.filters.minYear ?? _earliestYear).toDouble(),
    (widget.filters.maxYear ?? _thisYear).toDouble(),
  );

  static int get _thisYear => DateTime.now().year;

  bool get _ratingIsWhole => _rating.start == 0 && _rating.end == 10;

  bool get _yearsAreWhole => _years.start == _earliestYear && _years.end == _thisYear;

  /// A bound left at the end of its scale is not a filter — it is the absence
  /// of one, and sending it would narrow nothing while looking as though it
  /// had.
  DiscoverFilters get _chosen => DiscoverFilters(
        genreIds: _genreIds,
        minRating: _rating.start == 0 ? null : _rating.start,
        maxRating: _rating.end == 10 ? null : _rating.end,
        minYear: _years.start == _earliestYear ? null : _years.start.round(),
        maxYear: _years.end == _thisYear ? null : _years.end.round(),
      );

  void _clear() {
    setState(() {
      _genreIds = {};
      _rating = const RangeValues(0, 10);
      _years = RangeValues(_earliestYear.toDouble(), _thisYear.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: context.l10n.filtersTitle,
                actionLabel: context.l10n.filtersClear,
                onAction: _clear,
              ),
              AppGap.vertical(AppSpacing.xl),
              SheetSectionLabel(label: context.l10n.filtersGenre),
              AppGap.vertical(AppSpacing.md),
              _Genres(
                isSeries: widget.isSeries,
                selected: _genreIds,
                onToggle: (id) => setState(() => _genreIds.contains(id) ? _genreIds.remove(id) : _genreIds.add(id)),
              ),
              AppGap.vertical(AppSpacing.xl),
              _RangeField(
                label: context.l10n.filtersRating,
                // The whole scale reads as "any", not as "0 to 10".
                value: _ratingIsWhole
                    ? context.l10n.filtersAny
                    : '${_rating.start.toStringAsFixed(1)} – ${_rating.end.toStringAsFixed(1)}',
                child: RangeSlider(
                  values: _rating,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  onChanged: (values) => setState(() => _rating = values),
                ),
              ),
              AppGap.vertical(AppSpacing.lg),
              _RangeField(
                label: context.l10n.filtersYear,
                value: _yearsAreWhole ? context.l10n.filtersAny : '${_years.start.round()} – ${_years.end.round()}',
                child: RangeSlider(
                  values: _years,
                  min: _earliestYear.toDouble(),
                  max: _thisYear.toDouble(),
                  divisions: _thisYear - _earliestYear,
                  onChanged: (values) => setState(() => _years = values),
                ),
              ),
              AppGap.vertical(AppSpacing.xl),
              CustomButton(
                text: context.l10n.filtersApply,
                onPressed: () => Navigator.of(context).pop(_chosen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every genre the catalogue has, as chips that toggle.
///
/// Several picked means any of them — a reader asking for action and comedy
/// wants either, not a film that is both.
class _Genres extends StatelessWidget {
  final bool isSeries;
  final Set<int> selected;
  final void Function(int id) onToggle;

  const _Genres({required this.isSeries, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final genres = isSeries
        ? [for (final genre in SeriesType.values) (genre.id, genre.label)]
        : [for (final genre in MovieType.values) (genre.id, genre.label)];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (id, label) in genres)
          _GenreChip(label: label, isSelected: selected.contains(id), onTap: () => onToggle(id)),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: AppRadius.xsAll,
          color: isSelected ? palette.tagAccentBackground : palette.tagNeutralBackground,
          border: Border.all(color: isSelected ? palette.buttonBorder : palette.tagNeutralBackground),
        ),
        child: Text(
          label,
          style: context.styles.tag.copyWith(color: isSelected ? palette.onTagAccent : palette.onTagNeutral),
        ),
      ),
    );
  }
}

/// A slider with its name on the left and what it currently says on the right.
class _RangeField extends StatelessWidget {
  final String label;
  final String value;
  final Widget child;

  const _RangeField({required this.label, required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SheetSectionLabel(label: label),
            Text(value, style: context.styles.meta),
          ],
        ),
        SizedBox(height: 36.h, child: child),
      ],
    );
  }
}
