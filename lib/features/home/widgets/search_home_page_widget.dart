import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SearchHomePageWidget extends StatelessWidget {
  const SearchHomePageWidget({super.key});

  static const Color _deepGreen = Color(0xFF0E3121);
  static const Color _softBorder = Color(0xFFE5E8E3);

  @override
  Widget build(BuildContext context) {
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(
        Dimensions.homePagePadding,
        8,
        Dimensions.homePagePadding,
        10,
      ),
      child: Container(
        height: 54,
        padding: EdgeInsetsDirectional.only(
          start: isLtr ? 16 : 12,
          end: isLtr ? 8 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _deepGreen, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                getTranslated('search_hint', context) ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textRegular.copyWith(
                  color: const Color(0xFF7C817D),
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _deepGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}
