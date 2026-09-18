import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/number_checker_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/email_checker_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/enums/from_page.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController? _userInputController;
  String? _countryCode;

  final GlobalKey<ScaffoldMessengerState> _key = GlobalKey();

  final GlobalKey<FormState> forgetFormKey = GlobalKey<FormState>();

  final ConfigModel config = Provider.of<SplashController>(Get.context!, listen: false).configModel!;

  @override
  void initState() {
    _userInputController = TextEditingController();
    final AuthController authProvider = Provider.of<AuthController>(context, listen: false);

    authProvider.clearVerificationMessage();
    authProvider.setIsLoading = false;
    authProvider.setIsPhoneVerificationButttonLoading = false;
    authProvider.toggleIsNumberLogin(value: false, isUpdate: false);
    _countryCode = CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel?.countryCode ?? 'IN').dialCode;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =  Provider.of<SplashController>(context, listen: false).configModel!;
    return Scaffold(
      key: _key,
      backgroundColor: AsinDesign.canvas(context),
      appBar: CustomAppBar(title: ''),
      body: Consumer<AuthController>(
        builder: (context, authProvider,_) {
          return Consumer<SplashController>(
            builder: (context, splashProvider, _) {
              return Form(
                key: forgetFormKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ListView(padding: const EdgeInsets.fromLTRB(24, 18, 24, 30), children: [

                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Image.asset(Images.logoWithNameImage, height: 44, width: 132, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(getTranslated('forget_password', context) ?? 'Forgot Password', style: textBold.copyWith(
                      fontSize: 27,
                      color: AsinDesign.foreground(context),
                      fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 8),
                  Text('Enter your registered email address or phone number to reset your password.', style: textRegular.copyWith(
                    color: AsinDesign.muted(context),
                    fontSize: 14,
                    height: 1.4,
                  )),
                 const SizedBox(height: 28),


                  Selector<AuthController, bool>(
                    selector: (context, authProvider) => authProvider.isNumberLogin,
                    builder: (_, isNumberLogin, ___) {
                      return CustomTextFieldWidget(
                        countryDialCode: isNumberLogin ? _countryCode : null,
                        showCodePicker: isNumberLogin,
                        onCountryChanged: (CountryCode value) {
                          _countryCode = value.dialCode;
                        },

                        onChanged: (String text){

                          final numberRegExp = RegExp(r'^[+-]?[0-9]+$');

                          if(text.isEmpty && authProvider.isNumberLogin){
                            authProvider.toggleIsNumberLogin();
                          }
                          if(text.startsWith(numberRegExp) && !authProvider.isNumberLogin){
                            authProvider.toggleIsNumberLogin();
                          }


                          final emailRegExp = RegExp(r'@');

                          if(text.contains(emailRegExp) && authProvider.isNumberLogin) {
                            authProvider.toggleIsNumberLogin();
                          }
                        },
                        hintText: '',
                        isShowBorder: true,
                        controller: _userInputController,
                        inputType: TextInputType.emailAddress,
                        labelText: getTranslated('email/phone', context) ?? 'Email / phone',
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.bannerPadding),

                  CustomButton(
                    isBuy: true,
                    isLoading: (authProvider.isLoading || authProvider.isForgotPasswordLoading),
                    buttonText: getTranslated('send', context),
                    onTap: () async {
                      if(forgetFormKey.currentState?.validate() ?? false) {
                        if(!(config.emailVerification ?? false) && !(config.phoneVerification ?? false) && config.customerVerification?.phone == 0 && config.customerVerification?.firebase == 0 && config.customerVerification?.email == 0) {
                          showCustomSnackBarWidget(getTranslated('forgot_password_configuration_is_not', context), context, snackBarType: SnackBarType.warning);
                        } else if (_userInputController!.text.trim().isEmpty) {
                          showCustomSnackBarWidget(getTranslated('enter_email_or_phone', context) ?? 'Enter your email or phone number', context, snackBarType: SnackBarType.warning);
                        } else {
                          String userInput = _userInputController!.text.trim();
                          final bool isNumber = NumberCheckerHelper.isNumber(userInput);

                          if (!isNumber && EmailCheckerHelper.isNotValid(userInput)) {
                            showCustomSnackBarWidget(
                              getTranslated('enter_valid_email_address', context) ?? 'Enter a valid email address',
                              context,
                              snackBarType: SnackBarType.warning,
                            );
                            return;
                          }

                          if (isNumber && !userInput.startsWith('+')) {
                            userInput = '${_countryCode ?? ''}$userInput';
                          }

                          ResponseModel? response = await authProvider.forgetPassword(
                            config: configModel,
                            phoneOrEmail: userInput,
                            type: isNumber ? 'phone' : 'email',
                          );
                          if(response != null && response.isSuccess) {
                            if(isNumber && !authProvider.sendToEmail) {
                              RouterHelper.getVerificationRoute(
                                userInput: userInput,
                                fromPage: FromPage.forgetPassword,
                                action: RouteAction.push,
                              );
                            } else {
                              if(context.mounted) {
                                showCustomSnackBarWidget(response.message, context, snackBarType: SnackBarType.success);
                              }
                            }
                          } else if(response != null && !response.isSuccess) {
                            if(context.mounted){
                              showCustomSnackBarWidget(response.message, context, snackBarType: SnackBarType.warning);
                            }
                          }

                        }
                      }
                    },
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Back to Sign In', style: textBold.copyWith(color: AsinDesign.gold, fontSize: 12.5)),
                    ),
                  ),
                ]),
                    ),
                  ),
              );
            }
          );
        }
      ),
    );
  }
}
