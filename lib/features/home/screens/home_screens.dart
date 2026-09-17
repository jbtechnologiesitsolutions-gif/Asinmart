import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/fashion_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/footer_banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/single_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/widgets/brand_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/featured_deal_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/announcement_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/marketplace_home_header.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/marketplace_home_sections.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/featured_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_type_popup_menu_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/top_seller_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static Future<void> loadData(bool reload) async {
    final flashDealController = Provider.of<FlashDealController>(Get.context!, listen: false);
    final shopController = Provider.of<ShopController>(Get.context!, listen: false);
    final categoryController = Provider.of<CategoryController>(Get.context!, listen: false);
    final bannerController = Provider.of<BannerController>(Get.context!, listen: false);
    final addressController = Provider.of<AddressController>(Get.context!, listen: false);
    final productController = Provider.of<ProductController>(Get.context!, listen: false);
    final brandController = Provider.of<BrandController>(Get.context!, listen: false);
    final featuredDealController = Provider.of<FeaturedDealController>(Get.context!, listen: false);
    final notificationController = Provider.of<NotificationController>(Get.context!, listen: false);
    final cartController = Provider.of<CartController>(Get.context!, listen: false);
    final profileController = Provider.of<ProfileController>(Get.context!, listen: false);
    final splashController = Provider.of<SplashController>(Get.context!, listen: false);

    if(flashDealController.flashDealList.isEmpty || reload) {
      // await flashDealController.getFlashDealList(reload, false);
    }

    splashController.initConfig(Get.context!, null, null);

    await categoryController.getCategoryList(reload);
    int? fashionCategoryId;
    for (final category in categoryController.categoryList) {
      if ((category.name ?? '').toLowerCase().contains('fashion')) {
        fashionCategoryId = category.id;
        break;
      }
    }
    if (fashionCategoryId != null) {
      productController.getFashionCategoryProductList(id: fashionCategoryId, isUpdate: reload);
    }

    bannerController.getBannerList();

    shopController.getAllSellerList(offset: 1, isUpdate: reload);
    shopController.getTopSellerList(offset: 1, isUpdate: reload);

    addressController.getAddressList();


    cartController.getCartData(Get.context!);

    productController.getHomeCategoryProductList(reload);

    brandController.getBrandList(offset: 1, isUpdate: reload);

    featuredDealController.getFeaturedDealList();

    // productController.getLProductList('1', reload: reload);

    productController.getLatestProductList(1, isUpdate: reload);
    productController.getSelectedProductModel(1, isUpdate: reload);

    productController.getFeaturedProductModel(1, isUpdate: reload);
    productController.getAllProductModelByType(offset: 1, type: ProductType.topProduct, isUpdate: reload);

    productController.getRecommendedProduct();


    productController.getClearanceAllProductList(1, isUpdate: reload);



      if(notificationController.notificationModel == null ||
        (notificationController.notificationModel != null &&
          notificationController.notificationModel!.notification!.isEmpty) || reload) {
        notificationController.getNotificationList(1);
      }

    if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn() && profileController.userInfoModel == null) {
      await profileController.getUserInfo(Get.context!);
    }

  }
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();


  void passData(int index, String title) {
    index = index;
    title = title;
  }

  bool singleVendor = false;
  @override
  void initState() {
    super.initState();

    singleVendor = Provider.of<SplashController>(context, listen: false).configModel?.businessMode == "single";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => HomePage.loadData(true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: MarketplaceHomeHeader()),
              const SliverToBoxAdapter(child: HomeQuickCategoryStrip()),

              SliverToBoxAdapter(
                child: Provider.of<SplashController>(context, listen: false).configModel?.announcement?.status == '1'
                    ? Consumer<SplashController>(
                        builder: (context, announcement, _) {
                          return (announcement.configModel?.announcement?.announcement != null && announcement.onOff)
                              ? AnnouncementWidget(announcement: announcement.configModel!.announcement)
                              : const SizedBox.shrink();
                        },
                      )
                    : const SizedBox.shrink(),
              ),

              const SliverToBoxAdapter(child: FashionBannersWidget()),
              const SliverToBoxAdapter(child: MarketplacePromoRibbon()),
              const SliverToBoxAdapter(child: MarketplaceCoverFlowShowcase()),
              const SliverToBoxAdapter(child: MarketplaceShopByCategory()),
              const SliverToBoxAdapter(child: MarketplaceFashionCollections()),
              // API-driven category sliders. Fashion is sorted to the first
              // position so the Fashion product rail appears directly below
              // Fashion Collections when the API provides that category.
              const SliverToBoxAdapter(child: MarketplaceHomeCategoryCarousels()),

              SliverToBoxAdapter(
                child: MarketplaceProductSection(
                  eyebrow: 'STYLE EDIT',
                  title: 'Trending Fashion',
                  productType: ProductType.featuredProduct,
                  productsBuilder: (controller) {
                    final fashionProducts = controller.fashionCategoryProductModel?.products;
                    return (fashionProducts?.isNotEmpty ?? false)
                        ? fashionProducts
                        : controller.featuredProductModel?.products;
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: MarketplaceProductSection(
                  eyebrow: 'MOST VIEWED',
                  title: 'Top Most Viewed Products',
                  productType: ProductType.topProduct,
                  productsBuilder: (controller) => controller.allProductModel?.products,
                ),
              ),

              const SliverToBoxAdapter(child: MarketplaceMultiVendorCard()),
              const SliverToBoxAdapter(child: MarketplaceVerifiedStores()),
              const SliverToBoxAdapter(child: MarketplaceTrustSection()),
              const SliverToBoxAdapter(child: MarketplaceAppFooter()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}


class SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverSearchDelegate({required this.child, this.height = 70});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverSearchDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}