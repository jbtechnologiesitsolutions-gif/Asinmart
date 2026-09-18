import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatefulWidget {
  final String? hintText;
  final String? slug;
  const SearchWidget({super.key, required this.hintText, this.slug});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, SellerProductController controller) {
    if (searchController.text.trim().isEmpty) {
      showCustomSnackBarWidget(
        getTranslated('enter_somethings', context),
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    controller.getSellerProductList(
      widget.slug.toString(),
      1,
      '',
      search: searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SellerProductController>(context, listen: false);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _focusNode.hasFocus
                ? Theme.of(context).primaryColor.withValues(alpha: .65)
                : Theme.of(context).dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .13 : .035),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, size: 21, color: Theme.of(context).hintColor),
            const SizedBox(width: 8),
            Expanded(
              child: Focus(
                onFocusChange: (_) => setState(() {}),
                child: TextFormField(
                  controller: searchController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  maxLines: 1,
                  onFieldSubmitted: (_) => _submit(context, controller),
                  onChanged: (_) => setState(() {}),
                  style: textRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    isDense: true,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintStyle: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIconConstraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              searchController.clear();
                              controller.getSellerProductList(widget.slug.toString(), 1, '');
                              setState(() {});
                            },
                            icon: Icon(Icons.close_rounded, size: 18, color: Theme.of(context).hintColor),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: const Color(0xFFF5B82E),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _submit(context, controller),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF063D39), size: 21),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
