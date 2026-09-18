import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/change_amount_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  final bool onlyDigital;
  const PaymentMethodBottomSheetWidget({super.key, required this.onlyDigital});

  @override
  State<PaymentMethodBottomSheetWidget> createState() => PaymentMethodBottomSheetWidgetState();
}

class PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {
  final TextEditingController changeAmountTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final checkout = Provider.of<CheckoutController>(context, listen: false);
    final config = Provider.of<SplashController>(context, listen: false).configModel;
    changeAmountTextController.text = '${checkout.cashChangesAmount ?? ''}';
  }

  String _gatewayIdentity(PaymentMethods method) {
    final raw = '${method.keyName ?? ''} ${method.additionalDatas?.gatewayTitle ?? ''}'.toLowerCase();
    return raw.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  bool _isUpiCapableGateway(PaymentMethods method) {
    final identity = _gatewayIdentity(method);
    // These gateways can surface UPI in their hosted checkout when UPI is
    // enabled for the merchant account. We still send the backend's original
    // key_name, so this UI alias does not change the payment API contract.
    const markers = <String>[
      'upi',
      'razorpay',
      'razor',
      'phonepe',
      'googlepay',
      'gpay',
      'cashfree',
      'payu',
      'paytm',
    ];
    return markers.any(identity.contains);
  }

  int? _upiGatewayIndex(List<PaymentMethods>? methods) {
    if (methods == null || methods.isEmpty) return null;
    for (int i = 0; i < methods.length; i++) {
      if (_isUpiCapableGateway(methods[i])) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<SplashController>(context, listen: false).configModel;
    final methods = config?.paymentMethods ?? <PaymentMethods>[];
    final upiIndex = _upiGatewayIndex(methods);

    return Consumer<CheckoutController>(
      builder: (context, checkout, _) {
        return PopScope(
          onPopInvokedWithResult: (_, __) {
            checkout.onChangeCashChangesAmount(
              checkout.isCODChecked ? double.tryParse(changeAmountTextController.text) : null,
            );
          },
          child: FractionallySizedBox(
            heightFactor: .96,
            child: Container(
              decoration: BoxDecoration(
                color: AsinDesign.card(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(width: 42, height: 4, decoration: BoxDecoration(color: AsinDesign.line(context), borderRadius: BorderRadius.circular(99))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        Text('Payment', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 20, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: AsinDesign.foreground(context))),
                      ],
                    ),
                  ),
                  const _CheckoutSteps(),
                  Divider(height: 1, color: AsinDesign.line(context)),
                  Expanded(
                    child: _isPaymentMethodsAvailable(context, checkout.offlinePaymentModel?.offlineMethods)
                        ? ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                            children: [
                              if ((config?.digitalPayment ?? false) || methods.isNotEmpty) ...[
                                Text('Payment Methods', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 15)),
                                const SizedBox(height: 10),
                                _PaymentTile(
                                  iconData: Icons.account_balance_outlined,
                                  title: 'UPI / Google Pay',
                                  subtitle: upiIndex != null
                                      ? 'Pay securely with any supported UPI app'
                                      : 'UPI needs to be enabled in the server payment gateway settings',
                                  selected: upiIndex != null && checkout.paymentMethodIndex == upiIndex,
                                  enabled: upiIndex != null,
                                  onTap: upiIndex == null
                                      ? null
                                      : () => checkout.setDigitalPaymentMethodName(
                                            upiIndex,
                                            methods[upiIndex].keyName ?? 'razor_pay',
                                          ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              if (((config?.digitalPayment ?? false) || methods.isNotEmpty) && methods.isNotEmpty)
                                ...List.generate(methods.length, (index) {
                                  if (index == upiIndex) return const SizedBox.shrink();
                                  final method = methods[index];
                                  final title = (method.additionalDatas?.gatewayTitle ?? '').trim().isNotEmpty
                                      ? method.additionalDatas!.gatewayTitle!
                                      : (method.keyName ?? 'Online payment').replaceAll('_', ' ');
                                  final image = '${config?.paymentMethodImagePath ?? ''}/${method.additionalDatas?.gatewayImage ?? ''}';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _PaymentTile(
                                      image: image,
                                      title: title,
                                      subtitle: 'Secure online payment',
                                      selected: checkout.paymentMethodIndex == index,
                                      onTap: () => checkout.setDigitalPaymentMethodName(index, method.keyName ?? ''),
                                    ),
                                  );
                                }),

                              if ((config?.cashOnDelivery ?? false) && !widget.onlyDigital) ...[
                                _PaymentTile(
                                  iconData: Icons.payments_outlined,
                                  title: getTranslated('cash_on_delivery', context) ?? 'Cash on Delivery',
                                  subtitle: 'Pay when your order arrives',
                                  selected: checkout.isCODChecked,
                                  onTap: () => checkout.setOfflineChecked('cod'),
                                ),
                                ChangeAmountWidget(changeAmountTextController: changeAmountTextController),
                                const SizedBox(height: 10),
                              ],

                              if (config?.walletStatus == 1 && Provider.of<AuthController>(context, listen: false).isLoggedIn()) ...[
                                _PaymentTile(
                                  iconData: Icons.account_balance_wallet_outlined,
                                  title: getTranslated('pay_via_wallet', context) ?? 'Wallet',
                                  subtitle: 'Use your AsinMart wallet balance',
                                  selected: checkout.isWalletChecked,
                                  onTap: () => checkout.setOfflineChecked('wallet'),
                                ),
                                const SizedBox(height: 10),
                              ],

                              if ((checkout.offlinePaymentModel?.offlineMethods?.isNotEmpty ?? false)) ...[
                                Text('Offline Payment', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 14)),
                                const SizedBox(height: 8),
                                ...List.generate(checkout.offlinePaymentModel!.offlineMethods!.length, (index) {
                                  final method = checkout.offlinePaymentModel!.offlineMethods![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _PaymentTile(
                                      iconData: Icons.receipt_long_outlined,
                                      title: method.methodName ?? 'Offline payment',
                                      subtitle: 'Manual payment method',
                                      selected: checkout.isOfflineChecked && checkout.offlineMethodSelectedIndex == index,
                                      onTap: () {
                                        if (!checkout.isOfflineChecked) checkout.setOfflineChecked('offline');
                                        checkout.setOfflinePaymentMethodSelectedIndex(index);
                                      },
                                    ),
                                  );
                                }),
                              ],

                            ],
                          )
                        : const NoInternetOrDataScreenWidget(isNoInternet: false, message: 'no_payment_method_available_right_now'),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
                    decoration: BoxDecoration(
                      color: AsinDesign.card(context),
                      border: Border(top: BorderSide(color: AsinDesign.line(context))),
                    ),
                    child: CustomButton(
                      isBuy: true,
                      buttonText: 'Continue to Review',
                      onTap: () {
                        checkout.onChangeCashChangesAmount(
                          checkout.isCODChecked ? double.tryParse(changeAmountTextController.text) : null,
                        );
                        Navigator.of(context).pop();
                        if ((config?.cashOnDelivery ?? false) && !widget.onlyDigital) {
                          checkout.updatePaymentSelection();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckoutSteps extends StatelessWidget {
  const _CheckoutSteps();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
      child: Row(
        children: [
          const _StepBadge(index: 1, label: 'Address', completed: true),
          Expanded(child: Container(height: 1, color: AsinDesign.primary)),
          const _StepBadge(index: 2, label: 'Payment', active: true),
          Expanded(child: Container(height: 1, color: AsinDesign.border)),
          const _StepBadge(index: 3, label: 'Review'),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int index;
  final String label;
  final bool active;
  final bool completed;
  const _StepBadge({required this.index, required this.label, this.active = false, this.completed = false});

  @override
  Widget build(BuildContext context) {
    final color = completed ? AsinDesign.success : (active ? AsinDesign.gold : AsinDesign.line(context));
    final textColor = completed ? AsinDesign.success : (active ? AsinDesign.primary : AsinDesign.muted(context));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 21,
          height: 21,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: completed
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
              : Text('$index', style: textBold.copyWith(color: active ? AsinDesign.primaryDeep : AsinDesign.muted(context), fontSize: 9)),
        ),
        const SizedBox(width: 5),
        Text(label, style: textMedium.copyWith(color: textColor, fontSize: 10.5)),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData? iconData;
  final String? image;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _PaymentTile({
    this.iconData,
    this.image,
    required this.title,
    this.subtitle,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: enabled ? AsinDesign.card(context) : AsinDesign.softCard(context),
          borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
          border: Border.all(color: selected ? AsinDesign.primary : AsinDesign.line(context), width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AsinDesign.softCard(context), borderRadius: BorderRadius.circular(AsinDesign.radius)),
              child: image != null && image!.isNotEmpty
                  ? Padding(padding: const EdgeInsets.all(5), child: CustomImageWidget(image: image!, fit: BoxFit.contain))
                  : Icon(iconData ?? Icons.credit_card_rounded, color: AsinDesign.primary, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textBold.copyWith(color: enabled ? AsinDesign.foreground(context) : AsinDesign.muted(context), fontSize: 12.5)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AsinDesign.gold : AsinDesign.muted(context), width: 2),
                color: selected ? AsinDesign.gold : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check_rounded, color: AsinDesign.primaryDeep, size: 13) : null,
            ),
          ],
        ),
      ),
    );
  }
}

bool _isPaymentMethodsAvailable(BuildContext context, List<OfflineMethods>? offlineMethods) {
  final config = Provider.of<SplashController>(context, listen: false).configModel;
  final isCashOnDeliveryOn = config?.cashOnDelivery ?? false;
  final isWalletOn = config?.walletStatus == 1 && Provider.of<AuthController>(context, listen: false).isLoggedIn();
  // Keep the payment sheet available when digital payment is enabled even if
  // the server returned no active gateway. In that case the UPI row remains
  // visible but disabled with an explicit configuration message.
  final isOnlinePaymentMethodsOn = (config?.digitalPayment ?? false) || ((config?.paymentMethods?.isNotEmpty ?? false));
  final isOfflinePaymentMethodsOn = offlineMethods?.isNotEmpty ?? false;
  return isCashOnDeliveryOn || isWalletOn || isOnlinePaymentMethodsOn || isOfflinePaymentMethodsOn;
}
