import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceHomeHeader extends StatelessWidget {
  const MarketplaceHomeHeader({super.key});

  static const Color _deepGreen = Color(0xFF063D39);
  static const Color _gold = Color(0xFFF5B82E);

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();

    return Container(
      color: _deepGreen,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    Images.logoWithNameImageWhite,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              _MarketplaceHeaderAction(
                icon: Icons.search_rounded,
                label: 'Search',
                onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
              ),
              const SizedBox(width: 12),
              _MarketplaceHeaderAction(
                icon: Icons.account_circle_outlined,
                label: 'Account',
                onTap: () {
                  if (loggedIn) {
                    RouterHelper.getProfileScreen1Route(action: RouteAction.push);
                  } else {
                    RouterHelper.getLoginRoute(action: RouteAction.push);
                  }
                },
              ),
              const SizedBox(width: 12),
              _MarketplaceHeaderAction(
                icon: Icons.menu_rounded,
                label: 'Menu',
                onTap: () => _showMarketplaceMenu(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Search for products, brands and more...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(color: const Color(0xFF9AA2A0), fontSize: 13),
                    ),
                  ),
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Color(0xFFE9ECEB))),
                    ),
                    child: const Icon(Icons.mic_none_rounded, color: _deepGreen, size: 21),
                  ),
                  Container(
                    width: 53,
                    height: double.infinity,
                    alignment: Alignment.center,
                    color: _gold,
                    child: const Icon(Icons.search_rounded, color: _deepGreen, size: 25),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceHeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MarketplaceHeaderAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 46,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            const SizedBox(height: 2),
            Text(label, style: textBold.copyWith(color: Colors.white, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

void _showMarketplaceMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _MarketplaceMenuSheet(),
  );
}

class _MarketplaceMenuSheet extends StatelessWidget {
  const _MarketplaceMenuSheet();

  static const Color _deepGreen = Color(0xFF063D39);
  static const Color _gold = Color(0xFFF5B82E);
  static const Color _border = Color(0xFFE4E9E7);

  void _closeAndRun(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    Future<void>.delayed(const Duration(milliseconds: 120), action);
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();

    return FractionallySizedBox(
      heightFactor: .96,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Center(
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFF2F6F5), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: _deepGreen, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _closeAndRun(context, () => RouterHelper.getSearchRoute(action: RouteAction.push)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Search for items...', style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF9AA09D))),
                    ),
                    Container(width: 46, height: double.infinity, alignment: Alignment.center, color: _gold, child: const Icon(Icons.search_rounded, color: _deepGreen, size: 22)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _MarketplaceMenuTile(title: 'Home', onTap: () => _closeAndRun(context, () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home'))),
            _MarketplaceMenuTile(title: 'Categories', highlighted: true, onTap: () => _closeAndRun(context, () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'category'))),
            _MarketplaceMenuTile(title: 'Cart', onTap: () => _closeAndRun(context, () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'cart'))),
            _MarketplaceMenuTile(title: 'Orders', onTap: () => _closeAndRun(context, () => RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'orders'))),
            _MarketplaceMenuTile(title: 'Stores', onTap: () => _closeAndRun(context, () => RouterHelper.getAllTopSellerRoute(action: RouteAction.push, title: 'Stores'))),
            _MarketplaceMenuTile(title: 'Brands', onTap: () => _closeAndRun(context, () => RouterHelper.getBrandViewRoute(action: RouteAction.push))),
            _MarketplaceMenuTile(
              title: 'Become a Vendor',
              onTap: () => _closeAndRun(context, () async {
                final Uri uri = Uri.parse('${AppConstants.baseUrl}/vendor/auth/registration/index');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text('Theme mode', style: textRegular.copyWith(color: const Color(0xFF313936), fontSize: Dimensions.fontSizeDefault)),
                  const Spacer(),
                  Consumer<ThemeController>(
                    builder: (context, themeController, _) {
                      return Row(
                        children: [
                          _ThemeModeButton(icon: Icons.light_mode_outlined, selected: !themeController.darkTheme, onTap: themeController.darkTheme ? themeController.toggleTheme : null),
                          const SizedBox(width: 8),
                          _ThemeModeButton(icon: Icons.dark_mode_outlined, selected: themeController.darkTheme, onTap: !themeController.darkTheme ? themeController.toggleTheme : null),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deepGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
                onPressed: () => _closeAndRun(context, () {
                  if (loggedIn) {
                    RouterHelper.getProfileScreen1Route(action: RouteAction.push);
                  } else {
                    RouterHelper.getLoginRoute(action: RouteAction.push, fromPage: RouterHelper.dashboardScreen);
                  }
                }),
                child: Text(loggedIn ? 'My Account' : 'Login/Register', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceMenuTile extends StatelessWidget {
  final String title;
  final bool highlighted;
  final VoidCallback onTap;

  const _MarketplaceMenuTile({required this.title, required this.onTap, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFFEAF4F1) : Colors.white,
            border: Border.all(color: const Color(0xFFE4E9E7)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: textBold.copyWith(color: highlighted ? const Color(0xFF063D39) : const Color(0xFF202927), fontSize: Dimensions.fontSizeDefault),
          ),
        ),
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _ThemeModeButton({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: selected ? const Color(0xFFDCEBE7) : const Color(0xFFF6F8F7), shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: const Color(0xFF26312F)),
      ),
    );
  }
}

class HomeQuickCategoryStrip extends StatefulWidget {
  const HomeQuickCategoryStrip({super.key});

  @override
  State<HomeQuickCategoryStrip> createState() => _HomeQuickCategoryStripState();
}

class _HomeQuickCategoryStripState extends State<HomeQuickCategoryStrip> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryController, _) {
        final categories = categoryController.categoryList;
        if (categories.isEmpty) return const SizedBox(height: 92);

        final visible = categories.length > 12 ? categories.take(12).toList() : categories;

        return Container(
          height: 94,
          color: const Color(0xFFFFFCF2),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: visible.length + 1,
            itemBuilder: (context, index) {
              final bool selected = _selectedIndex == index;
              final category = index == 0 ? null : visible[index - 1];
              return InkWell(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  if (category != null) {
                    RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: category.id,
                      name: category.name,
                    );
                  }
                },
                child: Container(
                  width: 78,
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected ? const Color(0xFF1E2426) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 41,
                        height: 41,
                        child: index == 0
                            ? const Icon(Icons.storefront_rounded, color: Color(0xFF202426), size: 34)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: CustomImageWidget(
                                  image: '${category?.imageFullUrl?.path}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        index == 0 ? 'All' : (category?.name ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: (selected ? textBold : textMedium).copyWith(
                          color: const Color(0xFF25292B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
