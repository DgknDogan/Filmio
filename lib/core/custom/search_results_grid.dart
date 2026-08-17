import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'custom_searchbar.dart';

/// The field and its way out, at the top of a search screen.
///
/// Cancel is a word rather than an icon: it is the only other thing on the
/// row, and a word says which of the two is the way back.
class SearchBarRow extends StatelessWidget {
  final Object heroTag;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focus;
  final void Function(String query) onChanged;

  const SearchBarRow({
    super.key,
    required this.heroTag,
    required this.hintText,
    required this.controller,
    required this.focus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Hero(
              tag: heroTag,
              // What flies is a still of the field rather than the field: the
              // real one is mounted on the screen it belongs to, and a second
              // one built over it in the overlay would put two text fields on
              // one controller and one focus node.
              flightShuttleBuilder: (flightContext, animation, direction, fromHero, toHero) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    // The accent ring and the glow under it belong to the
                    // screen with the keyboard on it. Carrying them across the
                    // whole flight and dropping them at the end is what makes
                    // the border go all at once; they arrive and leave over
                    // the flight instead.
                    //
                    // The value is the route's own animation, so it already
                    // reads as how much of this is the search screen: it runs
                    // up on the way in and back down on the way out. Reading
                    // it backwards for a pop inverts an animation that was
                    // already inverted, which is a pop that looks like a push.
                    final focused = animation.value;

                    // The overlay a flight is drawn in has no `Material` of its
                    // own, and the field inside asks for one.
                    return Material(
                      color: Colors.transparent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // The ground stays opaque underneath: two half-faded
                          // fields would let the page show through the bar.
                          CustomSearchbar(isEnabled: false, hintText: hintText),
                          Opacity(
                            opacity: focused.clamp(0.0, 1.0),
                            child: CustomSearchbar(isEnabled: true, hintText: hintText),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Material(
                color: Colors.transparent,
                child: CustomSearchbar(
                  controller: controller,
                  focusNode: focus,
                  isEnabled: true,
                  hintText: hintText,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          AppGap.horizontal(AppSpacing.md),
          GestureDetector(
            onTap: () {
              controller.clear();
              context.router.maybePop();
            },
            child: Text(
              context.l10n.cancel,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// "6 RESULTS" on the left, what was searched on the right.
class SearchResultsSummary extends StatelessWidget {
  final int count;
  final String scope;

  const SearchResultsSummary({super.key, required this.count, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.searchResultCount(count).toUpperCase(), style: context.styles.sectionLabel),
          Text(scope, style: context.styles.meta),
        ],
      ),
    );
  }
}

/// Search results, three across.
///
/// Three rather than two: a query is answered by scanning, and at three a
/// screen holds nine posters at a size that is still recognisable.
class SearchResultsGrid extends StatelessWidget {
  final List<Widget> children;

  const SearchResultsGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2 / 3,
      ),
      childrenDelegate: SliverChildListDelegate(children),
    );
  }
}
