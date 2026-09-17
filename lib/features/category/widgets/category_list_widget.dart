import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CategoryListWidget extends StatelessWidget {
  final bool isHomePage;
  const CategoryListWidget({super.key, required this.isHomePage});

  static const Color _deepGreen = Color(0xFF063D39);
  static const Color _gold = Color(0xFFF5B82E);
  static const Color _border = Color(0xFFDCE7E5);

  static IconData? _marketplaceIconFor(String categoryName) {
    final String name = categoryName.toLowerCase();
    if (name.contains('fashion') || name.contains('cloth') || name.contains('apparel')) {
      return Icons.shopping_bag_outlined;
    }
    if (name.contains('mobile') || name.contains('phone')) {
      return Icons.phone_android_rounded;
    }
    if (name.contains('electronic') || name.contains('computer') || name.contains('laptop')) {
      return Icons.laptop_mac_rounded;
    }
    if (name.contains('beauty') || name.contains('cosmetic') || name.contains('makeup')) {
      return Icons.palette_outlined;
    }
    if (name.contains('grocery') || name.contains('food')) {
      return Icons.local_grocery_store_outlined;
    }
    if (name.contains('home') || name.contains('furniture')) {
      return Icons.chair_outlined;
    }
    if (name.contains('baby') || name.contains('kid')) {
      return Icons.child_friendly_outlined;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.categoryList.isEmpty) {
          return const CategoryShimmerWidget();
        }

        final visibleCount = categoryProvider.categoryList.length > 5
            ? 5
            : categoryProvider.categoryList.length;

        return Container(
          color: Colors.white,
          height: 78,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            scrollDirection: Axis.horizontal,
            itemCount: visibleCount + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryShortcut(
                  title: 'For You',
                  selected: true,
                  icon: Icons.auto_awesome_rounded,
                  onTap: () {},
                );
              }

              final category = categoryProvider.categoryList[index - 1];
              final String categoryName = category.name ?? '';
              return _CategoryShortcut(
                title: categoryName,
                image: '${category.imageFullUrl?.path}',
                icon: _marketplaceIconFor(categoryName),
                onTap: () {
                  RouterHelper.getBrandCategoryRoute(
                    action: RouteAction.push,
                    isBrand: false,
                    id: category.id,
                    name: category.name,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  final String title;
  final String? image;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryShortcut({
    required this.title,
    required this.onTap,
    this.image,
    this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.black.withValues(alpha: .05)),
            bottom: BorderSide(
              color: selected ? CategoryListWidget._gold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FAF9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CategoryListWidget._border),
              ),
              child: icon != null
                  ? Icon(icon, color: CategoryListWidget._deepGreen, size: 19)
                  : CustomImageWidget(
                      image: image ?? '',
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                fontSize: 10,
                height: 1.05,
                color: const Color(0xFF25302D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
