import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_directionality_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/app_localization.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class ProductTitleWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final String? averageRatting;
  const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});

  @override
  Widget build(BuildContext context) {
    if (productModel == null) return const SizedBox.shrink();

    final priceRange = ProductHelper.getProductPriceRange(productModel);
    final startingPrice = priceRange.start;
    final endingPrice = priceRange.end;
    final hasDiscount = (productModel!.discount ?? 0) > 0 || (productModel!.clearanceSale?.discountAmount ?? 0) > 0;
    final discountAmount = (productModel!.clearanceSale?.discountAmount ?? 0) > 0
        ? productModel!.clearanceSale?.discountAmount
        : productModel!.discount;
    final discountType = (productModel!.clearanceSale?.discountAmount ?? 0) > 0
        ? productModel!.clearanceSale?.discountType
        : productModel!.discountType;
    final storeName = productModel!.seller?.shop?.name?.trim();

    return Consumer<ProductDetailsController>(
      builder: (context, details, _) {
        return Container(
          color: AsinDesign.card(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (storeName?.isNotEmpty ?? false) ? storeName!.toUpperCase() : 'ASINMART',
                      style: textBold.copyWith(color: AsinDesign.gold, fontSize: 9.5, letterSpacing: .2),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      productModel!.name ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 20, height: 1.18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AsinDesign.star, size: 17),
                        const SizedBox(width: 3),
                        Text(
                          (double.tryParse(averageRatting ?? '0') ?? 0).toStringAsFixed(1),
                          style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 11.5),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '(${productModel!.reviewsCount ?? 0} Reviews)',
                          style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 10.5),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Divider(height: 1, color: AsinDesign.line(context)),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: CustomDirectionalityWidget(
                            child: Text(
                              '${startingPrice != null ? PriceConverter.convertPrice(context, startingPrice, discount: discountAmount, discountType: discountType) : ''}'
                              '${endingPrice != null ? ' - ${PriceConverter.convertPrice(context, endingPrice, discount: discountAmount, discountType: discountType)}' : ''}',
                              style: textBold.copyWith(color: AsinDesign.primary, fontSize: 23),
                            ),
                          ),
                        ),
                        if (hasDiscount && startingPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            PriceConverter.convertPrice(context, startingPrice),
                            style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 12, decoration: TextDecoration.lineThrough),
                          ),
                        ],
                        if (hasDiscount && discountType == 'percent') ...[
                          const SizedBox(width: 7),
                          Text(
                            '${(discountAmount ?? 0).toStringAsFixed(0)}% OFF',
                            style: textBold.copyWith(color: AsinDesign.success, fontSize: 10.5),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('Inclusive of all applicable taxes', style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
                  ],
                ),
              ),

              if (hasDiscount)
                _PdpSection(
                  title: 'Special Offers',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AsinDesign.goldSoft,
                      borderRadius: BorderRadius.circular(AsinDesign.radius),
                      border: Border.all(color: AsinDesign.gold.withValues(alpha: .45)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, color: AsinDesign.primary, size: 16),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            discountType == 'percent'
                                ? 'Save ${(discountAmount ?? 0).toStringAsFixed(0)}% on this product'
                                : 'Special product discount is already applied',
                            style: textMedium.copyWith(color: AsinDesign.primary, fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (productModel!.choiceOptions?.isNotEmpty ?? false)
                ...List.generate(productModel!.choiceOptions!.length, (index) {
                  final choice = productModel!.choiceOptions![index];
                  final rawOptions = choice.options ?? <String>[];
                  final optionIndexes = <int>[
                    for (int optionIndex = 0; optionIndex < rawOptions.length; optionIndex++)
                      if (rawOptions[optionIndex].trim().isNotEmpty) optionIndex,
                  ];
                  if (optionIndexes.isEmpty) return const SizedBox.shrink();
                  final title = (choice.title ?? choice.name ?? 'Option').trim();
                  final isSize = title.toLowerCase().contains('size');

                  return _PdpSection(
                    title: isSize ? 'Select Size' : 'Select ${title.toCapitalized()}',
                    child: Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: List.generate(optionIndexes.length, (position) {
                        final i = optionIndexes[position];
                        final selected = details.variationIndex != null &&
                            index < details.variationIndex!.length &&
                            details.variationIndex![index] == i;
                        return InkWell(
                          onTap: () => details.setCartVariationIndex(productModel!.minimumOrderQty ?? 1, index, i, context),
                          borderRadius: BorderRadius.circular(99),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 170),
                            constraints: const BoxConstraints(minWidth: 42, minHeight: 34),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected ? AsinDesign.goldSoft : AsinDesign.card(context),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: selected ? AsinDesign.gold : AsinDesign.line(context), width: selected ? 1.5 : 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              rawOptions[i].trim(),
                              style: textBold.copyWith(color: selected ? AsinDesign.primary : AsinDesign.foreground(context), fontSize: 10.5),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),

              if (productModel!.colors?.isNotEmpty ?? false)
                _PdpSection(
                  title: 'Select Color',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: List.generate(productModel!.colors!.length, (index) {
                      final color = productModel!.colors![index];
                      final selected = details.variantIndex == index;
                      return InkWell(
                        onTap: () => details.setCartVariantIndex(productModel!.minimumOrderQty ?? 1, index, context),
                        borderRadius: BorderRadius.circular(99),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 170),
                              width: 27,
                              height: 27,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: selected ? AsinDesign.gold : AsinDesign.line(context), width: selected ? 2 : 1),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorHelper.hexCodeToColor(color.code),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 6),
                              Text(color.name ?? '', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 10.5)),
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
                ),

              _PdpSection(
                title: 'Delivery Information',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                  decoration: BoxDecoration(
                    color: AsinDesign.softCard(context),
                    borderRadius: BorderRadius.circular(AsinDesign.radius),
                    border: Border.all(color: AsinDesign.line(context)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: AsinDesign.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Delivery availability and shipping cost are confirmed at checkout.', style: textRegular.copyWith(color: AsinDesign.foreground(context), fontSize: 10.5, height: 1.35)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PdpSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _PdpSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: BoxDecoration(
        color: AsinDesign.card(context),
        border: Border(top: BorderSide(color: AsinDesign.line(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 12.5)),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}
