import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CustomMenuWidget extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String icon;
  final bool showCartCount;
  final VoidCallback onTap;

  const CustomMenuWidget({
    super.key,
    required this.isSelected,
    required this.name,
    required this.icon,
    required this.onTap,
    this.showCartCount = false,
  });

  static const Color _deepGreen = Color(0xFF0E3121);
  static const Color _gold = Color(0xFFB68A22);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isSelected ? 38 : 32,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _deepGreen.withValues(alpha: .08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    icon,
                    color: isSelected ? _deepGreen : const Color(0xFF9A9F9B),
                    width: Dimensions.menuIconSize,
                    height: Dimensions.menuIconSize,
                  ),
                ),
                if (showCartCount)
                  Positioned(
                    right: -3,
                    top: -4,
                    child: Consumer<CartController>(
                      builder: (context, cart, child) {
                        if (cart.cartList.isEmpty) return const SizedBox.shrink();
                        return Container(
                          constraints: BoxConstraints(
                            minWidth: ResponsiveHelper.isTab(context) ? 20 : 16,
                            minHeight: ResponsiveHelper.isTab(context) ? 20 : 16,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cart.cartList.length > 99 ? '99+' : cart.cartList.length.toString(),
                            style: titilliumSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              getTranslated(name, context) ?? name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isSelected ? textBold : textRegular).copyWith(
                color: isSelected ? _deepGreen : const Color(0xFF8A8F8B),
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
