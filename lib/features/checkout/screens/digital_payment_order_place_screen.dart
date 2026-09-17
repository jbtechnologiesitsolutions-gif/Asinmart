import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_bottomsheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:provider/provider.dart';

class DigitalPaymentScreen extends StatefulWidget {
  final String url;
  final bool fromWallet;
  final String orderId;

  const DigitalPaymentScreen({
    super.key,
    required this.url,
    this.fromWallet = false,
    this.orderId = '',
  });

  @override
  DigitalPaymentScreenState createState() => DigitalPaymentScreenState();
}

class DigitalPaymentScreenState extends State<DigitalPaymentScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _canRedirect = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initWebViewController();
      _isInitialized = true;
    }
  }

  void _initWebViewController() {
    final Uri? initialUri = Uri.tryParse(widget.url.trim());
    if (initialUri == null ||
        !initialUri.hasScheme ||
        !(initialUri.scheme == 'http' || initialUri.scheme == 'https')) {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePaymentResult(false, true, false, false, null);
      });
      return;
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(context).cardColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100 && mounted) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: _checkRedirect,
          onPageFinished: _checkRedirect,
          onWebResourceError: (WebResourceError error) {
            debugPrint('Payment WebView Error: ${error.errorCode} ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (_isRedirectUrl(request.url)) {
              _checkRedirect(request.url);
              return NavigationDecision.prevent;
            }

            final Uri? uri = Uri.tryParse(request.url);
            if (uri != null && _isExternalPaymentScheme(uri.scheme)) {
              await _launchExternalPaymentApp(uri);
              // Never ask WebView to load UPI/app-intent schemes. If no matching
              // payment app is installed, the gateway page remains visible so
              // the customer can choose another available payment method.
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(initialUri);
  }

  bool _isExternalPaymentScheme(String scheme) {
    final normalized = scheme.toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'http' &&
        normalized != 'https' &&
        normalized != 'about' &&
        normalized != 'data' &&
        normalized != 'javascript';
  }

  Future<bool> _launchExternalPaymentApp(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Unable to open payment app: $e');
      return false;
    }
  }

  String _normalizeHost(String host) {
    final lower = host.toLowerCase().trim();
    return lower.startsWith('www.') ? lower.substring(4) : lower;
  }

  bool _isRedirectUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    final Uri? baseUri = Uri.tryParse(AppConstants.baseUrl);
    if (uri == null || baseUri == null || uri.host.isEmpty) return false;

    final String host = _normalizeHost(uri.host);
    final String baseHost = _normalizeHost(baseUri.host);
    final bool isStoreHost = host == baseHost || host.endsWith('.$baseHost');
    if (!isStoreHost) return false;

    final String lowerPath = uri.path.toLowerCase();
    final String lowerUrl = url.toLowerCase();
    final String status = (
      uri.queryParameters['status'] ??
      uri.queryParameters['payment_status'] ??
      uri.queryParameters['result'] ??
      ''
    ).toLowerCase();

    final bool hasSuccess = lowerPath.contains('success') ||
        lowerUrl.contains('payment-success') ||
        status == 'success' ||
        status == 'successful' ||
        status == 'paid';
    final bool hasFailure = lowerPath.contains('fail') ||
        lowerUrl.contains('payment-fail') ||
        status == 'fail' ||
        status == 'failed';
    final bool hasCancel = lowerPath.contains('cancel') ||
        lowerUrl.contains('payment-cancel') ||
        status == 'cancel' ||
        status == 'cancelled' ||
        status == 'canceled';

    return hasSuccess || hasFailure || hasCancel;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSafePadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (val, _) {
        if (_canRedirect) _exitApp(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          title: Text(getTranslated('payment', context) ?? 'Payment'),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => _exitApp(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (_isInitialized && widget.url.trim().isNotEmpty)
                    WebViewWidget(controller: controller),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: bottomSafePadding),
          ],
        ),
      ),
    );
  }

  void _checkRedirect(String url) {
    if (_canRedirect && _isRedirectUrl(url)) {
      _canRedirect = false;

      final String lowerUrl = url.toLowerCase();
      final Uri? uri = Uri.tryParse(url);
      final String status = (
        uri?.queryParameters['status'] ??
        uri?.queryParameters['payment_status'] ??
        uri?.queryParameters['result'] ??
        ''
      ).toLowerCase();

      final bool isSuccess = lowerUrl.contains('success') ||
          status == 'success' || status == 'successful' || status == 'paid';
      final bool isFailed = lowerUrl.contains('fail') || status == 'fail' || status == 'failed';
      final bool isCancel = lowerUrl.contains('cancel') ||
          status == 'cancel' || status == 'cancelled' || status == 'canceled';
      final bool isNewUser = _getIsNewUser(url);
      final String? orderIds = _getOrderIds(url);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePaymentResult(isSuccess, isFailed, isCancel, isNewUser, orderIds);
      });
    }
  }

  void _handlePaymentResult(
    bool isSuccess,
    bool isFailed,
    bool isCancel,
    bool isNewUser,
    String? orderIds,
  ) {
    final bool isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();

    if (isSuccess) {
      if (widget.orderId.trim().isNotEmpty && widget.orderId.trim() != 'null' && (orderIds == null || orderIds.isEmpty)) {
        final int? parsedOrderId = int.tryParse(widget.orderId);
        if (parsedOrderId != null) {
          RouterHelper.getOrderDetailsScreenRoute(
            orderId: parsedOrderId,
            action: RouteAction.pushReplacement,
            isNotification: true,
          );
        } else {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'orders');
        }
      } else if (isLoggedIn && orderIds != null && orderIds.isNotEmpty) {
        RouterHelper.getOrderScreenRoute(
          isBackButtonExist: true,
          action: RouteAction.pushReplacement,
          fromPlaceOrder: true,
        );
      } else {
        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
      }

      if (widget.orderId.trim() == 'null') {
        _showResultUI(
          isBottomSheet: true,
          orderIds: orderIds,
          isNewUser: isNewUser,
          icon: Icons.check,
          titleKey: isNewUser ? 'order_placed_Account_Created' : 'order_placed',
          descKey: 'your_order_placed',
        );
      }
    } else {
      RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');

      _showResultUI(
        isBottomSheet: false,
        icon: Icons.clear,
        titleKey: isFailed ? 'payment_failed' : 'payment_cancelled',
        descKey: isFailed ? 'your_payment_failed' : 'your_payment_cancelled',
        isFailed: true,
      );
    }
  }

  void _showResultUI({
    required bool isBottomSheet,
    String? orderIds,
    bool isNewUser = false,
    required IconData icon,
    required String titleKey,
    required String descKey,
    bool isFailed = false,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isBottomSheet) {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: OrderPlaceBottomSheetWidget(
                orderID: orderIds,
                icon: icon,
                title: getTranslated(titleKey, Get.context!),
                description: getTranslated(descKey, Get.context!),
                isFailed: isFailed,
              ),
            ),
          ),
        );
      } else {
        showAnimatedDialog(
          Get.context!,
          OrderPlaceDialogWidget(
            icon: icon,
            title: getTranslated(titleKey, Get.context!),
            description: getTranslated(descKey, Get.context!),
            isFailed: isFailed,
          ),
          dismissible: false,
          willFlip: true,
        );
      }
    });
  }

  bool _getIsNewUser(String url) {
    try {
      final Uri uri = Uri.parse(url);
      return uri.queryParameters['new_user'] == '1';
    } catch (_) {
      return false;
    }
  }

  String? _getOrderIds(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final String? encodedData = uri.queryParameters['order_ids'];
      if (encodedData == null || encodedData.isEmpty) return null;

      try {
        final String decoded = utf8.decode(base64.decode(base64.normalize(encodedData)));
        return Provider.of<CheckoutController>(context, listen: false).extractId(decoded);
      } catch (_) {
        return Provider.of<CheckoutController>(context, listen: false).extractId(Uri.decodeComponent(encodedData));
      }
    } catch (e) {
      debugPrint('Order ID Extraction Error: $e');
      return null;
    }
  }

  Future<void> _exitApp(BuildContext context) async {
    if (!_canRedirect) return;
    _canRedirect = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      showAnimatedDialog(
        Get.context!,
        OrderPlaceDialogWidget(
          icon: Icons.clear,
          title: getTranslated('payment_cancelled', Get.context!),
          description: getTranslated('your_payment_cancelled', Get.context!),
          isFailed: true,
        ),
        dismissible: false,
        willFlip: true,
      );
    });
  }
}
