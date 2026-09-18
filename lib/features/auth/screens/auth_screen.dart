import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/modern_motion_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/sign_up_widget.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget{
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  final String? referCode;
  const AuthScreen({super.key, this.fromLogout = false, this.fromPage, this.onLoginSuccess, this.referCode});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
  }
  bool scrolled = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if(didPop) return;
        if(widget.referCode != null) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
        } else {
          Navigator.pop(context);
        }
      },

      child: Scaffold(
        backgroundColor: AsinDesign.canvas(context),
        body: SafeArea(
          child: Consumer<AuthController>(
            builder: (context, authProvider, _) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      if (widget.referCode != null)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AsinDesign.foreground(context)),
                            onPressed: () => RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil),
                          ),
                        )
                      else
                        const SizedBox(height: 8),
                      Expanded(
                        child: ModernFadeSlide(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Image.asset(Images.logoWithNameImage, width: 132, height: 44, fit: BoxFit.contain),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Create Account',
                                  style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 26, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Join AsinMart for a faster and more personal shopping experience.',
                                  style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 14, height: 1.35),
                                ),
                                const SizedBox(height: 20),
                                SignUpWidget(
                                  fromLogout: widget.fromLogout,
                                  fromPage: widget.fromPage,
                                  onLoginSuccess: widget.onLoginSuccess,
                                  referCode: widget.referCode,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

