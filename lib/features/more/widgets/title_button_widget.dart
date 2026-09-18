import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class MenuButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final bool isNotification;
  final bool isProfile;
  final Function? onTap;

  const MenuButtonWidget({
    super.key,
    required this.image,
    required this.title,
    this.navigateTo,
    this.isNotification = false,
    this.isProfile = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    Widget trailing = Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor, size: 20);

    if (isNotification && Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      trailing = Consumer<NotificationController>(
        builder: (context, controller, _) {
          final count = controller.notificationModel?.newNotificationItem ?? 0;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: count > 0
                ? Container(
                    key: ValueKey(count),
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AsinDesign.gold,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: textBold.copyWith(color: AsinDesign.primary, fontSize: 10),
                    ),
                  )
                : Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor, size: 20),
          );
        },
      );
    } else if (isProfile) {
      trailing = Consumer<ProfileController>(
        builder: (context, profileProvider, _) {
          final count = profileProvider.userInfoModel?.referCount ?? 0;
          return Container(
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: dark ? .22 : .10),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text('$count', style: textBold.copyWith(color: primary, fontSize: 10)),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AsinDesign.radius),
          onTap: onTap != null ? () => onTap!() : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: dark ? .18 : .075),
                    borderRadius: BorderRadius.circular(AsinDesign.radius),
                  ),
                  child: CustomAssetImageWidget(
                    image,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    color: dark ? const Color(0xFF84CFC3) : primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
