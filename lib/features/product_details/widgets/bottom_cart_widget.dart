import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/cart_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class BottomCartWidget extends StatefulWidget {
  final ProductDetailsModel? product;
  const BottomCartWidget({super.key, required this.product});

  @override
  State<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends State<BottomCartWidget> {
  bool vacationIsOn = false;
  bool temporaryClose = false;

  @override
  void initState() {
    super.initState();
    vacationIsOn = ShopHelper.isVacationActive(
      context,
      startDate: widget.product?.seller?.shop?.vacationStartDate,
      endDate: widget.product?.seller?.shop?.vacationEndDate,
      vacationDurationType: widget.product?.seller?.shop?.vacationDurationType,
      vacationStatus: widget.product?.seller?.shop?.vacationStatus,
      isInHouseSeller: widget.product?.addedBy == 'admin',
    );

    if (widget.product?.addedBy == 'admin') {
      temporaryClose = Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inhouseTemporaryClose
              ?.status ??
          false;
    } else {
      temporaryClose = widget.product?.seller?.shop?.temporaryClose ?? false;
    }
  }

  void _openConfigurator() {
    if (vacationIsOn || temporaryClose) {
      showCustomSnackBarWidget(
        getTranslated('this_shop_is_close_now', context),
        context,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CartBottomSheetWidget(
        product: widget.product,
        callback: () {
          showCustomSnackBarWidget(
            getTranslated('added_to_cart', context),
            context,
            snackBarType: SnackBarType.success,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom > 0 ? 6 : 12),
      decoration: BoxDecoration(
        color: AsinDesign.card(context),
        border: Border(top: BorderSide(color: AsinDesign.line(context))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .18 : .05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _openConfigurator,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AsinDesign.primary,
                  side: const BorderSide(color: AsinDesign.primary, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
                ),
                child: Text(
                  getTranslated('add_to_cart', context) ?? 'Add to Cart',
                  style: textBold.copyWith(color: AsinDesign.primary, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _openConfigurator,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AsinDesign.gold,
                  foregroundColor: AsinDesign.primaryDeep,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
                ),
                child: Text(
                  getTranslated('buy_now', context) ?? 'Buy Now',
                  style: textBold.copyWith(color: AsinDesign.primaryDeep, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
