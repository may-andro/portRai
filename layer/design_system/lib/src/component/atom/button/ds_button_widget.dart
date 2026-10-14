import 'package:design_system/src/component/atom/button/dto/dto.dart';
import 'package:design_system/src/component/atom/button/widget/base_button_widget.dart';
import 'package:flutter/material.dart';

class DSButtonWidget extends StatelessWidget {
  const DSButtonWidget({
    required this.label,
    required this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.border = DSButtonBorder.regular,
    this.isDisabled = false,
    this.isLoading = false,
    this.iconDirection = DSButtonIconDirection.left,
    this.size = DSButtonSize.large,
    this.icon,
    this.iconWidget,
    this.isExpanded = true,
    super.key,
  });

  final String label;

  final VoidCallback onPressed;

  final DSButtonVariant variant;

  final DSButtonBorder border;

  final bool isDisabled;

  final bool isLoading;

  final DSButtonIconDirection iconDirection;

  final IconData? icon;

  /// Replaces [icon], e.g. with an animated icon. It sizes itself.
  final Widget? iconWidget;

  /// Fills the available width when true, otherwise hugs its content.
  final bool isExpanded;

  final DSButtonSize size;

  @override
  Widget build(BuildContext context) {
    return BaseButtonWidget(
      content: _content,
      onPressed: onPressed,
      variant: variant.variant,
      border: border.border,
      isDisabled: isDisabled,
      loading: isLoading ? CircularLoading() : null,
      height: size.height,
      isExpanded: isExpanded,
    );
  }

  ContentDTO get _content {
    final mainAxisSize = isExpanded ? MainAxisSize.max : MainAxisSize.min;
    final widget = iconWidget;
    if (widget != null) {
      return WidgetIconTextContent(
        label,
        widget,
        iconDirection == DSButtonIconDirection.right,
        mainAxisSize: mainAxisSize,
      );
    }
    final iconData = icon;
    if (iconData == null) {
      return TextContent(label, mainAxisSize: mainAxisSize);
    }
    if (iconDirection == DSButtonIconDirection.left) {
      return LeftIconTextContent(
        label,
        iconData,
        size.height * 0.5,
        mainAxisSize: mainAxisSize,
      );
    }
    return RightIconTextContent(
      label,
      iconData,
      size.height * 0.5,
      mainAxisSize: mainAxisSize,
    );
  }
}

enum DSButtonVariant {
  primary,
  secondary,
  error,
  text;

  VariantDTO get variant {
    switch (this) {
      case primary:
        return PrimaryVariant();
      case secondary:
        return SecondaryVariant();
      case error:
        return ErrorVariant();
      case text:
        return TextVariant();
    }
  }
}

enum DSButtonBorder {
  regular,
  rounded;

  BorderDTO get border {
    switch (this) {
      case regular:
        return RegularBorder();
      case rounded:
        return RoundedBorder();
    }
  }
}

enum DSButtonIconDirection { left, right }

enum DSButtonSize {
  extraSmall(32.0),
  small(40.0),
  medium(48.0),
  large(54.0);

  const DSButtonSize(this.height);

  final double height;
}
