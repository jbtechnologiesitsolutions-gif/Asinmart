import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
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

/// Compact marketplace product card based on the supplied template.
///
/// Existing product/gallery/cart/wishlist APIs are intentionally preserved.
/// Products that require a size, colour or variation still open the PDP before
/// adding so an invalid cart variation is never submitted.
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
  static const Color _actionBlack = Color(0xFF151515);

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
      (productModel.choiceOptions?.any((e) => (e.options?.any((o) => o.trim().isNotEmpty) ?? false)) ?? false) ||
      (productModel.variation?.isNotEmpty ?? false) ||
      productModel.productType == 'digital';

  double get _effectiveDiscount => (productModel.clearanceSale?.discountAmount ?? 0) > 0
      ? (productModel.clearanceSale?.discountAmount ?? 0)
      : (productModel.discount ?? 0);

  String? get _effectiveDiscountType => (productModel.clearanceSale?.discountAmount ?? 0) > 0
      ? productModel.clearanceSale?.discountType
      : productModel.discountType;

  bool get _hasDiscount => _effectiveDiscount > 0;

  String _discountLabel() {
    if (!_hasDiscount) return '';
    if (_effectiveDiscountType == 'percent') {
      return '${_effectiveDiscount.toStringAsFixed(0)}% OFF';
    }
    return 'OFFER';
  }

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

  Future<void> _changeCartQuantity(
    BuildContext context,
    CartController controller,
    int index,
    int delta,
  ) async {
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

  @override
  Widget build(BuildContext context) {
    final images = _imagePaths();
    final rating = (productModel.rating?.isNotEmpty ?? false)
        ? double.tryParse('${productModel.rating?[0].average}') ?? 0
        : 0.0;
    final brandName = productModel.brand?.name?.trim();
    final salePrice = PriceConverter.convertPrice(
      context,
      productModel.unitPrice,
      discountType: _effectiveDiscountType,
      discount: _effectiveDiscount,
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
          decoration: AsinDesign.cardDecoration(context, radius: 10),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.04,
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
                                padding: const EdgeInsets.all(5),
                                child: CustomImageWidget(
                                  image: images[index],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: FavouriteButtonWidget(
                        sellerNavigationModel: widget.sellerNavigationModel,
                        backgroundColor: AsinDesign.card(context).withValues(alpha: .94),
                        productId: productModel.id,
                      ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        left: 8,
                        bottom: 7,
                        child: Row(
                          children: List.generate(
                            images.length > 4 ? 4 : images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: _imageIndex == index ? 10 : 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                color: _imageIndex == index ? AsinDesign.gold : AsinDesign.border,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_outOfStock)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: .20),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: AsinDesign.primaryDeep,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                getTranslated('out_of_stock', context) ?? 'Out of stock',
                                style: textBold.copyWith(color: Colors.white, fontSize: 9.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (brandName?.isNotEmpty ?? false) ? brandName!.toUpperCase() : 'ASINMART',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                        color: AsinDesign.primary,
                        fontSize: 8.5,
                        letterSpacing: .15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      productModel.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                        color: AsinDesign.foreground(context),
                        fontSize: 11.5,
                        height: 1.16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star_outline_rounded, color: AsinDesign.star, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: textMedium.copyWith(color: AsinDesign.foreground(context), fontSize: 9.5),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '(${productModel.reviewCount ?? 0})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 8.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          salePrice,
                          style: textBold.copyWith(color: AsinDesign.primary, fontSize: 14.5),
                        ),
                        if (_hasDiscount)
                          Text(
                            mrp,
                            style: textRegular.copyWith(
                              color: AsinDesign.muted(context),
                              fontSize: 9,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    if (_hasDiscount) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AsinDesign.goldSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _discountLabel(),
                          style: textBold.copyWith(color: AsinDesign.primary, fontSize: 8.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Consumer<CartController>(
                      builder: (context, cartController, _) {
                        final cartIndex = _simpleCartIndex(cartController);
                        if (cartIndex >= 0 && !_outOfStock) {
                          final cartItem = cartController.cartList[cartIndex];
                          final busy = cartItem.increment == true || cartItem.decrement == true;
                          return Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: _actionBlack,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: busy
                                ? const Center(
                                    child: SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => _changeCartQuantity(context, cartController, cartIndex, -1),
                                        child: const SizedBox(width: 36, height: 36, child: Icon(Icons.remove_rounded, color: Colors.white, size: 18)),
                                      ),
                                      Text('${cartItem.quantity ?? 1}', style: textBold.copyWith(color: Colors.white, fontSize: 12)),
                                      InkWell(
                                        onTap: () => _changeCartQuantity(context, cartController, cartIndex, 1),
                                        child: const SizedBox(width: 36, height: 36, child: Icon(Icons.add_rounded, color: Colors.white, size: 18)),
                                      ),
                                    ],
                                  ),
                          );
                        }

                        return InkWell(
                          onTap: _outOfStock ? null : () => _onAddPressed(context),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _outOfStock ? AsinDesign.softCard(context) : _actionBlack,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: _adding
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        color: _outOfStock ? AsinDesign.muted(context) : Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _outOfStock ? 'Sold Out' : 'Add',
                                        style: textBold.copyWith(
                                          color: _outOfStock ? AsinDesign.muted(context) : Colors.white,
                                          fontSize: 10.5,
                                        ),
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
