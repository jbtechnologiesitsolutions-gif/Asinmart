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
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Template-aligned reusable marketplace card.
///
/// It preserves the existing add-to-cart, quantity update, variation routing,
/// wishlist and multi-image API behavior while matching the supplied dense
/// two-column commerce template.
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
  late final PageController _imageController;
  int _imageIndex = 0;
  bool _adding = false;
  bool _pressed = false;

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
      (productModel.choiceOptions?.any((e) => (e.options?.isNotEmpty ?? false)) ?? false) ||
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
      if (item.id != null) await controller.removeFromCartAPI(item.id, index);
      return;
    }
    final max = item.maxQuantity;
    if (delta > 0 && max != null && max > 0 && next > max) return;
    await controller.updateCartProductQuantity(item.id, next, context, delta > 0, index);
  }

  bool _hasDiscount() =>
      (productModel.discount != null && productModel.discount! > 0) ||
      (productModel.clearanceSale?.discountAmount ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final images = _imagePaths();
    final rating = (productModel.rating?.isNotEmpty ?? false)
        ? double.tryParse('${productModel.rating?[0].average}') ?? 0
        : 0.0;
    final salePrice = PriceConverter.convertPrice(
      context,
      productModel.unitPrice,
      discountType: (productModel.clearanceSale?.discountAmount ?? 0) > 0
          ? productModel.clearanceSale?.discountType
          : productModel.discountType,
      discount: (productModel.clearanceSale?.discountAmount ?? 0) > 0
          ? productModel.clearanceSale?.discountAmount
          : productModel.discount,
    );
    final mrp = PriceConverter.convertPrice(context, productModel.unitPrice);

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? .985 : 1,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _openDetails,
        child: Container(
          margin: EdgeInsets.all(widget.margin ?? Dimensions.paddingSizeExtraSmall),
          decoration: AsinDesign.cardDecoration(context, radius: AsinDesign.radiusLg),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.02,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: AsinDesign.softCard(context),
                      child: images.isEmpty
                          ? Icon(Icons.image_not_supported_outlined, color: AsinDesign.muted(context))
                          : PageView.builder(
                              controller: _imageController,
                              itemCount: images.length,
                              onPageChanged: (index) => setState(() => _imageIndex = index),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(6),
                                child: CustomImageWidget(
                                  image: images[index],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                    ),
                    if (_hasDiscount())
                      DiscountTagWidget(
                        productModel: productModel,
                        positionedTop: 0,
                        topLeftBorderRadius: AsinDesign.radiusLg,
                        bottomRightBorderRadius: AsinDesign.radius,
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavouriteButtonWidget(
                        sellerNavigationModel: widget.sellerNavigationModel,
                        backgroundColor: AsinDesign.card(context).withValues(alpha: .92),
                        productId: productModel.id,
                      ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        left: 10,
                        bottom: 8,
                        child: Row(
                          children: List.generate(
                            images.length > 4 ? 4 : images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: _imageIndex == index ? 11 : 6,
                              height: 5,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                color: _imageIndex == index ? AsinDesign.primary : AsinDesign.border,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_outOfStock)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: .22),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: AsinDesign.primaryDeep, borderRadius: BorderRadius.circular(99)),
                              child: Text(getTranslated('out_of_stock', context) ?? 'Out of stock', style: textBold.copyWith(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((productModel.unit ?? '').trim().isNotEmpty)
                      Text(
                        productModel.unit!.trim().toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5, letterSpacing: .2),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      productModel.name ?? '',
                      maxLines: widget.productNameLine < 2 ? 2 : widget.productNameLine,
                      overflow: TextOverflow.ellipsis,
                      style: textMedium.copyWith(color: AsinDesign.foreground(context), fontSize: 12.5, height: 1.2, fontWeight: FontWeight.w600),
                    ),
                    if (rating > 0) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: AsinDesign.star, size: 15),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1), style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 10.5)),
                        const SizedBox(width: 3),
                        Text('(${productModel.reviewCount ?? 0})', style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
                      ]),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(salePrice, style: textBold.copyWith(color: AsinDesign.primary, fontSize: 15.5, fontWeight: FontWeight.w700)),
                        if (_hasDiscount())
                          Text(mrp, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 10, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    if (_requiresSelection) ...[
                      const SizedBox(height: 4),
                      Text('Choose size / option', maxLines: 1, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(color: AsinDesign.primary, fontSize: 9.5)),
                    ],
                    const SizedBox(height: 9),
                    Consumer<CartController>(
                      builder: (context, cartController, _) {
                        final cartIndex = _simpleCartIndex(cartController);
                        if (cartIndex >= 0 && !_outOfStock) {
                          final cartItem = cartController.cartList[cartIndex];
                          final busy = cartItem.increment == true || cartItem.decrement == true;
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(color: AsinDesign.primary, borderRadius: BorderRadius.circular(AsinDesign.radius)),
                            child: busy
                                ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(onTap: () => _changeCartQuantity(context, cartController, cartIndex, -1), child: const SizedBox(width: 40, height: 40, child: Icon(Icons.remove_rounded, color: Colors.white, size: 19))),
                                      Text('${cartItem.quantity ?? 1}', style: textBold.copyWith(color: Colors.white, fontSize: 13)),
                                      InkWell(onTap: () => _changeCartQuantity(context, cartController, cartIndex, 1), child: const SizedBox(width: 40, height: 40, child: Icon(Icons.add_rounded, color: Colors.white, size: 19))),
                                    ],
                                  ),
                          );
                        }
                        return InkWell(
                          onTap: _outOfStock ? null : () => _onAddPressed(context),
                          borderRadius: BorderRadius.circular(AsinDesign.radius),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _outOfStock ? AsinDesign.softCard(context) : AsinDesign.primary,
                              borderRadius: BorderRadius.circular(AsinDesign.radius),
                            ),
                            child: _adding
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_requiresSelection ? Icons.tune_rounded : Icons.add_rounded, color: _outOfStock ? AsinDesign.muted(context) : Colors.white, size: 17),
                                      const SizedBox(width: 5),
                                      Text(
                                        _outOfStock ? 'Sold Out' : (_requiresSelection ? 'Select Options' : 'Add to Cart'),
                                        style: textBold.copyWith(color: _outOfStock ? AsinDesign.muted(context) : Colors.white, fontSize: 11.5),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
