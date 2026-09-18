import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/discount_tag_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/compare/controllers/compare_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/enums/preview_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/screens/product_image_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/audio_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/download_preview_file.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/image_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/video_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';


class ProductImageWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final bool fromFlashDeals;
  ProductImageWidget({super.key, required this.productModel, required this.fromFlashDeals});

  final PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context,listen: false);
    final bool isDarkTheme = Provider.of<ThemeController>(context).darkTheme;

    return productModel != null?
    Consumer<ProductDetailsController>(
        builder: (context, productController,_) {
          final images = productModel!.imagesFullUrl ?? [];
          final thumbnailPath = productModel!.thumbnailFullUrl?.path ?? '';
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

            InkWell(
              onTap: () => (productModel!.productImagesNull ?? true) || images.isEmpty
                  ? null
                  : Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ProductImageScreen(
                            title: getTranslated('product_image', context),
                            imageList: images,
                          );
                        },
                      ),
                    ),
              child: productModel != null ?
              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.homePagePadding,
                  top: Dimensions.homePagePadding,
                  right: Dimensions.homePagePadding,
                  bottom: Dimensions.paddingSizeEight,
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  child: Container(decoration:  BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: AsinDesign.line(context)),
                      borderRadius: BorderRadius.circular(16)),
                    child: Stack(children: [
                      SizedBox(
                        height: (MediaQuery.of(context).size.width.clamp(320.0, 560.0) * .70).toDouble(),
                        child: images.isNotEmpty
                            ? PageView.builder(
                                controller: _controller,
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                    child: Container(
                                      color: AsinDesign.softCard(context),
                                      padding: const EdgeInsets.all(8),
                                      child: CustomImageWidget(
                                        height: double.infinity,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        image: '${images[index].path}',
                                      ),
                                    ),
                                  );
                                },
                                onPageChanged: (index) => productController.setImageSliderSelectedIndex(index),
                              )
                            : Container(
                                color: AsinDesign.softCard(context),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(24),
                                child: thumbnailPath.isNotEmpty
                                    ? CustomImageWidget(image: thumbnailPath, fit: BoxFit.contain, width: double.infinity, height: double.infinity)
                                    : Icon(Icons.image_not_supported_outlined, size: 62, color: Theme.of(context).hintColor),
                              ),
                      ),


                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _indicators(context),
                            ),
                            const Spacer(),
                            Provider.of<ProductDetailsController>(context).imageSliderIndex != null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      right: Dimensions.paddingSizeDefault,
                                      bottom: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Text(images.isEmpty ? '0/0' : '${(productController.imageSliderIndex ?? 0) + 1}/${images.length}'),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),

                      Positioned(top: 16, right: 16,
                          child: Column(children: [

                            FavouriteButtonWidget(
                              backgroundColor: AsinDesign.card(context),
                              productId: productModel?.id,
                              fromProductDetails: true,
                            ),

                            if(splashController.configModel!.activeTheme != "default")
                              const SizedBox(height: Dimensions.paddingSizeSmall,),

                            if(splashController.configModel!.activeTheme != "default")
                              InkWell(onTap: () {
                                if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                  Provider.of<CompareController>(context, listen: false).addCompareList(productModel!.id!);
                                } else {
                                  showModalBottomSheet(backgroundColor: const Color(0x00FFFFFF),
                                    context: context, builder: (_)=> const NotLoggedInBottomSheetWidget());
                                }
                              },
                              child: Consumer<CompareController>(
                                builder: (context, compare,_) {
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: compare.compIds.contains(productModel!.id)
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).cardColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        child: Image.asset(
                                          Images.compare,
                                          color: compare.compIds.contains(productModel!.id)
                                              ? Theme.of(context).cardColor
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),


                            InkWell(
                              onTap: () {
                                if(productController.sharableLink != null) {
                                  SharePlus.instance.share(
                                    ShareParams(
                                      text: productController.sharableLink!,
                                    ),
                                  );
                                }
                              },
                              child: Container(width: 40, height: 40,
                                decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(
                                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.10),
                                    spreadRadius: 0,
                                    blurRadius: 15,
                                    offset: const Offset(0,3),
                                  )],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: Image.asset(Images.share, color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),

                          ])
                      ),

                      (productModel?.productType == 'digital' && productModel?.previewFileFullUrl != null && productModel?.previewFileFullUrl?.path != '') ?
                      Positioned (right: 10, bottom: 10,
                        child: InkWell(
                          onTap: () => _showPreview(productModel?.previewFileFullUrl?.path ?? '', productModel?.name ?? '', productModel?.previewFileFullUrl?.key ?? '', context),
                          child: Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            height: 35, width: 81,
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14063D39), offset: Offset(0, 6),
                                    blurRadius: 12, spreadRadius: -3,
                                  ),
                                  BoxShadow(
                                    color: Color(0x14063D39), offset: Offset(0, -6),
                                    blurRadius: 12, spreadRadius: -3,
                                  ),
                                ]
                            ),
                            child: Row(
                                children: [
                                  Image.asset(Images.previewEyeIcon, width: 15),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Text('${getTranslated('preview', context)}',
                                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault)
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ) : const SizedBox(),

                      if(fromFlashDeals)
                      Positioned(
                        top: 16, left: 16,
                        child:  Image.asset(Images.flashDeal, scale: 2),
                      ),

                      ((productModel?.discount ?? 0) > 0 || (productModel?.clearanceSale != null)) ?
                      // DiscountTagWidget(productModel: productModel) : const SizedBox.shrink(),

                      DiscountTagDetailsWidget(
                        productModel: productModel!,
                        positionedTop: 0,
                        topLeftBorderRadius: Dimensions.radiusDefault,
                        bottomRightBorderRadius: Dimensions.radiusDefault
                      ) : const SizedBox.shrink(),



                    ]),
                  ),
                ),
              ) :
              const SizedBox(),
            ),

            const SizedBox(height: 10),


          ]);
        }
    ) : const SizedBox();
  }

  List<Widget> _indicators(BuildContext context) {
    List<Widget> indicators = [];
    final images = productModel?.imagesFullUrl ?? [];
    for (int index = 0; index < images.length; index++) {
      indicators.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraExtraSmall),
        child: Container(width: index == Provider.of<ProductDetailsController>(context).imageSliderIndex? 20 : 6, height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: index == Provider.of<ProductDetailsController>(context).imageSliderIndex ?
            Theme.of(context).primaryColor : Theme.of(context).hintColor,
          ),

        ),
      ));
    }
    return indicators;
  }

  void _showPreview(String url, String productName, String fileName, BuildContext context) {
    PreviewType type = Provider.of<ProductDetailsController>(context, listen: false).getFileType(url);

    showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: (type == PreviewType.pdf) ?
        PdfPreview(url: url, fileName: productName) : (type == PreviewType.image) ?
        ImagePreview(url: url, fileName: productName) : (type == PreviewType.video) ?
        VideoPreview(url: url, fileName: productName) : (type == PreviewType.audio)  ?
        AudioPreview(url: url, fileName: productName) : (type == PreviewType.others) ?
        DownloadPreview(url: url, fileName: fileName) :
        const SizedBox(),
      );
    });

  }

}
