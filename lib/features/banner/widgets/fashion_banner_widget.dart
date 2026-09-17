import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banner_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class FashionBannersWidget extends StatelessWidget {
  const FashionBannersWidget({super.key});

  static const Color _deepGreen = Color(0xFF00382F);

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, bannerController, child) {
        final banners = bannerController.mainBannerList;
        final width = MediaQuery.sizeOf(context).width;

        if (banners == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: BannerShimmer(),
          );
        }

        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        final double bannerHeight = (width - 20) * .62;

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 7),
          child: Column(
            children: [
              SizedBox(
                height: bannerHeight,
                width: width,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: bannerHeight,
                    viewportFraction: .93,
                    autoPlay: banners.length > 1,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(milliseconds: 650),
                    pauseAutoPlayOnTouch: true,
                    enlargeCenterPage: true,
                    enlargeFactor: .045,
                    onPageChanged: (index, reason) => bannerController.setCurrentIndex(index),
                  ),
                  itemCount: banners.length,
                  itemBuilder: (context, index, _) {
                    final banner = banners[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () {
                        bannerController.clickBannerRedirect(
                          context,
                          banner.resourceId,
                          banner.resourceType == 'product' ? banner.product : null,
                          banner.resourceType,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _deepGreen,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),
                              blurRadius: 13,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CustomImageWidget(
                          image: '${banner.photoFullUrl?.path}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (banners.length > 1) ...[
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (index) {
                    final selected = index == bannerController.currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 5,
                      width: selected ? 21 : 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: selected ? _deepGreen : _deepGreen.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
