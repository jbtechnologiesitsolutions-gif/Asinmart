import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool showResetIcon;
  final Widget? reset;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.showActionButton = true,
    this.fontSize,
    this.showResetIcon = false,
    this.reset,
    this.showLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AsinDesign.foreground(context);
    return AppBar(
      backgroundColor: AsinDesign.card(context),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      titleSpacing: isBackButtonExist ? 0 : Dimensions.paddingSizeDefault,
      leadingWidth: isBackButtonExist ? 48 : (showLogo ? 126 : 8),
      leading: isBackButtonExist
          ? IconButton(
              onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.maybePop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : showLogo
              ? Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: 12, bottom: 12),
                  child: Image.asset(Images.logoWithNameImage, fit: BoxFit.contain, alignment: Alignment.centerLeft),
                )
              : const SizedBox.shrink(),
      title: Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textBold.copyWith(
          fontSize: fontSize ?? 20,
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: showResetIcon && reset != null
          ? [Padding(padding: const EdgeInsets.only(right: 8), child: reset!)]
          : const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AsinDesign.line(context)),
      ),
    );
  }

  @override
  Size get preferredSize => Size(MediaQuery.of(Get.context!).size.width, 61);
}
