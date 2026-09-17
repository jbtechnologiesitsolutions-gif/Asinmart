import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/slider_product_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class LatestProductListWidget extends StatelessWidget {
  const LatestProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (ctx, productController) => productController.latestProductModel,
      builder: (context, latestProductModel, child) {
        final products = latestProductModel?.products ?? [];
        if (products.isEmpty) {
          return latestProductModel == null ? const SliderProductShimmerWidget() : const SizedBox.shrink();
        }

        final bool isTablet = ResponsiveHelper.isTab(context);
        return Container(
          color: const Color(0xFFF8FAFB),
          padding: const EdgeInsets.only(top: 8, bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleRowWidget(
                title: getTranslated('latest_products', context),
                onTap: () => RouterHelper.getViewAllProductScreenRoute(
                  productType: ProductType.latestProduct,
                  action: RouteAction.push,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isTablet ? 390 : 330,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: isTablet ? 220 : 166,
                      child: ProductWidget(
                        productModel: products[index],
                        productNameLine: 2,
                        margin: 0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
