import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class ProfileInfoSectionWidget extends StatelessWidget {
  const ProfileInfoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, profile, _) {
        final auth = Provider.of<AuthController>(context, listen: false);
        final themeController = Provider.of<ThemeController>(context);
        final isGuestMode = !auth.isLoggedIn();
        final dark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AsinDesign.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [AsinDesign.primaryInk, AsinDesign.primaryDeep]
                  : [AsinDesign.primary, AsinDesign.primaryDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF063D39).withValues(alpha: dark ? .24 : .20),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -38,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: .07), width: 18),
                  ),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (isGuestMode) {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.profileScreen1),
                        );
                      } else if (profile.userInfoModel != null) {
                        RouterHelper.getProfileScreen1Route(action: RouteAction.push);
                      }
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 68,
                      height: 68,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AsinDesign.gold, width: 1.5),
                      ),
                      child: ClipOval(
                        child: auth.isLoggedIn()
                            ? CustomImageWidget(
                                image: '${profile.userInfoModel?.imageFullUrl?.path}',
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                                placeholder: Images.guestProfile,
                              )
                            : Image.asset(Images.guestProfile, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          !isGuestMode
                              ? '${profile.userInfoModel?.fName ?? ''} ${profile.userInfoModel?.lName ?? ''}'.trim()
                              : 'Welcome to AsinMart',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraLarge,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          !isGuestMode && (profile.userInfoModel?.phone?.isNotEmpty ?? false)
                              ? profile.userInfoModel!.phone!
                              : 'Sign in for orders, wishlist and faster checkout',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(
                            color: Colors.white.withValues(alpha: .72),
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => Provider.of<ThemeController>(context, listen: false).toggleTheme(),
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) => RotationTransition(
                            turns: Tween<double>(begin: .85, end: 1).animate(animation),
                            child: FadeTransition(opacity: animation, child: child),
                          ),
                          child: Icon(
                            themeController.darkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            key: ValueKey(themeController.darkTheme),
                            color: themeController.darkTheme ? AsinDesign.gold : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
