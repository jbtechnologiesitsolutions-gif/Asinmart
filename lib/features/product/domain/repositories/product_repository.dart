import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart' show Options, ResponseType;

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/services/data_sync_service.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/repositories/product_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class ProductRepository extends DataSyncService implements ProductRepositoryInterface{
  final DioClient dioClient;
  ProductRepository({required this.dioClient, required super.dataSyncRepoInterface});

  @override
  Future<ApiResponseModel> getFilteredProductList(BuildContext context, String offset, ProductType productType) async {
    late String endUrl;

     if(productType == ProductType.bestSelling) {
      endUrl = AppConstants.bestSellingProductUri;
    }
    else if(productType == ProductType.newArrival){
      endUrl = AppConstants.newArrivalProductUri;
    }
    else if(productType == ProductType.topProduct){
      endUrl = AppConstants.topProductUri;
    }else if(productType == ProductType.discountedProduct){
       endUrl = AppConstants.discountedProductUri;
     }
    try {
      final response = await dioClient.get(endUrl+offset);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponseModel<T>> getProductModelByType<T>({
    required int offset,
    required ProductType productType,
    required DataSourceEnum source,
  }) async {

    final String endUrl = _getApiEndUrlByType(productType);

    return await fetchData<T>(endUrl + offset.toString(), source);
  }

  String _getApiEndUrlByType(ProductType type) {
    switch (type) {
      case ProductType.newArrival:
        return AppConstants.newArrivalProductUri;

      case ProductType.latestProduct:
        return AppConstants.latestProductUri;

      case ProductType.featuredProduct:
        return AppConstants.featuredProductUri;

      case ProductType.topProduct:
        return AppConstants.topProductUri;

      case ProductType.bestSelling:
        return AppConstants.bestSellingProductUri;

      case ProductType.discountedProduct:
        return AppConstants.discountedProductUri;

      case ProductType.justForYou:
        return '${AppConstants.justForYou}&limit=10&offset=';

      default:
        return AppConstants.newArrivalProductUri;

    }

  }


  @override
  Future<ApiResponseModel> getBrandOrCategoryProductList({required bool isBrand, required int id, String searchProduct = '', required int offset}) async {
    try {
      String uri;
      if(isBrand){
        uri = '${AppConstants.brandProductUri}$id?guest_id=1&limit=10&offset=$offset&search=$searchProduct';
      }else {
        uri = '${AppConstants.categoryProductUri}$id?guest_id=1&search=$searchProduct&limit=10&offset=$offset';
      }
      final response = await dioClient.get(uri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponseModel> getRelatedProductList(String id) async {
    try {
      final response = await dioClient.get('${AppConstants.relatedProductUri}$id?guest_id=1');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }





  @override
  Future<ApiResponseModel> getLatestProductList(String offset) async {
    try {
      final response = await dioClient.get(
        AppConstants.latestProductUri+offset,);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel<T>> getRecommendedProduct<T>({required DataSourceEnum source}) async {

   return await fetchData<T>(AppConstants.dealOfTheDay, source);

  }

  @override
  Future<ApiResponseModel<T>> getMostDemandedProduct<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.mostDemandedProduct, source);
  }

  @override
  Future<ApiResponseModel<T>> getFindWhatYouNeed<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.findWhatYouNeed, source);
  }


  @override
  Future<ApiResponseModel> getJustForYouProductList({required int offset, int? limit}) async {
    try {
      final response = await dioClient.get('${AppConstants.justForYou}&limit${limit ?? 10}&offset=$offset');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel<T>> getMostSearchingProductList<T>({required int offset, required DataSourceEnum source}) async {

    return await fetchData<T>('${AppConstants.mostSearching}?guest_id=1&limit=10&offset=$offset', source);

  }

  @override
  Future<ApiResponseModel<T>> getHomeCategoryProductList<T>({required DataSourceEnum source}) async {

    return fetchData(AppConstants.homeCategoryProductUri, source);
  }


  /// Mirrors the exact product order rendered by the website Cover Flow.
  ///
  /// The web Blade already applies AdvertisementService sponsored-product
  /// priority and its in-house fallbacks. Reading the rendered card links here
  /// means the app stays in sync with the website without duplicating or
  /// guessing that business rule on the client.
  @override
  Future<List<Product>> getWebsiteCoverFlowProducts() async {
    try {
      final pageResponse = await dioClient.get(
        '/',
        options: Options(
          responseType: ResponseType.plain,
          headers: const {'Accept': 'text/html'},
        ),
      );

      final html = pageResponse.data?.toString() ?? '';
      if (html.isEmpty) return <Product>[];

      final sectionMatch = RegExp(
        r'''<section\b[^>]*\bid=['"]asinCoverflowV7['"][^>]*>[\s\S]*?</section>''',
        caseSensitive: false,
      ).firstMatch(html);
      final section = sectionMatch?.group(0) ?? '';
      if (section.isEmpty) return <Product>[];

      final cardLinkPattern = RegExp(
        r'''<article\b[^>]*\bdata-cf-card\b[^>]*>[\s\S]*?<a\b[^>]*\bhref=['"]([^'"]+)['"]''',
        caseSensitive: false,
      );

      final lookups = <String>[];
      for (final match in cardLinkPattern.allMatches(section)) {
        final rawHref = (match.group(1) ?? '').replaceAll('&amp;', '&').trim();
        if (rawHref.isEmpty) continue;

        final uri = Uri.tryParse(rawHref);
        final path = uri?.path ?? rawHref;
        String? lookup;

        final productMatch = RegExp(r'/product/([^/?#]+)', caseSensitive: false).firstMatch(path);
        if (productMatch != null) {
          lookup = Uri.decodeComponent(productMatch.group(1)!);
        } else if (RegExp(r'advert|sponsor', caseSensitive: false).hasMatch(path)) {
          // advertisement.click receives the Product ID in the website Blade.
          final idMatch = RegExp(r'(\d+)(?!.*\d)').firstMatch('$path?${uri?.query ?? ''}');
          lookup = idMatch?.group(1);
        }

        if (lookup != null && lookup.trim().isNotEmpty && !lookups.contains(lookup)) {
          lookups.add(lookup.trim());
        }
        if (lookups.length >= 10) break;
      }

      if (lookups.isEmpty) return <Product>[];

      final productRequests = lookups.map((lookup) async {
        try {
          final response = await dioClient.get(
            '${AppConstants.productDetailsUri}${Uri.encodeComponent(lookup)}?guest_id=1',
          );
          if (response.statusCode == 200 && response.data is Map) {
            return Product.fromJson(Map<String, dynamic>.from(response.data as Map));
          }
        } catch (_) {
          // One stale website card must not hide the other valid Cover Flow cards.
        }
        return null;
      }).toList();

      final products = await Future.wait(productRequests);
      return products
          .whereType<Product>()
          .where((product) => product.id != null && (product.slug ?? '').trim().isNotEmpty)
          .toList();
    } catch (_) {
      // Home remains usable; the widget has its existing API fallback.
      return <Product>[];
    }
  }

  @override
  Future<ApiResponseModel<T>> getClearanceAllProductList<T>({required int offset, required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.clearanceAllProductUri}?guest_id=1&limit=10&offset=$offset', source);

  }



  @override
  Future<ApiResponseModel> getClearanceSearchProducts(String query, String? categoryIds, String? brandIds, String? authorIds, String? publishingIds, String? sort, String? priceMin, String? priceMax, int offset, String? productType, String? offerType) async {

    try {
      log("===limit==>" );
      final response = await dioClient.post(AppConstants.searchUri,
          data: {'search' : base64.encode(utf8.encode(query)),
            'category': categoryIds != null ? categoryIds.toString() : '[]',
            'brand' : brandIds??'[]',
            'product_authors' : authorIds ?? '[]',
            'publishing_houses' : publishingIds ?? '[]',
            'sort_by': sort,
            'price_min' : priceMin,
            'price_max' : priceMax,
            'limit' : '20',
            'offset' : offset,
            'guest_id' : '1',
            'product_type' : productType ?? 'all',
            'offer_type' : offerType,
          });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }



  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }



  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }


  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }



}