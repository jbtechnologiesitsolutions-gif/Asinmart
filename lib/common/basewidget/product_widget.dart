import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/discount_tag_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/shop_navigation_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Marketplace product card used across home/category/product lists.
///
/// The image area behaves like Blinkit-style product cards: if the API returns
/// multiple product images the customer can swipe inside the card and use the
/// dots as position feedback. Products without options can be added directly;
/// products with colour/size/variation options open the PDP so the customer can
/// make the required selection before adding to cart.
class ProductWidget extends StatefulWidget {
  final Product productModel;
  final int productNameLine;
  final double? margin;
  final SellerNavigationModel? sellerNavigationModel;

  const ProductWidget({
    super.key,
    required this.productModel,
    this.productNameLine = 2,
    this.margin,
    this.sellerNavigationModel,
  });

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  static const Color _cardBorder = Color(0xFFE2E5E7);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _imageSurface = Color(0xFFF8FAFB);
  static const Color _primary = Color(0xFF167A16);
  static const Color _asinGreen = Color(0xFF063D39);
  static const Color _muted = Color(0xFF6B7280);

  late final PageController _imageController;
  int _imageIndex = 0;
  bool _adding = false;

  Product get productModel => widget.productModel;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<String> _imagePaths() {
    final paths = <String>[];
    final thumb = productModel.thumbnailFullUrl?.path?.trim() ?? '';
    if (thumb.isNotEmpty) paths.add(thumb);
    for (final image in productModel.imagesFullUrl ?? const []) {
      final path = image.path?.trim() ?? '';
      if (path.isNotEmpty && !paths.contains(path)) paths.add(path);
    }
    return paths;
  }

  bool get _outOfStock =>
      (productModel.currentStock ?? 0) == 0 && productModel.productType == 'physical';

  bool get _requiresSelection =>
      (productModel.colors?.isNotEmpty ?? false) ||
      (productModel.choiceOptions?.isNotEmpty ?? false) ||
      (productModel.variation?.isNotEmpty ?? false) ||
      productModel.productType == 'digital';

  void _openDetails() {
    RouterHelper.getProductDetailsRoute(
      action: RouteAction.push,
      productId: productModel.id,
      slug: productModel.slug,
    );
  }

