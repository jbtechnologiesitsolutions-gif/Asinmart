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
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

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
              const SizedBox(height: 8),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ModernPressable(
                      onTap: () => RouterHelper.getBrandCategoryRoute(
                        action: RouteAction.push,
                        isBrand: false,
                        id: category.id,
                        name: category.name,
                        categoryModel: category,
                        isAllProduct: true,
                      ),
                      borderRadius: BorderRadius.circular(99),
                      child: SizedBox(
                        width: 66,
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AsinDesign.softCard(context),
                                shape: BoxShape.circle,
                                border: Border.all(color: AsinDesign.line(context)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CustomImageWidget(image: '${category.imageFullUrl?.path ?? ''}', fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: textMedium.copyWith(color: AsinDesign.foreground(context), fontSize: 9.5),
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
                height: 342,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => SizedBox(
                    width: 168,
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
                    width: 176,
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

class TemplateFeaturedStores extends StatelessWidget {
  const TemplateFeaturedStores({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
      builder: (context, controller, _) {
        final sellers = (controller.allSellerModel?.sellers ?? controller.topSellerModel?.sellers ?? []).take(8).toList();
        if (sellers.isEmpty) return const SizedBox.shrink();
        return Container(
          color: AsinDesign.card(context),
          padding: const EdgeInsets.only(top: 13, bottom: 15),
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              TemplateHomeSectionTitle(
                title: 'Featured Stores',
                action: 'Explore',
                onAction: () => RouterHelper.getAllTopSellerRoute(action: RouteAction.push, title: 'Stores'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AsinDesign.pagePaddingMobile),
                  scrollDirection: Axis.horizontal,
                  itemCount: sellers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final seller = sellers[index];
                    final shop = seller.shop;
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
                      borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
                      child: Container(
                        width: 190,
                        decoration: AsinDesign.cardDecoration(context, radius: AsinDesign.radiusLg),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: CustomImageWidget(
                                  image: '${shop?.bannerFullUrl?.path ?? shop?.imageFullUrl?.path ?? ''}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shop?.name ?? 'Store', maxLines: 1, overflow: TextOverflow.ellipsis, style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 11.5)),
                                  const SizedBox(height: 3),
                                  Row(children: [
                                    const Icon(Icons.star_rounded, size: 13, color: AsinDesign.star),
                                    const SizedBox(width: 2),
                                    Text('${seller.averageRating ?? 0}', style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
                                    const SizedBox(width: 4),
                                    Text('• Verified', style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
                                  ]),
                                ],
                              ),
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

class TemplateWhyShopWithUs extends StatelessWidget {
  const TemplateWhyShopWithUs({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      (Icons.local_shipping_outlined, 'Fast shipping on eligible orders'),
      (Icons.assignment_return_outlined, 'Easy returns & support'),
      (Icons.lock_outline_rounded, '100% secure payments'),
      (Icons.verified_user_outlined, 'Verified marketplace sellers'),
    ];
    return Container(
      color: AsinDesign.card(context),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why Shop With Us', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 15.5)),
          const SizedBox(height: 10),
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: AsinDesign.cardDecoration(context, radius: 10),
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: AsinDesign.primarySoft, shape: BoxShape.circle),
                    child: Icon(item.$1, size: 15, color: AsinDesign.primary),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(item.$2, style: textMedium.copyWith(color: AsinDesign.foreground(context), fontSize: 10.5))),
                ]),
              )),
        ],
      ),
    );
  }
}
