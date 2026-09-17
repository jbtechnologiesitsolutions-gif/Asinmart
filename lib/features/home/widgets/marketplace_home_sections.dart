import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/home_category_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const Color asinDeepGreen = Color(0xFF00382F);
const Color asinGold = Color(0xFFF5B82E);
const Color asinSoftBackground = Color(0xFFF7F8F6);

class MarketplacePromoRibbon extends StatelessWidget {
  const MarketplacePromoRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
      child: Row(
        children: [
          Expanded(
            child: _PromoChip(
              icon: Icons.local_offer_outlined,
              title: 'INDIA DEALS',
              subtitle: 'Best offers for you',
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _PromoChip(
              icon: Icons.verified_user_outlined,
              title: 'VERIFIED SELLERS',
              subtitle: 'Trusted marketplace',
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PromoChip({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: asinDeepGreen, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textBold.copyWith(color: asinDeepGreen, fontSize: 9)),
                const SizedBox(height: 1),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: textRegular.copyWith(color: const Color(0xFF6C7774), fontSize: 8.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarketplaceCoverFlowShowcase extends StatefulWidget {
  const MarketplaceCoverFlowShowcase({super.key});

  @override
  State<MarketplaceCoverFlowShowcase> createState() => _MarketplaceCoverFlowShowcaseState();
}

class _MarketplaceCoverFlowShowcaseState extends State<MarketplaceCoverFlowShowcase> {
  late final PageController _pageController;
  Timer? _timer;
  int _activeIndex = 0;
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: .63);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _ensureAutoPlay(int itemCount) {
    if (itemCount <= 1) {
      _timer?.cancel();
      _lastItemCount = itemCount;
      return;
    }
    if (_timer != null && _lastItemCount == itemCount) return;
    _timer?.cancel();
    _lastItemCount = itemCount;
    _timer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
      if (!mounted || !_pageController.hasClients || itemCount <= 1) return;
      final next = (_activeIndex + 1) % itemCount;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 620), curve: Curves.easeOutCubic);
    });
  }

  List<Product> _products(ProductController controller) {
    final featured = controller.featuredProductModel?.products ?? <Product>[];
    final latest = controller.latestProductModel?.products ?? <Product>[];
    final top = controller.allProductModel?.products ?? <Product>[];

    // The website Cover Flow prefers a curated/sponsored list and falls back to
    // in-house marketplace products. The app currently has no advertisement API,
    // so the closest API-safe equivalent is Featured -> Latest -> Top products.
    final source = featured.length >= 3 ? featured : (latest.length >= 3 ? latest : top);
    return source.where((product) => product.id != null && (product.slug ?? '').isNotEmpty).take(8).toList();
  }

  void _goTo(int index, int length) {
    if (length == 0 || !_pageController.hasClients) return;
    final target = (index % length + length) % length;
    _pageController.animateToPage(target, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final products = _products(productController);
        if (products.isEmpty) return const SizedBox.shrink();
        WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAutoPlay(products.length));

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
          decoration: BoxDecoration(
            color: asinDeepGreen,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: .10), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Text(
                '✦ LUXURY PRODUCT SHOWCASE',
                style: textBold.copyWith(color: asinGold, fontSize: 9.5, letterSpacing: 1.1),
              ),
              const SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textBold.copyWith(color: Colors.white, fontSize: 17),
                  children: const [
                    TextSpan(text: 'The Collection, in '),
                    TextSpan(text: 'Cover Flow', style: TextStyle(color: asinGold)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Popular marketplace picks while in-house products are curated.',
                textAlign: TextAlign.center,
                style: textRegular.copyWith(color: Colors.white70, fontSize: 9.5),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 310,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: products.length,
                      onPageChanged: (index) => setState(() => _activeIndex = index),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double page = _activeIndex.toDouble();
                            if (_pageController.hasClients && _pageController.position.haveDimensions) {
                              page = _pageController.page ?? page;
                            }
                            final delta = index - page;
                            final double distance = delta.abs().clamp(0.0, 2.0).toDouble();
                            final double scale = 1 - (distance * .13);
                            final double rotation = (delta.clamp(-1.5, 1.5).toDouble()) * -.22;
                            final double opacity = 1 - (distance * .27);

                            final matrix = Matrix4.identity()
                              ..setEntry(3, 2, .0012)
                              ..rotateY(rotation)
                              ..scale(scale, scale, 1.0);

                            return Opacity(
                              opacity: opacity.clamp(.35, 1.0).toDouble(),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: matrix,
                                child: child,
                              ),
                            );
                          },
                          child: _CoverFlowProductCard(
                            product: product,
                            active: index == _activeIndex,
                            onTap: () {
                              if (index != _activeIndex) {
                                _goTo(index, products.length);
                                return;
                              }
                              RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: product.id, slug: product.slug);
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      child: _CoverArrow(icon: Icons.chevron_left_rounded, onTap: () => _goTo(_activeIndex - 1, products.length)),
                    ),
                    Positioned(
                      right: 0,
                      child: _CoverArrow(icon: Icons.chevron_right_rounded, onTap: () => _goTo(_activeIndex + 1, products.length)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoverFlowProductCard extends StatelessWidget {
  final Product product;
  final bool active;
  final VoidCallback onTap;

  const _CoverFlowProductCard({required this.product, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = PriceConverter.convertPrice(
      context,
      product.unitPrice,
      discountType: (product.clearanceSale?.discountAmount ?? 0) > 0 ? product.clearanceSale?.discountType : product.discountType,
      discount: (product.clearanceSale?.discountAmount ?? 0) > 0 ? product.clearanceSale?.discountAmount : product.discount,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: active ? asinGold : Colors.white, width: active ? 1.6 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: active ? .22 : .10), blurRadius: active ? 20 : 9, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF8F8F5),
                padding: const EdgeInsets.all(8),
                child: CustomImageWidget(image: '${product.thumbnailFullUrl?.path}', fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
              child: Column(
                children: [
                  Text(product.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: textMedium.copyWith(color: const Color(0xFF1F2826), fontSize: 10.5)),
                  const SizedBox(height: 3),
                  Text(price, style: textBold.copyWith(color: asinDeepGreen, fontSize: 11)),
                  const SizedBox(height: 7),
                  Container(
                    height: 29,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: asinDeepGreen, borderRadius: BorderRadius.circular(7)),
                    child: Text('Shop now  →', style: textBold.copyWith(color: Colors.white, fontSize: 9.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CoverArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .19), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class MarketplaceShopByCategory extends StatelessWidget {
  const MarketplaceShopByCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryController, _) {
        final categories = categoryController.categoryList.take(6).toList();
        if (categories.isEmpty) return const SizedBox.shrink();

        return _HomeSectionShell(
          eyebrow: 'SHOP BY CATEGORY',
          title: 'Discover more, faster',
          actionText: 'View all  →',
          onAction: () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'category'),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.03, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () => RouterHelper.getBrandCategoryRoute(action: RouteAction.push, isBrand: false, id: category.id, name: category.name),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE7EBE8)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .025), blurRadius: 7, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(image: '${category.imageFullUrl?.path}', width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(category.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: textMedium.copyWith(color: const Color(0xFF26302D), fontSize: 9.5)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MarketplaceFashionCollections extends StatelessWidget {
  const MarketplaceFashionCollections({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, bannerController, _) {
        final banners = bannerController.footerBannerList ?? [];
        if (banners.isEmpty) return const SizedBox.shrink();
        final visible = banners.take(2).toList();

        return _HomeSectionShell(
          eyebrow: 'EXPLORE FASHION',
          title: 'Fashion Collections',
          actionText: 'View all fashion  →',
          onAction: () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'category'),
          child: SizedBox(
            height: 142,
            child: Row(
              children: List.generate(visible.length, (index) {
                final banner = visible[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 0 && visible.length > 1 ? 7 : 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => bannerController.clickBannerRedirect(
                        context,
                        banner.resourceId,
                        banner.resourceType == 'product' ? banner.product : null,
                        banner.resourceType,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomImageWidget(image: '${banner.photoFullUrl?.path}', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class MarketplaceProductSection extends StatelessWidget {
  final String eyebrow;
  final String title;
  final ProductType productType;
  final List<Product>? Function(ProductController controller) productsBuilder;

  const MarketplaceProductSection({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.productType,
    required this.productsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        final products = (productsBuilder(controller) ?? []).take(10).toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return _HomeSectionShell(
          eyebrow: eyebrow,
          title: title,
          actionText: 'View all  →',
          onAction: () => RouterHelper.getViewAllProductScreenRoute(productType: productType, action: RouteAction.push),
          child: SizedBox(
            height: 332,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) => SizedBox(
                width: 170,
                child: ProductWidget(productModel: products[index], margin: 0),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MarketplaceHomeCategoryCarousels extends StatelessWidget {
  const MarketplaceHomeCategoryCarousels({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        final categories = controller.homeCategoryProductList.where((category) => category.products?.isNotEmpty ?? false).toList();
        final hasFashion = categories.any((category) => (category.name ?? '').toLowerCase().contains('fashion'));
        final fallbackFashionProducts = controller.fashionCategoryProductModel?.products ?? <Product>[];
        if (!hasFashion && fallbackFashionProducts.isNotEmpty) {
          categories.insert(
            0,
            HomeCategoryProduct(
              id: controller.fashionCategoryId,
              name: 'Fashion',
              products: fallbackFashionProducts,
            ),
          );
        }
        if (categories.isEmpty) return const SizedBox.shrink();

        categories.sort((a, b) {
          final aFashion = (a.name ?? '').toLowerCase().contains('fashion');
          final bFashion = (b.name ?? '').toLowerCase().contains('fashion');
          if (aFashion == bFashion) return 0;
          return aFashion ? -1 : 1;
        });

        return Column(
          children: categories.map((category) => _CategoryProductCarousel(category: category)).toList(),
        );
      },
    );
  }
}

class _CategoryProductCarousel extends StatefulWidget {
  final HomeCategoryProduct category;

  const _CategoryProductCarousel({required this.category});

  @override
  State<_CategoryProductCarousel> createState() => _CategoryProductCarouselState();
}

class _CategoryProductCarouselState extends State<_CategoryProductCarousel> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(double direction) {
    if (!_controller.hasClients) return;
    final viewport = _controller.position.viewportDimension;
    final double target = (_controller.offset + direction * math.max(250, viewport * .72)).clamp(0.0, _controller.position.maxScrollExtent).toDouble();
    _controller.animateTo(target, duration: const Duration(milliseconds: 430), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.category.products ?? <Product>[];
    if (products.isEmpty) return const SizedBox.shrink();

    return _HomeSectionShell(
      eyebrow: (widget.category.name ?? '').toLowerCase().contains('fashion') ? 'EXPLORE FASHION' : 'CATEGORY PICKS',
      title: widget.category.name ?? '',
      actionText: 'View all  →',
      onAction: () => RouterHelper.getBrandCategoryRoute(action: RouteAction.push, isBrand: false, id: widget.category.id, name: widget.category.name),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 332,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) => SizedBox(width: 170, child: ProductWidget(productModel: products[index], margin: 0)),
            ),
          ),
          Positioned(left: 0, child: _HorizontalArrow(icon: Icons.chevron_left_rounded, onTap: () => _move(-1))),
          Positioned(right: 0, child: _HorizontalArrow(icon: Icons.chevron_right_rounded, onTap: () => _move(1))),
        ],
      ),
    );
  }
}

class _HorizontalArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HorizontalArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: asinDeepGreen.withValues(alpha: .84), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class MarketplaceMultiVendorCard extends StatelessWidget {
  const MarketplaceMultiVendorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 13),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: asinDeepGreen, borderRadius: BorderRadius.circular(13)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: asinGold, borderRadius: BorderRadius.circular(5)),
            child: Text('VENDOR PORTAL', style: textBold.copyWith(color: asinDeepGreen, fontSize: 8)),
          ),
          const SizedBox(height: 5),
          Text('Multi-Vendor Marketplace', style: textBold.copyWith(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 3),
          Text('Manage your store or start selling with India’s fast-growing seller hub.', style: textRegular.copyWith(color: Colors.white70, fontSize: 9.5)),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _VendorActionCard(
                  icon: Icons.storefront_outlined,
                  title: 'Vendor Login',
                  subtitle: 'Manage products & orders',
                  background: const Color(0xFF164E46),
                  foreground: Colors.white,
                  onTap: () async {
                    final uri = Uri.parse('${AppConstants.baseUrl}/vendor/auth/login');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _VendorActionCard(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Register Store',
                  subtitle: 'Start selling online',
                  background: asinGold,
                  foreground: asinDeepGreen,
                  onTap: () async {
                    final uri = Uri.parse('${AppConstants.baseUrl}/vendor/auth/registration/index');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _VendorActionCard({required this.icon, required this.title, required this.subtitle, required this.background, required this.foreground, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white.withValues(alpha: .12))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 17),
            const Spacer(),
            Text(title, maxLines: 1, style: textBold.copyWith(color: foreground, fontSize: 10.5)),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: textRegular.copyWith(color: foreground.withValues(alpha: .75), fontSize: 8)),
          ],
        ),
      ),
    );
  }
}

class MarketplaceVerifiedStores extends StatelessWidget {
  const MarketplaceVerifiedStores({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
      builder: (context, shopController, _) {
        final sellers = shopController.topSellerModel?.sellers ?? [];
        if (sellers.isEmpty) return const SizedBox.shrink();

        return _HomeSectionShell(
          title: 'Top Verified Stores',
          actionText: 'View All',
          onAction: () => RouterHelper.getAllTopSellerRoute(action: RouteAction.push, title: 'Top Verified Stores'),
          child: SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sellers.length > 8 ? 8 : sellers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final seller = sellers[index];
                final shop = seller.shop;
                return InkWell(
                  onTap: () {
                    if ((shop?.slug ?? '').isEmpty) return;
                    RouterHelper.getShopOverviewScreen(slug: shop!.slug!, scrollController: ScrollController(), action: RouteAction.push);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 105,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE7EAE7))),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF0F6F4)),
                          clipBehavior: Clip.antiAlias,
                          child: CustomImageWidget(image: '${shop?.imageFullUrl?.path ?? seller.imageFullUrl?.path}', fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 6),
                        Text(shop?.name ?? '${seller.fName ?? ''} ${seller.lName ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: textBold.copyWith(color: const Color(0xFF2A3431), fontSize: 9.5)),
                        const SizedBox(height: 2),
                        Text('${seller.productCount ?? 0} Products', style: textRegular.copyWith(color: const Color(0xFF7B8582), fontSize: 8)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MarketplaceTrustSection extends StatelessWidget {
  const MarketplaceTrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <_TrustItem>[
      _TrustItem(Icons.local_shipping_outlined, 'Fast Shipping', 'Quick and dependable delivery'),
      _TrustItem(Icons.verified_outlined, 'Authentic Products', 'Curated marketplace products'),
      _TrustItem(Icons.lock_outline_rounded, 'Secure Payment', 'Protected checkout transactions'),
      _TrustItem(Icons.support_agent_rounded, 'Customer Support', 'Help whenever you need it'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 17),
      child: Column(
        children: [
          Text('WHY SHOP WITH US', style: textBold.copyWith(color: asinGold, fontSize: 8.5, letterSpacing: .8)),
          const SizedBox(height: 4),
          Text('Why Customers Trust AsinMart', style: textBold.copyWith(color: const Color(0xFF232B29), fontSize: 15)),
          const SizedBox(height: 4),
          Text('Shop with confidence through reliable delivery, protected payments and verified sellers.', textAlign: TextAlign.center, style: textRegular.copyWith(color: const Color(0xFF7B8582), fontSize: 9)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.62, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF7F9F8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE9ECEA))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: asinDeepGreen, size: 20),
                    const SizedBox(height: 5),
                    Text(item.title, textAlign: TextAlign.center, style: textBold.copyWith(color: const Color(0xFF38413E), fontSize: 9.5)),
                    const SizedBox(height: 2),
                    Text(item.subtitle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: textRegular.copyWith(color: const Color(0xFF818986), fontSize: 7.8)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _TrustItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem(this.icon, this.title, this.subtitle);
}

class MarketplaceAppFooter extends StatelessWidget {
  const MarketplaceAppFooter({super.key});

  BusinessPageModel? _pageBySlug(String slug, List<BusinessPageModel>? pages) {
    if (pages == null) return null;
    for (final page in pages) {
      if (page.slug == slug) return page;
    }
    return null;
  }

  void _openBusinessPage(BuildContext context, SplashController splashController, String slug) {
    final page = _pageBySlug(slug, splashController.defaultBusinessPages);
    if (page != null) {
      RouterHelper.getHtmlViewRoute(action: RouteAction.push, page: page);
    } else {
      // Safe fallback if the business-pages API has not returned this page yet.
      RouterHelper.getDashboardRoute(action: RouteAction.push, page: 'more');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashController>(
      builder: (context, splashController, _) {
        final config = splashController.configModel;
        return Container(
          width: double.infinity,
          color: asinDeepGreen,
          padding: const EdgeInsets.fromLTRB(12, 17, 12, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(config?.companyName ?? 'AsinMart', style: textBold.copyWith(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 5),
              Text(
                'Your multi-vendor online marketplace. Discover fashion, electronics, gadgets, kitchen essentials and more.',
                style: textRegular.copyWith(color: Colors.white70, fontSize: 9.2, height: 1.35),
              ),
              const SizedBox(height: 11),
              if ((config?.companyPhone ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(children: [
                    const Icon(Icons.call_outlined, color: asinGold, size: 15),
                    const SizedBox(width: 6),
                    Text(config!.companyPhone!, style: textMedium.copyWith(color: Colors.white, fontSize: 9.5)),
                  ]),
                ),
              if ((config?.companyEmail ?? '').isNotEmpty)
                Row(children: [
                  const Icon(Icons.email_outlined, color: asinGold, size: 15),
                  const SizedBox(width: 6),
                  Expanded(child: Text(config!.companyEmail!, maxLines: 1, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(color: Colors.white, fontSize: 9.5))),
                ]),
              const SizedBox(height: 13),
              const Divider(color: Color(0xFF27564F), height: 1),
              const SizedBox(height: 11),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ABOUT ASINMART', style: textBold.copyWith(color: asinGold, fontSize: 9)),
                        const SizedBox(height: 5),
                        _FooterLink(title: 'About Us', onTap: () => _openBusinessPage(context, splashController, 'about-us')),
                        _FooterLink(title: 'Contact Us', onTap: () => RouterHelper.getContactUsScreenRoute(action: RouteAction.push)),
                        _FooterLink(title: 'Terms & Conditions', onTap: () => _openBusinessPage(context, splashController, 'terms-and-conditions')),
                        _FooterLink(title: 'Privacy Policy', onTap: () => _openBusinessPage(context, splashController, 'privacy-policy')),
                        _FooterLink(title: 'Return Policy', onTap: () => _openBusinessPage(context, splashController, 'return-policy')),
                        _FooterLink(title: 'Refund Policy', onTap: () => _openBusinessPage(context, splashController, 'refund-policy')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CUSTOMER CARE', style: textBold.copyWith(color: asinGold, fontSize: 9)),
                        const SizedBox(height: 5),
                        _FooterLink(title: 'Shipping Policy', onTap: () => _openBusinessPage(context, splashController, 'shipping-policy')),
                        _FooterLink(title: 'Cancellation Policy', onTap: () => _openBusinessPage(context, splashController, 'cancellation-policy')),
                        _FooterLink(title: 'Categories', onTap: () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'category')),
                        _FooterLink(title: 'Orders', onTap: () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'orders')),
                        _FooterLink(title: 'Cart', onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          title,
          style: textRegular.copyWith(
            color: Colors.white.withValues(alpha: .82),
            fontSize: 8.8,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}

class _HomeSectionShell extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget child;

  const _HomeSectionShell({this.eyebrow, required this.title, this.actionText, this.onAction, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: asinSoftBackground,
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((eyebrow ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(eyebrow!, style: textBold.copyWith(color: asinDeepGreen.withValues(alpha: .67), fontSize: 8, letterSpacing: .6)),
            ),
          Row(
            children: [
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textBold.copyWith(color: const Color(0xFF26302D), fontSize: 15))),
              if (actionText != null && onAction != null)
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                    child: Text(actionText!, style: textMedium.copyWith(color: asinDeepGreen, fontSize: 8.8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
