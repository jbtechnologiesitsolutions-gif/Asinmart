import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
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

  IconData _iconForName() {
    switch (name.toLowerCase()) {
      case 'home': return Icons.home_outlined;
      case 'category': return Icons.grid_view_rounded;
      case 'orders': return Icons.receipt_long_outlined;
      case 'stores': return Icons.storefront_outlined;
      case 'cart': return Icons.shopping_cart_outlined;
      case 'profile': return Icons.account_circle_outlined;
      default: return Icons.more_horiz_rounded;
    }
  }

  String _label(BuildContext context) {
    final translated = getTranslated(name, context);
    if (translated != null && translated.trim().isNotEmpty) return translated;
    if (name.toLowerCase() == 'category') return 'Categories';
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = AsinDesign.primary;
    final mutedColor = AsinDesign.muted(context);

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  scale: isSelected ? 1.06 : 1,
                  child: Icon(_iconForName(), color: isSelected ? selectedColor : mutedColor, size: 23),
                ),
                if (showCartCount)
                  Positioned(
                    right: -8,
                    top: -7,
                    child: Consumer<CartController>(
                      builder: (context, cart, child) {
                        if (cart.cartList.isEmpty) return const SizedBox.shrink();
                        return Container(
                          constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AsinDesign.gold,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: AsinDesign.card(context), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cart.cartList.length > 99 ? '99+' : '${cart.cartList.length}',
                            style: textBold.copyWith(color: AsinDesign.primaryDeep, fontSize: 8),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              _label(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isSelected ? textBold : textRegular).copyWith(
                color: isSelected ? selectedColor : mutedColor,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 16 : 0,
              height: 2.5,
              decoration: BoxDecoration(color: AsinDesign.gold, borderRadius: BorderRadius.circular(99)),
            ),
          ],
        ),
      ),
    );
  }
}
