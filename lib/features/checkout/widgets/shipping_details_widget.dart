import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/create_account_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class ShippingDetailsWidget extends StatefulWidget {
  final bool hasPhysical;
  final bool billingAddress;
  final GlobalKey<FormState> passwordFormKey;

  const ShippingDetailsWidget({
    super.key,
    required this.hasPhysical,
    required this.billingAddress,
    required this.passwordFormKey,
  });

  @override
  State<ShippingDetailsWidget> createState() => _ShippingDetailsWidgetState();
}

class _ShippingDetailsWidgetState extends State<ShippingDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    final isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();

    return Consumer<CheckoutController>(
      builder: (context, checkout, _) {
        if (checkout.sameAsBilling && !widget.hasPhysical) {
          checkout.setSameAsBilling(isUpdate: false);
        }
        return Consumer<AddressController>(
          builder: (context, addressController, _) {
            final addresses = addressController.addressList ?? <AddressModel>[];
            final AddressModel? shippingAddress = checkout.addressIndex != null &&
                    checkout.addressIndex! >= 0 && checkout.addressIndex! < addresses.length
                ? addresses[checkout.addressIndex!]
                : null;
            final AddressModel? billingAddress = checkout.billingAddressIndex != null &&
                    checkout.billingAddressIndex! >= 0 && checkout.billingAddressIndex! < addresses.length
                ? addresses[checkout.billingAddressIndex!]
                : null;

            return Column(
              children: [
                if (widget.hasPhysical)
                  _CheckoutAddressCard(
                    title: 'Delivery Address',
                    address: shippingAddress,
                    emptyText: 'Select a delivery address',
                    onChange: () => RouterHelper.getSavedAddressListRoute(fromGuest: isGuestMode),
                  ),

                if (isGuestMode && widget.hasPhysical) ...[
                  const SizedBox(height: 10),
                  CreateAccountWidget(formKey: widget.passwordFormKey),
                ],

                if (widget.billingAddress) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: AsinDesign.cardDecoration(context, radius: AsinDesign.radiusLg),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => checkout.setSameAsBilling(),
                          borderRadius: BorderRadius.circular(5),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 21,
                            height: 21,
                            decoration: BoxDecoration(
                              color: checkout.sameAsBilling ? AsinDesign.primary : AsinDesign.card(context),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: checkout.sameAsBilling ? AsinDesign.primary : AsinDesign.line(context)),
                            ),
                            child: checkout.sameAsBilling ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Billing address same as delivery', style: textMedium.copyWith(color: AsinDesign.foreground(context), fontSize: 10.5)),
                        ),
                      ],
                    ),
                  ),
                  if (!checkout.sameAsBilling) ...[
                    const SizedBox(height: 10),
                    _CheckoutAddressCard(
                      title: 'Billing Address',
                      address: billingAddress,
                      emptyText: 'Select a billing address',
                      onChange: () => RouterHelper.getSavedBillingAddressListRoute(fromGuest: isGuestMode),
                    ),
                  ],
                ] else if (!widget.hasPhysical) ...[
                  const SizedBox(height: 10),
                  _CheckoutAddressCard(
                    title: 'Billing Address',
                    address: billingAddress,
                    emptyText: 'Select a billing address',
                    onChange: () => RouterHelper.getSavedBillingAddressListRoute(fromGuest: isGuestMode),
                  ),
                  if (isGuestMode) ...[
                    const SizedBox(height: 10),
                    CreateAccountWidget(formKey: widget.passwordFormKey),
                  ],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _CheckoutAddressCard extends StatelessWidget {
  final String title;
  final AddressModel? address;
  final String emptyText;
  final VoidCallback onChange;

  const _CheckoutAddressCard({
    required this.title,
    required this.address,
    required this.emptyText,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final addressLine = address == null
        ? ''
        : [address!.address, address!.city, address!.state, address!.zip]
            .where((e) => e != null && e!.trim().isNotEmpty)
            .map((e) => e!.trim())
            .join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AsinDesign.cardDecoration(context, radius: AsinDesign.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AsinDesign.primarySoft, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.location_on_outlined, size: 18, color: AsinDesign.primary),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 13))),
              TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3)),
                child: Text(address == null ? 'Select' : 'Change', style: textBold.copyWith(color: AsinDesign.primary, fontSize: 10.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (address != null) ...[
            Text(address!.contactPersonName ?? '', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 11.5)),
            const SizedBox(height: 3),
            Text(addressLine, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.8, height: 1.4)),
            if ((address!.phone ?? '').isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(address!.phone!, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
            ],
          ] else
            Text(emptyText, style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 10.5)),
        ],
      ),
    );
  }
}
