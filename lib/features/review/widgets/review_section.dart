import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/rating_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/widgets/review_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class ReviewSection extends StatelessWidget {
  final ProductDetailsController details;
  const ReviewSection({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewController>(
      builder: (context, reviewController, _) {
        final reviews = reviewController.reviewList;
        final average = double.tryParse(details.productDetailsModel?.averageReview ?? '0') ?? 0;
        final count = reviews?.length ?? 0;

        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          color: AsinDesign.card(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: AsinDesign.softCard(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AsinDesign.line(context)),
                ),
                child: Row(
                  children: [
                    RatingBar(rating: average, size: 17),
                    const SizedBox(width: 8),
                    Text(
                      average.toStringAsFixed(1),
                      style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '($count ${count == 1 ? 'review' : 'reviews'})',
                      style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Verified buyers can rate this product and share their experience.',
                      style: textRegular.copyWith(
                        color: AsinDesign.muted(context),
                        fontSize: 9.5,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      final loggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
                      if (loggedIn) {
                        RouterHelper.getOrderScreenRoute(
                          action: RouteAction.push,
                          initialIndex: 1,
                        );
                      } else {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (_) => NotLoggedInBottomSheetWidget(
                            fromPage: RouterHelper.productDetailsScreen,
                            onLoginSuccess: () => RouterHelper.getOrderScreenRoute(
                              action: RouteAction.push,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AsinDesign.primary,
                      side: const BorderSide(color: AsinDesign.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    icon: const Icon(Icons.rate_review_outlined, size: 14),
                    label: Text(
                      'Write a Review',
                      style: textBold.copyWith(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (reviews == null)
                const ReviewShimmer()
              else if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'No reviews yet. Be the first verified buyer to share a review.',
                    style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 11),
                  ),
                )
              else ...[
                for (final review in reviews.take(3)) ReviewWidget(reviewModel: review),
                if (reviews.length > 3)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => RouterHelper.getReviewRoute(
                        action: RouteAction.push,
                        reviewList: reviews,
                      ),
                      child: Text(
                        'View all ${reviews.length} reviews',
                        style: textBold.copyWith(color: AsinDesign.primary, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
