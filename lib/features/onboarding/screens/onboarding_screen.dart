import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  final Color indicatorColor;
  final Color selectedIndicatorColor;
  OnBoardingScreen({
    super.key,
    this.indicatorColor = AsinDesign.border,
    this.selectedIndicatorColor = AsinDesign.gold,
  });

  final PageController _pageController = PageController();

  void _finish(BuildContext context) {
    Provider.of<SplashController>(context, listen: false).disableIntro();
    Provider.of<AuthController>(context, listen: false).getGuestIdUrl();
    RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingController>(context, listen: false).getOnBoardingList();

    return Scaffold(
      backgroundColor: AsinDesign.canvas(context),
      body: SafeArea(
        child: Consumer<OnBoardingController>(
          builder: (context, controller, _) {
            final items = controller.onBoardingList;
            if (items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final bool last = controller.selectedIndex == items.length - 1;

            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: controller.changeSelectIndex,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Column(
                        children: [
                          Expanded(
                            flex: 58,
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                              decoration: BoxDecoration(
                                color: AsinDesign.softCard(context),
                                borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                                child: Image.asset(item.imageUrl, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 42,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title ?? '',
                                    textAlign: TextAlign.center,
                                    style: textBold.copyWith(
                                      color: AsinDesign.foreground(context),
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.description ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: textRegular.copyWith(
                                      color: AsinDesign.muted(context),
                                      fontSize: 13,
                                      height: 1.55,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      items.length,
                                      (dot) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 220),
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        width: dot == controller.selectedIndex ? 18 : 6,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: dot == controller.selectedIndex
                                              ? AsinDesign.gold
                                              : AsinDesign.line(context),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    6,
                    16,
                    MediaQuery.of(context).padding.bottom > 0 ? 8 : 16,
                  ),
                  child: Row(
                    children: [
                      if (!last)
                        TextButton(
                          onPressed: () => _finish(context),
                          child: Text(
                            getTranslated('skip', context) ?? 'Skip',
                            style: textMedium.copyWith(color: AsinDesign.muted(context), fontSize: 13),
                          ),
                        )
                      else
                        const SizedBox(width: 72),
                      const Spacer(),
                      SizedBox(
                        width: last ? 150 : 108,
                        child: CustomButton(
                          isBuy: last,
                          backgroundColor: last ? AsinDesign.gold : AsinDesign.primaryDeep,
                          textColor: last ? AsinDesign.primaryDeep : Colors.white,
                          buttonText: last ? (getTranslated('explore', context) ?? 'Get Started') : 'Next',
                          onTap: () {
                            if (last) {
                              _finish(context);
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
