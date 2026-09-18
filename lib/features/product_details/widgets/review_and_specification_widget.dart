import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

/// Compact PDP reviews drop-down.
///
/// The existing ProductDetailsController selection state is reused so no
/// review API or product-details business logic changes are required.
class ReviewAndSpecificationSectionWidget extends StatelessWidget {
  final double? averageReview;

  const ReviewAndSpecificationSectionWidget({
    super.key,
    this.averageReview,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductDetailsController, ReviewController>(
      builder: (context, productDetailsController, reviewController, _) {
        final isOpen = productDetailsController.isReviewSelected;
        final reviewCount = reviewController.reviewList?.length ?? 0;
        final rating = averageReview ?? 0;

        return Container(
          width: double.infinity,
          color: AsinDesign.card(context),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: InkWell(
            onTap: () => productDetailsController.selectReviewSection(!isOpen),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AsinDesign.softCard(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AsinDesign.line(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: AsinDesign.goldSoft,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.star_outline_rounded, color: AsinDesign.star, size: 18),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reviews & Ratings',
                          style: textBold.copyWith(
                            color: AsinDesign.foreground(context),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${rating.toStringAsFixed(1)} • $reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                          style: textRegular.copyWith(
                            color: AsinDesign.muted(context),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isOpen ? 'Hide' : 'See reviews',
                    style: textBold.copyWith(color: AsinDesign.primary, fontSize: 9.5),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: isOpen ? .5 : 0,
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AsinDesign.primary, size: 21),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
