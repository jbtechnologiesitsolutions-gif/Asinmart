import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/modern_motion_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TemplateHomeSectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onAction;
  final IconData? icon;

  const TemplateHomeSectionTitle({
    super.key,
    required this.title,
    this.action = 'View All',
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AsinDesign.gold, size: 17),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: Text(
              title,
              style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), minimumSize: Size.zero),
              child: Text(action, style: textBold.copyWith(color: AsinDesign.primary, fontSize: 10.5)),
            ),
        ],
      ),
    );
  }
}

class TemplateShopByCategory extends StatelessWidget {
  const TemplateShopByCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, controller, _) {
        final categories = controller.categoryList.take(10).toList();
        if (categories.isEmpty) return const SizedBox.shrink();

        return Container(
          color: AsinDesign.card(context),
          padding: const EdgeInsets.only(top: 14, bottom: 14),
          child: Column(
            children: [
              TemplateHomeSectionTitle(
                title: 'Shop by Category',
                action: 'See All',
                onAction: () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'category'),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final image = category.imageFullUrl?.path?.trim() ?? '';
                    return ModernPressable(
                      onTap: () => RouterHelper.getBrandCategoryRoute(
                        action: RouteAction.push,
                        isBrand: false,
                        id: category.id,
                        name: category.name,
                        categoryModel: category,
                        isAllProduct: true,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 92,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AsinDesign.softCard(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AsinDesign.line(context)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: image.isEmpty
                                    ? Icon(Icons.image_outlined, color: AsinDesign.muted(context), size: 30)
                                    : CustomImageWidget(image: image, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: textMedium.copyWith(color: AsinDesign.foreground(context), fontSize: 9.5, height: 1.1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TemplateProductRail extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Product>? Function(ProductController controller) productsBuilder;
  final ProductType productType;

  const TemplateProductRail({
    super.key,
    required this.title,
    required this.icon,
    required this.productsBuilder,
    required this.productType,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        final products = productsBuilder(controller) ?? <Product>[];
        if (products.isEmpty) return const SizedBox.shrink();
        return Container(
          color: AsinDesign.card(context),
          padding: const EdgeInsets.only(top: 13, bottom: 15),
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              TemplateHomeSectionTitle(
                title: title,
                icon: icon,
                onAction: () => RouterHelper.getViewAllProductScreenRoute(productType: productType, action: RouteAction.push),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 316,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => SizedBox(
                    width: 146,
                    child: ModernFadeSlide(
                      delay: Duration(milliseconds: (index.clamp(0, 8) * 26).toInt()),
                      child: ProductWidget(productModel: products[index], margin: 0),
                    ),
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


class TemplateRecommendedSpotlight extends StatelessWidget {
  const TemplateRecommendedSpotlight({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        final product = controller.recommendedProduct;
        if (product == null || product.id == null || product.id == -1) {
          return const SizedBox.shrink();
        }

        return Container(
          color: AsinDesign.card(context),
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.only(top: 13, bottom: 15),
          child: Column(
            children: [
              const TemplateHomeSectionTitle(
                title: 'Recommended Product',
                icon: Icons.recommend_rounded,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 146,
                    child: ProductWidget(productModel: product, margin: 0),
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

class TemplateTopBrands extends StatelessWidget {
  const TemplateTopBrands({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BrandController>(
      builder: (context, controller, _) {
        final brands = controller.brandList.take(10).toList();
        if (brands.isEmpty) return const SizedBox.shrink();
        return Container(
          color: AsinDesign.card(context),
          padding: const EdgeInsets.only(top: 13, bottom: 15),
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              TemplateHomeSectionTitle(
                title: 'Top Brands',
                action: 'See All',
                onAction: () => RouterHelper.getBrandViewRoute(action: RouteAction.push),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 66,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return InkWell(
                      onTap: () => RouterHelper.getBrandCategoryRoute(
                        action: RouteAction.push,
                        isBrand: true,
                        id: brand.id,
                        name: brand.name,
                        image: brand.imageFullUrl?.path,
                      ),
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AsinDesign.softCard(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: AsinDesign.line(context)),
                        ),
                        child: CustomImageWidget(image: '${brand.imageFullUrl?.path ?? ''}', fit: BoxFit.contain),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TemplateVendorPortal extends StatelessWidget {
  const TemplateVendorPortal({super.key});

  Future<void> _open(String path) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AsinDesign.primaryDeep,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: AsinDesign.gold, borderRadius: BorderRadius.circular(4)),
            child: Text('VENDOR PORTAL', style: textBold.copyWith(color: const Color(0xFF17231F), fontSize: 8.5, letterSpacing: .2)),
          ),
          const SizedBox(height: 6),
          Text('Multi-Vendor Marketplace', style: textBold.copyWith(color: Colors.white, fontSize: 17)),
          const SizedBox(height: 3),
          Text("Manage your store or start selling with India's fast-growing seller hub.",
              style: textRegular.copyWith(color: Colors.white70, fontSize: 9.5, height: 1.35)),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _VendorPortalButton(
                  icon: Icons.storefront_outlined,
                  title: 'Vendor Login',
                  subtitle: 'Manage products & orders',
                  background: Colors.white.withValues(alpha: .10),
                  foreground: Colors.white,
                  onTap: () => _open('/vendor/auth/login'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VendorPortalButton(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Register Store',
                  subtitle: 'Start selling online',
                  background: AsinDesign.gold,
                  foreground: const Color(0xFF17231F),
                  onTap: () => _open('/vendor/auth/registration/index'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorPortalButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _VendorPortalButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: background == AsinDesign.gold ? AsinDesign.gold : Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: 19),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(color: foreground, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(color: foreground.withValues(alpha: .72), fontSize: 7.5)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: foreground, size: 14),
          ],
        ),
      ),
    );
  }
}

class TemplateFeaturedStores extends StatelessWidget {
  const TemplateFeaturedStores({super.key});

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'AM';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
      builder: (context, controller, _) {
        final sellers = (controller.topSellerModel?.sellers ?? controller.allSellerModel?.sellers ?? []).take(10).toList();
        if (sellers.isEmpty) return const SizedBox.shrink();

        return Container(
          color: AsinDesign.card(context),
          padding: const EdgeInsets.only(top: 13, bottom: 15),
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              TemplateHomeSectionTitle(
                title: 'Top Verified Stores',
                action: 'View All',
                onAction: () => RouterHelper.getAllTopSellerRoute(action: RouteAction.push, title: 'Stores'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  itemCount: sellers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final seller = sellers[index];
                    final shop = seller.shop;
                    final shopName = shop?.name?.trim().isNotEmpty == true ? shop!.name!.trim() : 'AsinMart Store';
                    final image = shop?.imageFullUrl?.path?.trim() ?? '';

                    return InkWell(
                      onTap: () => RouterHelper.getTopSellerRoute(
                        action: RouteAction.push,
                        sellerId: seller.id,
                        slug: shop?.slug,
                        name: shop?.name,
                        image: shop?.imageFullUrl?.path,
                        banner: shop?.bannerFullUrl?.path,
                        totalProduct: seller.productCount,
                        totalReview: seller.ratingCount,
                        rating: '${seller.averageRating ?? 0}',
                        temporaryClose: shop?.temporaryClose,
                        vacationStatus: shop?.vacationStatus,
                        vacationStartDate: shop?.vacationStartDate,
                        vacationEndDate: shop?.vacationEndDate,
                        vacationDurationType: shop?.vacationDurationType,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 126,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
                        decoration: AsinDesign.cardDecoration(context, radius: 10),
                        child: Column(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AsinDesign.primarySoft,
                                shape: BoxShape.circle,
                                border: Border.all(color: AsinDesign.line(context)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.center,
                              child: image.isEmpty
                                  ? Text(_initials(shopName), style: textBold.copyWith(color: AsinDesign.primary, fontSize: 11))
                                  : CustomImageWidget(image: image, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 6),
                            Text(shopName.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 8.5)),
                            const SizedBox(height: 2),
                            Text('${seller.productCount ?? 0} Products', maxLines: 1, overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 7.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TemplateWhyShopWithUs extends StatelessWidget {
  const TemplateWhyShopWithUs({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.local_shipping_outlined, 'Fast Shipping', 'Quick and dependable delivery across the country'),
      (Icons.verified_user_outlined, '100% Authentic', 'Curated and verified genuine marketplace products'),
      (Icons.lock_outline_rounded, 'Secure Payment', 'Protected checkout transactions'),
      (Icons.support_agent_rounded, '24/7 Support', 'Helpful customer assistance whenever you need it'),
    ];

    return Container(
      color: AsinDesign.card(context),
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 18),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Text('WHY SHOP WITH US', style: textBold.copyWith(color: AsinDesign.gold, fontSize: 8, letterSpacing: .55)),
          const SizedBox(height: 5),
          Text('Why Customers Trust AsinMart', textAlign: TextAlign.center,
              style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 15.5)),
          const SizedBox(height: 3),
          Text('Shop with confidence through reliable delivery, protected payments and verified sellers.',
              textAlign: TextAlign.center,
              style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 8.5, height: 1.3)),
          const SizedBox(height: 11),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 7,
              crossAxisSpacing: 7,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AsinDesign.softCard(context),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AsinDesign.line(context)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AsinDesign.primarySoft, shape: BoxShape.circle),
                      child: Icon(item.$1, color: AsinDesign.primary, size: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(item.$2, textAlign: TextAlign.center,
                        style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 9.5)),
                    const SizedBox(height: 2),
                    Text(item.$3, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                        style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 7.2, height: 1.15)),
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

