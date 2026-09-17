import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final int length;

  const CategoryWidget({
    super.key,
    required this.category,
    required this.index,
    required this.length,
  });

  static const Color _deepGreen = Color(0xFF0E3121);
  static const Color _softGold = Color(0xFFF2E7C7);

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final homeLength = length >= 10 ? 10 : length;

    return Padding(
      padding: EdgeInsets.only(
        left: isLtr ? (index == 0 ? Dimensions.homePagePadding : 10) : 0,
        right: index + 1 == homeLength ? Dimensions.homePagePadding : (isLtr ? 0 : 10),
      ),
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _softGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _deepGreen.withValues(alpha: .07),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  image: '${category.imageFullUrl?.path}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              category.name ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                height: 1.15,
                color: const Color(0xFF263129),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
