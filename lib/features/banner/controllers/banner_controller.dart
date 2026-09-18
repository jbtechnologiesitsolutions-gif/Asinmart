import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/domain/models/banner_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/domain/services/banner_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/data_sync_helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class BannerController extends ChangeNotifier {
  final BannerServiceInterface? bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<BannerModel>? _mainBannerList;
  List<BannerModel>? _footerBannerList;
  List<BannerModel> _allBannerList = <BannerModel>[];
  BannerModel? mainSectionBanner;
  BannerModel? sideBarBanner;
  Product? _product;
  int? _currentIndex;
  int? _footerBannerIndex;
  List<BannerModel>? get mainBannerList => _mainBannerList;
  List<BannerModel>? get footerBannerList => _footerBannerList;
  List<BannerModel> get allBannerList => _allBannerList;

  Product? get product => _product;
  int? get currentIndex => _currentIndex;
  int? get footerBannerIndex => _footerBannerIndex;

  BannerModel? promoBannerMiddleTop;
  BannerModel? promoBannerRight;
  BannerModel? promoBannerMiddleBottom;
  BannerModel? promoBannerLeft;
  BannerModel? promoBannerBottom;
  BannerModel? sideBarBannerBottom;
  BannerModel? topSideBarBannerBottom;

  Future<void> getBannerList() async {

    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: ()=> bannerServiceInterface!.getList(source: DataSourceEnum.local),
      fetchFromClient: ()=> bannerServiceInterface!.getList(source: DataSourceEnum.client),
      onResponse: (data, _){
        _mainBannerList = [];
        _footerBannerList = [];
        _allBannerList = <BannerModel>[];

        data.forEach((bannerModel) {
          final parsedBanner = BannerModel.fromJson(bannerModel);
          _allBannerList.add(parsedBanner);
          if(bannerModel['banner_type'] == 'Main Banner'){
            _mainBannerList!.add(parsedBanner);
          }
          else if(bannerModel['banner_type'] == 'Promo Banner Middle Top'){
            promoBannerMiddleTop = parsedBanner;
          }
          else if(bannerModel['banner_type'] == 'Promo Banner Right'){
            promoBannerRight = parsedBanner;
          }else if(bannerModel['banner_type'] == 'Promo Banner Middle Bottom'){
            promoBannerMiddleBottom = parsedBanner;
          }
          else if(bannerModel['banner_type'] == 'Promo Banner Bottom'){
            promoBannerBottom = parsedBanner;
          }
          else if(bannerModel['banner_type'] == 'Promo Banner Left'){
            promoBannerLeft = parsedBanner;
          }else if(bannerModel['banner_type'] == 'Sidebar Banner'){
            sideBarBanner = parsedBanner;
          }else if(bannerModel['banner_type'] == 'Top Side Banner'){
            topSideBarBannerBottom = parsedBanner;
          }else if(bannerModel['banner_type'] == 'Footer Banner'){
            _footerBannerList?.add(parsedBanner);
          }else if(bannerModel['banner_type'] == 'Main Section Banner'){
            mainSectionBanner = parsedBanner;
          }
        });

        _currentIndex = 0;

        notifyListeners();
      },
    );
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void onChangeFooterBannerIndex(int index) {
    _footerBannerIndex = index;
    notifyListeners();
  }


  void clickBannerRedirect(BuildContext context, int? id, Product? product, String? type, {String? url}) {
    if(type == 'custom' && url != null && url.isNotEmpty) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    if(type == 'category') {
      final categories = Provider.of<CategoryController>(context, listen: false).categoryList;
      final cIndex = categories.indexWhere((element) => element.id == id);
      if(cIndex < 0 || cIndex >= categories.length) return;
      final category = categories[cIndex];
      if((category.name ?? '').isNotEmpty) {
        RouterHelper.getBrandCategoryRoute(
          action: RouteAction.push,
          isBrand: false,
          id: id ?? category.id ?? 1,
          name: category.name ?? '',
        );
      }
      return;
    }

    if(type == 'product') {
      if(product != null && product.status == 1 && product.id != null && (product.slug ?? '').isNotEmpty) {
        RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: product.id!, slug: product.slug!);
      }
      return;
    }

    if(type == 'brand') {
      final brands = Provider.of<BrandController>(context, listen: false).brandList;
      final bIndex = brands.indexWhere((element) => element.id == id);
      if(bIndex < 0 || bIndex >= brands.length) return;
      final brand = brands[bIndex];
      if((brand.name ?? '').isNotEmpty && id != null) {
        RouterHelper.getBrandCategoryRoute(action: RouteAction.push, isBrand: true, id: id, name: brand.name ?? '');
      }
      return;
    }

    if(type == 'shop') {
      final sellers = Provider.of<ShopController>(context, listen: false).allSellerModel?.sellers ?? [];
      final tIndex = sellers.indexWhere((element) => element.id == id);
      if(tIndex < 0 || tIndex >= sellers.length) return;
      final shop = sellers[tIndex].shop;
      if(shop == null || (shop.slug ?? '').isEmpty) return;
      RouterHelper.getTopSellerRoute(
        action: RouteAction.push,
        slug: shop.slug ?? '',
        sellerId: id,
        temporaryClose: shop.temporaryClose,
        vacationStatus: shop.vacationStatus,
        vacationEndDate: shop.vacationEndDate,
        vacationStartDate: shop.vacationStartDate,
        vacationDurationType: shop.vacationDurationType,
        name: shop.name,
        banner: shop.bannerFullUrl?.path,
        image: shop.imageFullUrl?.path,
      );
    }
  }

}
