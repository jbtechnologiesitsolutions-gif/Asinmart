import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class CustomButton extends StatefulWidget {
  final Function()? onTap;
  final String? buttonText;
  final bool isBuy;
  final bool isBorder;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? loadingColor;
  final double? radius;
  final double? fontSize;
  final String? leftIcon;
  final double? borderWidth;
  final bool isLoading;
  final double buttonHeight;

  const CustomButton({
    super.key,
    this.onTap,
    required this.buttonText,
    this.isBuy = false,
    this.isBorder = false,
    this.backgroundColor,
    this.radius,
    this.textColor,
    this.fontSize,
    this.leftIcon,
    this.borderColor,
    this.loadingColor = Colors.white,
    this.borderWidth,
    this.isLoading = false,
    this.buttonHeight = 50,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.isLoading;
    final radius = BorderRadius.circular(widget.radius ?? AsinDesign.radius);
    final Color baseColor = widget.backgroundColor ??
        (widget.isBuy ? AsinDesign.gold : Theme.of(context).primaryColor);
    final Color foreground = widget.textColor ??
        (widget.isBuy ? AsinDesign.text : Colors.white);

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? .985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : widget.onTap,
          onHighlightChanged: disabled ? null : (value) => setState(() => _pressed = value),
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: widget.buttonHeight < 44 ? 44 : widget.buttonHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: disabled
                  ? Theme.of(context).disabledColor.withValues(alpha: .72)
                  : widget.isBorder
                      ? Colors.transparent
                      : baseColor,
              borderRadius: radius,
              border: widget.isBorder
                  ? Border.all(
                      color: widget.borderColor ?? Theme.of(context).primaryColor,
                      width: widget.borderWidth ?? 1.25,
                    )
                  : null,
              boxShadow: disabled || widget.isBorder
                  ? null
                  : [
                      BoxShadow(
                        color: baseColor.withValues(alpha: .18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: widget.isLoading
                  ? Row(
                      key: const ValueKey('loading'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 17,
                          width: 17,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor ?? Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          getTranslated('loading', context) ?? 'Loading',
                          style: textBold.copyWith(color: widget.loadingColor ?? Colors.white),
                        ),
                      ],
                    )
                  : Row(
                      key: const ValueKey('content'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leftIcon != null) ...[
                          Image.asset(
                            widget.leftIcon!,
                            width: 20,
                            height: 20,
                            color: widget.isBorder ? (widget.textColor ?? Theme.of(context).primaryColor) : foreground,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.buttonText ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: titilliumSemiBold.copyWith(
                              fontSize: widget.fontSize ?? 15,
                              color: widget.isBorder
                                  ? (widget.textColor ?? Theme.of(context).primaryColor)
                                  : foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
