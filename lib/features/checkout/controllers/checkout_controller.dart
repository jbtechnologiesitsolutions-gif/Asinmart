import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';



class CheckoutController with ChangeNotifier {
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  int? _addressIndex;
  int? _billingAddressIndex;
  int? get billingAddressIndex => _billingAddressIndex;
  int? _shippingIndex;
  bool _isLoading = false;
  bool _isCheckCreateAccount = false;
  bool _newUser = false;

  int _paymentMethodIndex = -1;
  bool _onlyDigital = true;
  bool get onlyDigital => _onlyDigital;
  int? get addressIndex => _addressIndex;
  int? get shippingIndex => _shippingIndex;
  bool get isLoading => _isLoading;
  int get paymentMethodIndex => _paymentMethodIndex;
  bool get isCheckCreateAccount => _isCheckCreateAccount;

  bool _changeAmountShow = false;
  bool get changeAmountShow => _changeAmountShow;

  double? _cashChangesAmount;
  double? get cashChangesAmount => _cashChangesAmount;

  ReferralAmount? _referralAmount;
  ReferralAmount? get referralAmount => _referralAmount;

  String selectedPaymentName = '';
  void setSelectedPayment(String payment){
    selectedPaymentName = payment;
    notifyListeners();
  }

  bool _isAcceptTerms = false;
  bool get isAcceptTerms => _isAcceptTerms;


  final TextEditingController orderNoteController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  List<String> inputValueList = [];



  Future<void> placeOrder({required Function callback, String? addressID,
        String? couponCode, String? couponAmount,
        String? billingAddressId, String? orderNote, String? transactionId,
        String? paymentNote, int? id, String? name,bool isfOffline = false, bool wallet = false}) async {
    for(TextEditingController textEditingController in inputFieldControllerList) {
      inputValueList.add(textEditingController.text.trim());

    }

    _isLoading = true;
    _newUser = false;
    notifyListeners();
    ApiResponseModel apiResponse;
    isfOffline?
    apiResponse = await checkoutServiceInterface.offlinePaymentPlaceOrder(addressID, couponCode, couponAmount, billingAddressId, orderNote, keyList, inputValueList, offlineMethodSelectedId, offlineMethodSelectedName, paymentNote, _isCheckCreateAccount, passwordController.text.trim()):
    wallet?
    apiResponse = await checkoutServiceInterface.walletPaymentPlaceOrder(addressID, couponCode, couponAmount, billingAddressId, orderNote, _isCheckCreateAccount, passwordController.text.trim()):

    apiResponse = await checkoutServiceInterface.cashOnDeliveryPlaceOrder(
      addressID: addressID,
      couponCode: couponCode,
      couponDiscountAmount: couponAmount,
      billingAddressId: billingAddressId,
      orderNote: orderNote,
      isCheckCreateAccount: _isCheckCreateAccount,
      password: passwordController.text.trim(),
      cashChangeAmount: _cashChangesAmount,
      currentCurrencyCode: Provider.of<SplashController>(Get.context!, listen: false).myCurrency?.code,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isCheckCreateAccount = false;
      _isLoading = false;
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      if(!Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()){
        _newUser = apiResponse.response!.data['new_user'];
      }

      String message = apiResponse.response!.data.toString();
      callback(true, message, extractId(apiResponse.response!.data['order_ids'].toString()), _newUser);
    } else {
      _isLoading = false;
     ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  String? extractId(String idsString) {

    String cleaned = idsString.replaceAll(RegExp(r'[\[\]\s]'), '');
    return cleaned.isNotEmpty ? cleaned : null;
  }

  String? getFirstOrderId(String idsString) {
    if (idsString.trim().isEmpty) return null;

    List<String> ids = idsString.split(',').map((e) => e.trim()).toList();

    return ids.isNotEmpty ? ids.first : null;
  }



  void setAddressIndex(int index) {
    _addressIndex = index;
    notifyListeners();
  }
  void setBillingAddressIndex(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }


  void resetPaymentMethod(){
    _paymentMethodIndex = -1;
    isCODChecked = false;
    isWalletChecked = false;
    isOfflineChecked = false;
  }


  void shippingAddressNull(){
    _addressIndex = null;
    notifyListeners();
  }

  void billingAddressNull(){
    _billingAddressIndex = null;
    notifyListeners();
  }

  void setSelectedShippingAddress(int index) {
    _shippingIndex = index;
    notifyListeners();
  }
  void setSelectedBillingAddress(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }


  bool isOfflineChecked = false;
  bool isCODChecked = false;
  bool isWalletChecked = false;

  void setOfflineChecked(String type, {bool notify = true}) {
    if(type == 'offline'){
      isOfflineChecked = !isOfflineChecked;
      isCODChecked = false;
      isWalletChecked = false;
      _paymentMethodIndex = -1;
      setOfflinePaymentMethodSelectedIndex(0);
    }else if(type == 'cod'){
      isCODChecked = !isCODChecked;
      isOfflineChecked = false;
      isWalletChecked = false;
      _paymentMethodIndex = -1;
    }else if(type == 'wallet'){
      isWalletChecked = !isWalletChecked;
      isOfflineChecked = false;
      isCODChecked = false;
      _paymentMethodIndex = -1;
    }

    if(notify) {
      notifyListeners();
    }
  }



  String selectedDigitalPaymentMethodName = '';

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    selectedDigitalPaymentMethodName = name;
    isCODChecked = false;
    isWalletChecked = false;
    isOfflineChecked = false;
    notifyListeners();
  }


  void digitalOnly(bool value, {bool isUpdate = false}){
    _onlyDigital = value;
    if(isUpdate){
      notifyListeners();
    }

  }



  OfflinePaymentModel? offlinePaymentModel;
  Future<ApiResponseModel> getOfflinePaymentList() async {
    ApiResponseModel apiResponse = await checkoutServiceInterface.offlinePaymentList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      offlineMethodSelectedIndex = 0;
      offlinePaymentModel = OfflinePaymentModel.fromJson(apiResponse.response?.data);
    }
    else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  List<TextEditingController> inputFieldControllerList = [];
  List <String?> keyList = [];
  int offlineMethodSelectedIndex = -1;
  int offlineMethodSelectedId = 0;
  String offlineMethodSelectedName = '';

  void setOfflinePaymentMethodSelectedIndex(int index, {bool notify = true}){
    keyList = [];
    inputFieldControllerList = [];
    offlineMethodSelectedIndex = index;
    if(offlinePaymentModel != null && offlinePaymentModel!.offlineMethods!= null && offlinePaymentModel!.offlineMethods!.isNotEmpty){
      offlineMethodSelectedId = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].id!;
      offlineMethodSelectedName = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].methodName!;
    }

