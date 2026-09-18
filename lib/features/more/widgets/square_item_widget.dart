import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SquareButtonWidget extends StatefulWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final int count;
  final bool hasCount;
  final bool isWallet;
  final double? balance;
  final bool isLoyalty;
  final String? subTitle;
  final Function? onTap;

  const SquareButtonWidget({
    super.key,
    required this.image,
    required this.title,
    this.navigateTo,
    required this.count,
    required this.hasCount,
    this.isWallet = false,
    this.balance,
    this.subTitle,
    this.isLoyalty = false,
    this.onTap,
  });

  @override
  State<SquareButtonWidget> createState() => _SquareButtonWidgetState();
}

class _SquareButtonWidgetState extends State<SquareButtonWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? .975 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onHighlightChanged: (value) => setState(() => _pressed = value),
        onTap: widget.onTap == null ? null : () => widget.onTap!(),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                width: 118,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [const Color(0xFF173A34), const Color(0xFF102A26)]
                        : [primary, const Color(0xFF0A554E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: dark ? .18 : .16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -45,
                      right: -32,
                      child: Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: .08), width: 14),
                        ),
                      ),
                    ),
                    if (widget.isWallet)
                      Positioned(
                        left: 11,
                        top: 11,
                        child: Image.asset(widget.image, width: 25, height: 25, color: Colors.white),
                      )
                    else
                      Center(
                        child: Image.asset(widget.image, width: 34, height: 34, color: Colors.white),
                      ),
                    if (widget.isWallet)
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              getTranslated(widget.subTitle, context) ?? '',
                              style: textRegular.copyWith(color: Colors.white70, fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isLoyalty
                                  ? (widget.balance?.toStringAsFixed(0) ?? '0')
                                  : (widget.balance != null ? PriceConverter.convertPrice(context, widget.balance) : '0'),
                              style: textBold.copyWith(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    if (widget.hasCount)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Consumer<CartController>(
                          builder: (context, cart, child) => Container(
                            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5B82E),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: Colors.white, width: 1.2),
                            ),
                            child: Text(
                              widget.count > 99 ? '99+' : widget.count.toString(),
                              style: textBold.copyWith(color: const Color(0xFF063D39), fontSize: 9),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
