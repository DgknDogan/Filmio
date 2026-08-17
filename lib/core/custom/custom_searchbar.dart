import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

/// The height the app draws a search field at.
///
/// Anything that flies into one has to agree with it, or the flight starts by
/// jumping.
double get searchFieldHeight => 42.h;

/// The search field.
///
/// A pill rather than the app's usual 8pt box — it is the one control that is
/// always the subject of its screen, and the accent ring plus the glow under
/// it are what say so.
class CustomSearchbar extends StatelessWidget {
  final bool isEnabled;
  final String hintText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const CustomSearchbar({
    super.key,
    required this.isEnabled,
    required this.hintText,
    this.focusNode,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: searchFieldHeight,
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: isEnabled ? palette.accent : palette.inputBorder),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: palette.buttonGlow.withValues(alpha: 0.4),
                  blurRadius: 22,
                  spreadRadius: -8,
                ),
              ]
            : null,
      ),
      child: SearchFieldContent(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        isEnabled: isEnabled,
        hintText: hintText,
      ),
    );
  }
}

/// What is inside the pill: the icon, and the text or the hint standing in for
/// it.
///
/// Separate from the pill because the movie tab draws the same insides in a
/// box of its own, one that changes width and colour with the scroll. Building
/// a second copy of the row by hand there put the hint a couple of points off
/// the real one, which is exactly the distance the flight between them showed.
class SearchFieldContent extends StatelessWidget {
  final bool isEnabled;
  final String hintText;

  /// Overrides the icon's colour. The bar tints it while it is still a button
  /// standing on artwork.
  final Color? iconColor;

  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const SearchFieldContent({
    super.key,
    required this.isEnabled,
    required this.hintText,
    this.iconColor,
    this.focusNode,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: isEnabled,
      onTapOutside: (event) => focusNode?.unfocus(),
      cursorColor: palette.accent,
      cursorWidth: 1.5,
      style: context.styles.inputText,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hintText,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
          child: Icon(
            Icons.search_rounded,
            size: AppSpacing.lg,
            color: iconColor ?? (isEnabled ? palette.accent : palette.textSecondary),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: AppSpacing.xxl),
      ),
    );
  }
}