  Future<void> _onAddPressed(BuildContext context) async {
    if (_outOfStock || _adding) return;

    // Variable/colour/digital products must be configured on the PDP first.
    if (_requiresSelection) {
      _openDetails();
      return;
    }

    setState(() => _adding = true);
    final cart = CartModelBody(
      productId: productModel.id,
      variant: '',
      color: '',
      variation: null,
      quantity: productModel.minimumOrderQuantity ?? 1,
    );

    try {
      await Provider.of<CartController>(context, listen: false).addToCartAPI(
        cart,
        context,
        <ChoiceOptions>[],
        <int>[],
        popOnSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  int _simpleCartIndex(CartController controller) {
    if (_requiresSelection) return -1;
    return controller.cartList.indexWhere((item) =>
        item.productId == productModel.id &&
        (item.variant ?? '').isEmpty &&
        (item.color ?? '').isEmpty);
  }

  Future<void> _changeCartQuantity(BuildContext context, CartController controller, int index, int delta) async {
    if (index < 0 || index >= controller.cartList.length) return;
    final item = controller.cartList[index];
    final current = item.quantity ?? 1;
    final minimum = item.minimumOrderQuantity ?? productModel.minimumOrderQuantity ?? 1;
    final next = current + delta;

    if (delta < 0 && next < minimum) {
      if (item.id != null) {
        await controller.removeFromCartAPI(item.id, index);
      }
      return;
    }

    final max = item.maxQuantity;
    if (delta > 0 && max != null && max > 0 && next > max) return;
    await controller.updateCartProductQuantity(item.id, next, context, delta > 0, index);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final double rating = (productModel.rating?.isNotEmpty ?? false)
        ? double.tryParse('${productModel.rating?[0].average}') ?? 0
        : 0;
    final images = _imagePaths();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _openDetails,
      child: Container(
        margin: EdgeInsets.all(widget.margin ?? Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: .92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: _imageSurface,
                    child: images.isEmpty
                        ? const Center(child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFB8C0BF)))
                        : PageView.builder(
                            controller: _imageController,
                            itemCount: images.length,
                            onPageChanged: (index) {
                              if (mounted) setState(() => _imageIndex = index);
                            },
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
                              child: CustomImageWidget(
                                image: images[index],
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                  ),

                  if (_outOfStock)
                    Container(
                      color: Colors.black.withValues(alpha: .20),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.black.withValues(alpha: .62),
                        child: Text(
                          getTranslated('out_of_stock', context) ?? 'Out of stock',
                          textAlign: TextAlign.center,
                          style: textBold.copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),

                  if (images.length > 1)
                    Positioned(
                      left: 10,
                      bottom: 9,
                      child: Row(
                        children: List.generate(
                          images.length > 4 ? 4 : images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: _imageIndex == index ? 9 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: _imageIndex == index ? const Color(0xFF4F565C) : const Color(0xFFD4D9DE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 7,
                    right: isLtr ? 7 : null,
                    left: !isLtr ? 7 : null,
                    child: FavouriteButtonWidget(
                      sellerNavigationModel: widget.sellerNavigationModel,
                      backgroundColor: Colors.white,
                      productId: productModel.id,
                    ),
                  ),

                  Positioned(
                    right: isLtr ? 7 : null,
                    left: !isLtr ? 7 : null,
                    bottom: 7,
                    child: Consumer<CartController>(
                      builder: (context, cartController, _) {
                        final cartIndex = _simpleCartIndex(cartController);
                        if (cartIndex >= 0 && !_outOfStock) {
                          final cartItem = cartController.cartList[cartIndex];
                          final busy = cartItem.increment == true || cartItem.decrement == true;
                          return Container(
                            height: 36,
                            constraints: const BoxConstraints(minWidth: 88),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: busy
                                ? const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => _changeCartQuantity(context, cartController, cartIndex, -1),
                                        child: const SizedBox(width: 30, height: 36, child: Icon(Icons.remove_rounded, color: Colors.white, size: 20)),
                                      ),
                                      SizedBox(
                                        width: 28,
                                        child: Text(
                                          '${cartItem.quantity ?? 1}',
                                          textAlign: TextAlign.center,
                                          style: textBold.copyWith(color: Colors.white, fontSize: 13),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _changeCartQuantity(context, cartController, cartIndex, 1),
                                        child: const SizedBox(width: 30, height: 36, child: Icon(Icons.add_rounded, color: Colors.white, size: 20)),
                                      ),
                                    ],
                                  ),
                          );
                        }

                        return InkWell(
                          onTap: () => _onAddPressed(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 36,
                            constraints: const BoxConstraints(minWidth: 61),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _outOfStock ? const Color(0xFFF0F1F1) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _outOfStock ? const Color(0xFFC9CFCE) : _primary,
                                width: 1.5,
                              ),
                            ),
                            child: _adding
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
                                  )
                                : Text(
                                    _outOfStock ? 'SOLD' : 'ADD',
                                    style: textBold.copyWith(
                                      color: _outOfStock ? const Color(0xFF8C9492) : _primary,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (_hasDiscount())
                    DiscountTagWidget(
                      productModel: productModel,
                      positionedTop: 0,
                      topLeftBorderRadius: 12,
                      bottomRightBorderRadius: 8,
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((productModel.unit ?? '').trim().isNotEmpty) ...[
                    Text(
                      productModel.unit!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(color: const Color(0xFF303638), fontSize: 10.5),
                    ),
                    const SizedBox(height: 5),
                  ],
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        PriceConverter.convertPrice(
                          context,
                          productModel.unitPrice,
                          discountType: (productModel.clearanceSale?.discountAmount ?? 0) > 0
                              ? productModel.clearanceSale?.discountType
                              : productModel.discountType,
                          discount: (productModel.clearanceSale?.discountAmount ?? 0) > 0
                              ? productModel.clearanceSale?.discountAmount
                              : productModel.discount,
                        ),
                        style: textBold.copyWith(color: const Color(0xFF202426), fontSize: 16),
                      ),
                      if (_hasDiscount())
                        Text(
                          PriceConverter.convertPrice(context, productModel.unitPrice),
                          style: textRegular.copyWith(
                            color: _muted,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: _muted,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productModel.name ?? '',
                    maxLines: widget.productNameLine < 2 ? 2 : widget.productNameLine,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      color: const Color(0xFF25292C),
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                  if (rating > 0) ...[
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF9C934), size: 14),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1), style: textMedium.copyWith(fontSize: 10.5, color: const Color(0xFF5B6266))),
                        const SizedBox(width: 3),
                        Text(
                          '(${PriceConverter.longToShortPrice(productModel.reviewCount?.toDouble() ?? 0, withDecimalPoint: false)})',
                          style: textRegular.copyWith(fontSize: 9.5, color: _muted),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF707980)),
                      const SizedBox(width: 3),
                      Text('Fast delivery', style: textMedium.copyWith(color: const Color(0xFF707980), fontSize: 9.5)),
                    ],
                  ),
                  if (_requiresSelection) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Choose size / option',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textMedium.copyWith(color: _asinGreen, fontSize: 9.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasDiscount() =>
      (productModel.discount != null && productModel.discount! > 0) ||
      (productModel.clearanceSale?.discountAmount ?? 0) > 0;
}
