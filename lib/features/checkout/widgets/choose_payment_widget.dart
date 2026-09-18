import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class ChoosePaymentWidget extends StatelessWidget {
  final bool onlyDigital;
  const ChoosePaymentWidget({super.key, required this.onlyDigital});

  bool _isUpiGateway(String value) {
    final v = value.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    return v.contains('razorpay') || v.contains('upi') || v.contains('googlepay') ||
        v.contains('gpay') || v.contains('phonepe') || v.contains('paytm') ||
        v.contains('cashfree') || v.contains('payu');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutController>(
      builder: (context, orderProvider, _) {
        return Consumer<SplashController>(
          builder: (context, configProvider, _) {
            String title = 'Select payment method';
            String subtitle = 'Choose UPI, online payment, wallet or COD';
            String image = '';
            IconData icon = Icons.account_balance_wallet_outlined;

            if (orderProvider.paymentMethodIndex >= 0 &&
                orderProvider.paymentMethodIndex < (configProvider.configModel?.paymentMethods?.length ?? 0)) {
              final paymentMethod = configProvider.configModel!.paymentMethods![orderProvider.paymentMethodIndex];
              final key = paymentMethod.keyName ?? '';
              final gatewayTitle = (paymentMethod.additionalDatas?.gatewayTitle ?? '').trim();
              title = _isUpiGateway('$key $gatewayTitle') ? 'UPI / Google Pay' : (gatewayTitle.isNotEmpty ? gatewayTitle : key.replaceAll('_', ' '));
              subtitle = _isUpiGateway('$key $gatewayTitle') ? 'Pay securely with your preferred UPI app' : 'Secure online payment';
              final gatewayImage = paymentMethod.additionalDatas?.gatewayImage ?? '';
              if (gatewayImage.isNotEmpty) {
                image = '${configProvider.configModel?.paymentMethodImagePath ?? ''}/$gatewayImage';
              }
              icon = _isUpiGateway('$key $gatewayTitle') ? Icons.account_balance_outlined : Icons.credit_card_rounded;
            } else if (orderProvider.isCODChecked) {
              title = getTranslated('cash_on_delivery', context) ?? 'Cash on Delivery';
              subtitle = 'Pay when your order arrives';
              icon = Icons.payments_outlined;
            } else if (orderProvider.isOfflineChecked) {
              title = getTranslated('offline_payment', context) ?? 'Offline Payment';
              subtitle = 'Manual payment method';
              icon = Icons.receipt_long_outlined;
            } else if (orderProvider.isWalletChecked) {
              title = getTranslated('wallet_payment', context) ?? 'Wallet Payment';
              subtitle = 'Use your AsinMart wallet balance';
              icon = Icons.account_balance_wallet_outlined;
            }

            return Container(
              decoration: AsinDesign.cardDecoration(context, radius: AsinDesign.radiusLg),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Payment Method', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 13.5)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => PaymentMethodBottomSheetWidget(onlyDigital: onlyDigital),
                        ),
                        style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3)),
                        child: Text('Change', style: textBold.copyWith(color: AsinDesign.primary, fontSize: 10.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PaymentMethodBottomSheetWidget(onlyDigital: onlyDigital),
                    ),
                    borderRadius: BorderRadius.circular(AsinDesign.radius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                      decoration: BoxDecoration(
                        color: AsinDesign.softCard(context),
                        borderRadius: BorderRadius.circular(AsinDesign.radius),
                        border: Border.all(color: AsinDesign.line(context)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AsinDesign.card(context), borderRadius: BorderRadius.circular(8)),
                            child: image.isNotEmpty
                                ? Padding(padding: const EdgeInsets.all(5), child: CustomImageWidget(image: image, fit: BoxFit.contain))
                                : Icon(icon, color: AsinDesign.primary, size: 21),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 11.5)),
                                const SizedBox(height: 2),
                                Text(subtitle, maxLines: 2, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AsinDesign.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
