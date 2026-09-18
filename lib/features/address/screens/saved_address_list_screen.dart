import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/widgets/address_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class SavedAddressListScreen extends StatefulWidget {
  final bool fromGuest;
  const SavedAddressListScreen({super.key, this.fromGuest = false});

  @override
  State<SavedAddressListScreen> createState() => _SavedAddressListScreenState();
}

class _SavedAddressListScreenState extends State<SavedAddressListScreen> {
  @override
  void initState() {
    Provider.of<AddressController>(context, listen: false).getAddressList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsinDesign.canvas(context),
      appBar: CustomAppBar(title: widget.fromGuest ? getTranslated('ADDRESS_LIST', context) : 'Select Address'),
      bottomNavigationBar: Consumer<CheckoutController>(
        builder: (context, checkout, _) => Container(
          padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
          decoration: BoxDecoration(
            color: AsinDesign.card(context),
            border: Border(top: BorderSide(color: AsinDesign.line(context))),
          ),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: checkout.addressIndex == null ? null : () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AsinDesign.gold,
                foregroundColor: AsinDesign.primaryDeep,
                disabledBackgroundColor: AsinDesign.line(context),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
              ),
              child: Text('Deliver Here', style: textBold.copyWith(fontSize: 13, color: AsinDesign.primaryDeep)),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<AddressController>(
          builder: (context, locationProvider, child) {
            final addresses = locationProvider.addressList;
            if (addresses == null) return const AddressShimmerWidget();
            if (addresses.isEmpty) {
              return Center(
                child: NoInternetOrDataScreenWidget(
                  isNoInternet: false,
                  message: 'no_address_found',
                  icon: Images.noAddress,
                ),
              );
            }

            return Consumer<CheckoutController>(
              builder: (context, checkout, _) {
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    ...List.generate(addresses.length, (index) {
                      final selected = checkout.addressIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AddressSelectionCard(
                          address: addresses[index],
                          selected: selected,
                          onTap: () => checkout.setAddressIndex(index),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: () => RouterHelper.getAddNewAddressRoute(isBilling: false),
                      borderRadius: BorderRadius.circular(AsinDesign.radius),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AsinDesign.card(context),
                          borderRadius: BorderRadius.circular(AsinDesign.radius),
                          border: Border.all(color: AsinDesign.gold, width: 1.2),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded, size: 18, color: AsinDesign.primary),
                            const SizedBox(width: 5),
                            Text('Add New Address', style: textBold.copyWith(color: AsinDesign.primary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AddressSelectionCard extends StatelessWidget {
  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  const _AddressSelectionCard({required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = (address.addressType ?? 'Address').toUpperCase();
    final addressLine = [address.address, address.city, address.state, address.zip]
        .where((e) => e != null && e!.trim().isNotEmpty)
        .map((e) => e!.trim())
        .join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AsinDesign.card(context),
          borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
          border: Border.all(color: selected ? AsinDesign.gold : AsinDesign.line(context), width: selected ? 1.6 : 1),
          boxShadow: selected
              ? [BoxShadow(color: AsinDesign.primary.withValues(alpha: .08), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AsinDesign.goldSoft, borderRadius: BorderRadius.circular(5)),
                  child: Text(type, style: textBold.copyWith(color: AsinDesign.primary, fontSize: 8.5)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(address.contactPersonName ?? '', style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 12.5)),
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
                  child: selected ? const Icon(Icons.check_rounded, size: 13, color: AsinDesign.primaryDeep) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(addressLine, style: textRegular.copyWith(color: AsinDesign.foreground(context), fontSize: 10.5, height: 1.45)),
            if ((address.phone ?? '').isNotEmpty) ...[
              const SizedBox(height: 5),
              Text('Phone: ${address.phone}', style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 9.5)),
            ],
            const SizedBox(height: 9),
            InkWell(
              onTap: () => RouterHelper.getAddNewAddressRoute(
                isEnableUpdate: true,
                fromCheckout: true,
                isBilling: false,
                address: address,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('Edit', style: textBold.copyWith(color: AsinDesign.primary, fontSize: 9.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
