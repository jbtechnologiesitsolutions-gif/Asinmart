import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/chosen_shipping_method.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/models/shipping_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/models/selected_shipping_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/domain/services/shipping_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class ShippingController extends ChangeNotifier {
  final ShippingServiceInterface shippingServiceInterface;
  ShippingController({required this.shippingServiceInterface});

  List<ChosenShippingMethodModel> _chosenShippingList = [];
  List<ChosenShippingMethodModel> get chosenShippingList =>_chosenShippingList;
  List<ShippingModel>? _shippingList;
  List<ShippingModel>? get shippingList => _shippingList;
  List<bool> isSelectedList = [];
  double amount = 0.0;
  bool isSelectAll = true;
  bool _isLoading = false;
  CartModel? cart;
  String? _updateQuantityErrorText;
  String? get addOrderStatusErrorText => _updateQuantityErrorText;
  bool get isLoading => _isLoading;


  final List<int> _chosenShippingMethodIndex =[];
  List<int> get chosenShippingMethodIndex=>_chosenShippingMethodIndex;





  Future<void> getShippingMethod(BuildContext context, List<List<CartModel>> cartProdList) async {
    _isLoading = true;
    Provider.of<CartController>(context, listen: false).getCartDataLoaded();
    List<int?> sellerIdList = [];
    List<String?> sellerTypeList = [];
    List<String?> groupList = [];
    _shippingList = [];
    for(List<CartModel> element in cartProdList) {
      sellerIdList.add(element[0].sellerId);
      sellerTypeList.add(element[0].sellerIs);
      groupList.add(element[0].cartGroupId);
      _shippingList!.add(ShippingModel(-1, element[0].cartGroupId, []));
    }

    await getChosenShippingMethod(context);
    for(int i=0; i<sellerIdList.length; i++) {
      ApiResponseModel apiResponse = await shippingServiceInterface.getShippingMethod(sellerIdList[i],sellerTypeList[i]);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        List<ShippingMethodModel> shippingMethodList =[];
        apiResponse.response!.data.forEach((shipping) => shippingMethodList.add(ShippingMethodModel.fromJson(shipping)));

        _shippingList![i].shippingMethodList =[];
        _shippingList![i].shippingMethodList!.addAll(shippingMethodList);
        int index = -1;
        int? shipId = -1;
        for(ChosenShippingMethodModel cs in _chosenShippingList) {
          if(cs.cartGroupId == groupList[i]) {
            shipId = cs.shippingMethodId;
            break;
          }
        }
        if(shipId != -1) {
          for(int j=0; j<_shippingList![i].shippingMethodList!.length; j++) {
            if(_shippingList![i].shippingMethodList![j].id == shipId) {
              index = j;
              break;
            }
          }
        }
        _shippingList![i].shippingIndex = index;
      } else {
        if(context.mounted){
        }
        ApiChecker.checkApi( apiResponse);
      }
      _isLoading = false;
      notifyListeners();
    }
  }




  Future<void> getAdminShippingMethodList(BuildContext context) async {
    _isLoading = true;
    Provider.of<CartController>(context, listen: false).getCartDataLoaded();
    _shippingList = [];
    await getChosenShippingMethod(context);
    ApiResponseModel apiResponse = await shippingServiceInterface.getShippingMethod(1,'admin');
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _shippingList!.add(ShippingModel(-1, '', []));
      List<ShippingMethodModel> shippingMethodList =[];
      apiResponse.response!.data.forEach((shipping) => shippingMethodList.add(ShippingMethodModel.fromJson(shipping)));

      _shippingList![0].shippingMethodList =[];
      _shippingList![0].shippingMethodList!.addAll(shippingMethodList);
      int index = -1;


      if(_chosenShippingList.isNotEmpty){
        for(int j=0; j<_shippingList![0].shippingMethodList!.length; j++) {
          if(_shippingList![0].shippingMethodList![j].id == _chosenShippingList[0].shippingMethodId) {
            index = j;
            break;
          }
        }
      }

      _shippingList![0].shippingIndex = index;
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    _isLoading = false;
    notifyListeners();

  }


  Future<void> getChosenShippingMethod(BuildContext context) async {
    ApiResponseModel apiResponse = await shippingServiceInterface.getChosenShippingMethod();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _chosenShippingList = [];
      apiResponse.response!.data.forEach((shipping) => _chosenShippingList.add(ChosenShippingMethodModel.fromJson(shipping)));
      notifyListeners();
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }




  void setSelectedShippingMethod(int? index , int sellerIndex) {
    _shippingList![sellerIndex].shippingIndex = index;
    notifyListeners();
  }


  void initShippingMethodIndexList(int length) {
    _shippingList =[];
    for(int i =0; i< length; i++){
      _shippingList!.add(ShippingModel(0,'', null));
    }

  }





  Future addShippingMethod(BuildContext context, int? id, String? cartGroupId) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await shippingServiceInterface.addShippingMethod(id,cartGroupId);
    if (apiResponse.response != null &&
        (apiResponse.response!.statusCode ?? 0) >= 200 &&
        (apiResponse.response!.statusCode ?? 0) < 300) {
      // In in-house order-wise shipping the UI uses `all_cart_group`, while
      // the digital-payment backend validates every real cart_group_id. Keep
      // the global selection, then explicitly persist the same method against
      // each checked physical cart group so payment cannot fail with
      // `shipping-method: Data not found`.
      if (cartGroupId == 'all_cart_group' && id != null) {
        final CartController cartController = Provider.of<CartController>(Get.context!, listen: false);
        await cartController.getCartData(Get.context!, reload: false);

        final Set<String> physicalGroups = cartController.cartList
            .where((CartModel item) => (item.isChecked ?? false) && item.productType == 'physical' && (item.cartGroupId?.isNotEmpty ?? false))
            .map((CartModel item) => item.cartGroupId!)
            .toSet();

        for (final String groupId in physicalGroups) {
          final ApiResponseModel groupResponse = await shippingServiceInterface.addShippingMethod(id, groupId);
          final int status = groupResponse.response?.statusCode ?? 0;
          if (status < 200 || status >= 300) {
            ApiChecker.checkApi(groupResponse);
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      }

      await Provider.of<CartController>(Get.context!, listen: false).getCartData(Get.context!);
      await getChosenShippingMethod(Get.context!);
      if(context.mounted){
        Navigator.pop(Get.context!);
      }
      showCustomSnackBarWidget(getTranslated('shipping_method_added_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);

    } else {
      if(context.mounted){
        Navigator.pop(Get.context!);
      }
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }



  /// Saves a shipping method without changing the current route. This is used
  /// as a checkout safety net when the backend expects a CartShipping record
  /// for every checked physical cart group.
  Future<bool> saveShippingMethodForGroupSilently(int? id, String? cartGroupId) async {
    if (id == null || cartGroupId == null || cartGroupId.isEmpty) {
      return false;
    }

    ApiResponseModel apiResponse = await shippingServiceInterface.addShippingMethod(id, cartGroupId);
    if (apiResponse.response != null &&
        (apiResponse.response!.statusCode ?? 0) >= 200 &&
        (apiResponse.response!.statusCode ?? 0) < 300) {
      return true;
    }

    ApiChecker.checkApi(apiResponse);
    return false;
  }

  String? _selectedShippingType;
  String? get selectedShippingType=>_selectedShippingType;

  final List<SelectedShippingType> _selectedShippingTypeList = [];
  List<SelectedShippingType> get selectedShippingTypeList => _selectedShippingTypeList;



}