    if(offlinePaymentModel!.offlineMethods != null && offlinePaymentModel!.offlineMethods!.isNotEmpty && offlinePaymentModel!.offlineMethods![index].methodInformations!.isNotEmpty){
      for(int i= 0; i< offlinePaymentModel!.offlineMethods![index].methodInformations!.length; i++){
        inputFieldControllerList.add(TextEditingController());
        keyList.add(offlinePaymentModel!.offlineMethods![index].methodInformations![i].customerInput);
      }
    }
    if(notify){
      notifyListeners();
    }
  }

  /// The Laravel payment endpoint rejects physical carts with
  /// `shipping-method / Data not found` when one of the checked cart groups
  /// does not have a CartShipping row. The cart UI normally creates those
  /// rows, but a stale cart, Buy Now flow, or a changed shipping configuration
  /// can leave them missing. Repair a previously-selected/default method before
  /// opening the payment gateway instead of sending a request that will 403.
  Future<bool> _ensureOrderWiseShippingReady() async {
    final BuildContext context = Get.context!;
    final SplashController splashController = Provider.of<SplashController>(context, listen: false);
    final CartController cartController = Provider.of<CartController>(context, listen: false);
    final ShippingController shippingController = Provider.of<ShippingController>(context, listen: false);
    final config = splashController.configModel;

    if (config == null) return true;

    await cartController.getCartData(context, reload: false);
    final List<CartModel> physicalChecked = cartController.cartList
        .where((CartModel item) => (item.isChecked ?? false) && item.productType == 'physical')
        .toList();

    if (physicalChecked.isEmpty) return true;

    final Set<String> requiredGroups = <String>{};
    if (config.shippingMethod == 'sellerwise_shipping') {
      for (final CartModel item in physicalChecked) {
        if (item.shippingType == 'order_wise' && (item.cartGroupId?.isNotEmpty ?? false)) {
          requiredGroups.add(item.cartGroupId!);
        }
      }
    } else if (config.inhouseSelectedShippingType == 'order_wise') {
      for (final CartModel item in physicalChecked) {
        if (item.cartGroupId?.isNotEmpty ?? false) {
          requiredGroups.add(item.cartGroupId!);
        }
      }
    }

    if (requiredGroups.isEmpty) return true;

    await shippingController.getChosenShippingMethod(context);

    bool groupExists(String groupId) => shippingController.chosenShippingList.any(
      (chosen) => chosen.cartGroupId == groupId && chosen.isCheckItemExist == 1,
    );

    Set<String> missingGroups = requiredGroups.where((String groupId) => !groupExists(groupId)).toSet();
    if (missingGroups.isEmpty) return true;

    // The cart response itself can still remember a chosen shipping_method_id
    // even when the CartShipping row was lost. Re-persist that exact selection
    // first; this fixes stale carts without silently changing the user's choice.
    for (final String groupId in missingGroups.toList()) {
      int? rememberedMethodId;
      for (final CartModel item in physicalChecked) {
        if (item.cartGroupId == groupId && (item.shippingMethodId ?? 0) > 0) {
          rememberedMethodId = item.shippingMethodId;
          break;
        }
      }
      if (rememberedMethodId != null) {
        await shippingController.saveShippingMethodForGroupSilently(rememberedMethodId, groupId);
      }
    }

    await shippingController.getChosenShippingMethod(context);
    missingGroups = requiredGroups.where((String groupId) => !groupExists(groupId)).toSet();
    if (missingGroups.isEmpty) return true;

    if (config.shippingMethod != 'sellerwise_shipping') {
      await shippingController.getAdminShippingMethodList(context);
      final shippingList = shippingController.shippingList;
      if (shippingList == null || shippingList.isEmpty || shippingList.first.shippingMethodList == null) {
        return false;
      }

      final methods = shippingList.first.shippingMethodList!;
      if (methods.isEmpty) return false;

      int selectedIndex = shippingList.first.shippingIndex ?? -1;
      if (selectedIndex < 0 || selectedIndex >= methods.length) {
        // Auto-select only when there is no ambiguity. If several methods are
        // configured, the customer must explicitly choose one in the cart.
        if (methods.length != 1) return false;
        selectedIndex = 0;
        shippingController.setSelectedShippingMethod(0, 0);
      }

      final int? methodId = methods[selectedIndex].id;
      if (methodId == null) return false;

      for (final String groupId in missingGroups) {
        final bool saved = await shippingController.saveShippingMethodForGroupSilently(methodId, groupId);
        if (!saved) return false;
      }
    } else {
      // Rebuild the seller-wise shipping list from the checked cart groups so
      // we can restore a selected method when the CartShipping row was lost.
      final Map<String, List<CartModel>> grouped = <String, List<CartModel>>{};
      for (final CartModel item in physicalChecked) {
        final String? groupId = item.cartGroupId;
        if (groupId != null && groupId.isNotEmpty) {
          grouped.putIfAbsent(groupId, () => <CartModel>[]).add(item);
        }
      }

      if (grouped.isNotEmpty) {
        await shippingController.getShippingMethod(context, grouped.values.toList());
      }

      for (final String groupId in missingGroups) {
        final shippingModels = shippingController.shippingList;
        if (shippingModels == null) return false;

        dynamic shippingModel;
        for (final model in shippingModels) {
          if (model.groupId == groupId) {
            shippingModel = model;
            break;
          }
        }

        if (shippingModel == null || shippingModel.shippingMethodList == null || shippingModel.shippingMethodList.isEmpty) {
          return false;
        }

        int selectedIndex = shippingModel.shippingIndex ?? -1;
        if (selectedIndex < 0 || selectedIndex >= shippingModel.shippingMethodList.length) {
          if (shippingModel.shippingMethodList.length != 1) return false;
          selectedIndex = 0;
        }

        final int? methodId = shippingModel.shippingMethodList[selectedIndex].id;
        if (methodId == null) return false;

        final bool saved = await shippingController.saveShippingMethodForGroupSilently(methodId, groupId);
        if (!saved) return false;
      }
    }

    await shippingController.getChosenShippingMethod(context);
    missingGroups = requiredGroups.where((String groupId) => !groupExists(groupId)).toSet();
    return missingGroups.isEmpty;
  }

  Future<ApiResponseModel> digitalPaymentPlaceOrder({String? orderNote, String? customerId,
    String? addressId, String? billingAddressId,
    String? couponCode,
    String? couponDiscount,
    String? paymentMethod}) async {
    _isLoading = true;
    notifyListeners();

    final bool shippingReady = await _ensureOrderWiseShippingReady();
    if (!shippingReady) {
      _isLoading = false;
      final String message = getTranslated('select_shipping_method', Get.context!) ??
          'Please select a shipping method before online payment';
      showCustomSnackBarWidget(message, Get.context!, snackBarType: SnackBarType.warning);
      notifyListeners();
      return ApiResponseModel.withError(message);
    }

    ApiResponseModel apiResponse = await checkoutServiceInterface.digitalPaymentPlaceOrder(orderNote, customerId, addressId, billingAddressId, couponCode, couponDiscount, paymentMethod, _isCheckCreateAccount, passwordController.text.trim());

    final int statusCode = apiResponse.response?.statusCode ?? 0;
    final dynamic responseData = apiResponse.response?.data;
    final String redirectLink = responseData is Map
        ? '${responseData['redirect_link'] ?? ''}'.trim()
        : '';
    final Uri? redirectUri = Uri.tryParse(redirectLink);
    final bool hasValidRedirect = redirectUri != null &&
        (redirectUri.scheme == 'http' || redirectUri.scheme == 'https') &&
        redirectUri.host.isNotEmpty;

    if (apiResponse.response != null && statusCode >= 200 && statusCode < 300 && hasValidRedirect) {
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      _isLoading = false;

      RouterHelper.getDigitalPaymentScreenRoute(
        url: redirectLink,
        fromWallet: false,
        action: RouteAction.pushReplacement,
      );
    } else {
      _isLoading = false;
      String errorMessage = apiResponse.error?.toString().trim() ?? '';
      if (errorMessage.toLowerCase() == 'data not found') {
        errorMessage = getTranslated('select_shipping_method', Get.context!) ??
            'Please select a shipping method before online payment';
      } else if (apiResponse.response != null && statusCode >= 200 && statusCode < 300 && !hasValidRedirect) {
        errorMessage = 'Payment gateway did not return a valid redirect link';
      }

      showCustomSnackBarWidget(
        errorMessage.isNotEmpty
            ? errorMessage
            : getTranslated('payment_method_not_properly_configured', Get.context!),
        Get.context!,
        snackBarType: apiResponse.error == 'Already registered '
            ? SnackBarType.warning
            : SnackBarType.error,
      );
    }
    notifyListeners();
    return apiResponse;
  }

  bool sameAsBilling = false;
  void setSameAsBilling({bool isUpdate = true}) {
    sameAsBilling = !sameAsBilling;
    if(isUpdate) {
      notifyListeners();
    }
  }

  void clearData(){
    orderNoteController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isCheckCreateAccount = false;
    _cashChangesAmount = null;
  }


  void setIsCheckCreateAccount(bool isCheck, {bool update = true}) {
    _isCheckCreateAccount = isCheck;
    if(update) {
      notifyListeners();
    }
  }



  void toggleChangeAmountShow(){
    _changeAmountShow = !_changeAmountShow;
    notifyListeners();
  }

  void onChangeCashChangesAmount(double? amount)=> _cashChangesAmount = amount;


  Future<ApiResponseModel> getReferralAmount(String? amount) async {
    ApiResponseModel apiResponse = await checkoutServiceInterface.getReferralAmount(amount);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _referralAmount = ReferralAmount.fromJson(apiResponse.response.data);
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }


  void toggleTermsCheck({bool isUpdate = true}) {
    _isAcceptTerms = !_isAcceptTerms;
    if(isUpdate) {
      notifyListeners();
    }
  }


  void updatePaymentSelection(){
    notifyListeners();
  }


}
