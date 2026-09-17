
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_directionality_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/app_localization.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';


class ProductTitleWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final String? averageRatting;
  const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});

  @override
  Widget build(BuildContext context) {

    ({double? end, double? start})? priceRange = ProductHelper.getProductPriceRange(productModel);
    double? startingPrice = priceRange.start;
    double? endingPrice = priceRange.end;

    return productModel != null? Container(
      padding: const EdgeInsets.symmetric(horizontal : Dimensions.homePagePadding),
      child: Consumer<ProductDetailsController>(
        builder: (context, details, child) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
                productModel!.name ?? '',
                style: titleRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CustomDirectionalityWidget(
                child: Text(
                  '${startingPrice != null ?
                      PriceConverter.convertPrice(
                        context,
                        startingPrice,
                        discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                            ? productModel?.clearanceSale?.discountAmount
                            : productModel?.discount,
                        discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                            ? productModel?.clearanceSale?.discountType
                            : productModel?.discountType,
                      )
                      : ''}'
                  '${endingPrice != null
                      ? ' - ${PriceConverter.convertPrice(
                            context,
                            endingPrice,
                            discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                ? productModel?.clearanceSale?.discountAmount
                                : productModel?.discount,
                            discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                ? productModel?.clearanceSale?.discountType
                                : productModel?.discountType,
                          )}'
                      : ''}',
                  style: titilliumBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),

              if((productModel!.discount != null && productModel!.discount! > 0) || (productModel!.clearanceSale != null && productModel!.clearanceSale!.discountAmount! > 0) )...[
                const SizedBox(width: Dimensions.paddingSizeSmall),

                CustomDirectionalityWidget(
                  child: Text('${PriceConverter.convertPrice(context, startingPrice)}'
                      '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                      style: titilliumRegular.copyWith(color: Theme.of(context).hintColor,
                          decoration: TextDecoration.lineThrough)),
                ),
              ],
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),


            if (productModel!.reviews != null && productModel!.reviews!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.star_rate_rounded, color: Colors.orange, size: Dimensions.paddingSizeDefault),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      (double.tryParse(averageRatting ?? '0') ?? 0).toStringAsFixed(1),
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Text(
                    '(${PriceConverter.longToShortPrice(productModel?.reviewsCount?.toDouble() ?? 0, withDecimalPoint: false)})',
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: Dimensions.paddingSizeSmall),


            Consumer<ReviewController>(
              builder: (context, reviewController, _) {
                return Row(children: [

                  if(reviewController.reviewList != null && (reviewController.reviewList?.length ?? 0) > 0)
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '${reviewController.reviewList != null ? reviewController.reviewList!.length : 0} ',
                      style: textMedium.copyWith(
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Theme.of(context).hintColor : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),

                    TextSpan(
                      text: '${getTranslated('reviews', context)} ',
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ])),


                  if((details.orderCount ?? 0) > 0)
                  Text.rich(TextSpan(children: [
                    TextSpan(text: ' ${(reviewController.reviewList != null && (reviewController.reviewList?.length ?? 0) > 0) ? '| ' : ''} ${details.orderCount}', style: textMedium.copyWith(
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Theme.of(context).hintColor : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeDefault,
                    )),

                    TextSpan(text: ' ${getTranslated('orders', context)} ',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ])),

                  if((details.wishCount ?? 0) > 0)
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '${((details.orderCount ?? 0) > 0) ? '| ' : ''} ${details.wishCount}', style: textMedium.copyWith(
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Theme.of(context).hintColor : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeDefault,
                    )),

                    TextSpan(
                        text: ' ${getTranslated('wish_listed', context)}',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ])),

                ]);
              }),

              Consumer<ReviewController>(
                builder: (context, reviewController, _) {
                  if(((details.wishCount ?? 0) > 0) || ((details.orderCount ?? 0) > 0) || ((reviewController.reviewList != null && (reviewController.reviewList?.length ?? 0) > 0))) {
                    return const SizedBox(height: Dimensions.paddingSizeSmall);
                  }
                  return SizedBox();
                }
              ),

            if(_isVariationAvailable()) ...[
              Text(
                '${getTranslated('available', context)}',
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],

            /// Available colour - selectable directly on the PDP.
            if(productModel!.colors != null && productModel!.colors!.isNotEmpty) ...[
              Text('${getTranslated('color', context)} :', style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: List.generate(productModel!.colors!.length, (index) {
                  final selected = details.variantIndex == index;
                  return InkWell(
                    onTap: () => details.setCartVariantIndex(productModel!.minimumOrderQty ?? 1, index, context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42,
                      height: 42,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? const Color(0xFF063D39) : Theme.of(context).hintColor.withValues(alpha: .28),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorHelper.hexCodeToColor(productModel?.colors?[index].code),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            /// Size / variation options - selectable on the PDP and preserved
            /// when Add to Cart opens the configuration sheet.
            if(productModel!.choiceOptions != null && productModel!.choiceOptions!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: productModel!.choiceOptions!.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final choice = productModel!.choiceOptions![index];
                  final options = choice.options ?? <String>[];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${choice.title?.toCapitalized() ?? 'Option'} :',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(options.length, (i) {
                            final selected = details.variationIndex != null &&
                                index < details.variationIndex!.length &&
                                details.variationIndex![index] == i;
                            return InkWell(
                              onTap: () => details.setCartVariationIndex(productModel!.minimumOrderQty ?? 1, index, i, context),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 48, minHeight: 40),
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFFEAF4F1) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected ? const Color(0xFF063D39) : Theme.of(context).hintColor.withValues(alpha: .30),
                                  ),
                                ),
                                child: Text(
                                  options[i].trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: selected ? const Color(0xFF063D39) : Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ]);
        },
      ),
    ) : const SizedBox();
  }

  bool _isVariationAvailable() => ((productModel!.colors != null && productModel!.colors!.isNotEmpty) && productModel!.choiceOptions != null && productModel!.choiceOptions!.isNotEmpty);
}


