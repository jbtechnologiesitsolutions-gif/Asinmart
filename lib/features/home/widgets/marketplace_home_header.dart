import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
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
  static const Color _greenDark = Color(0xFF03352F);
  static const Color _gold = Color(0xFFF5B82E);
  static const Color _mint = Color(0xFFEAF5F1);

  String _deliveryText(AddressController controller) {
    if (controller.addressList?.isNotEmpty ?? false) {
      final address = controller.addressList!.first;
      final city = (address.city ?? '').trim();
      if (city.isNotEmpty) return city;
      final state = (address.state ?? '').trim();
      if (state.isNotEmpty) return state;
      final line = (address.address ?? '').trim();
      if (line.isNotEmpty) return line;
    }
    return 'Add address';
  }

  Widget _badgeIcon({
    required IconData icon,
    required int count,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _deepGreen, width: 1.2),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: textBold.copyWith(color: badgeColor == _gold ? _greenDark : Colors.white, fontSize: 7.5, height: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final addressController = context.watch<AddressController>();
    final notificationController = context.watch<NotificationController>();
    final cartController = context.watch<CartController>();
    final profileController = context.watch<ProfileController>();

    final bool loggedIn = authController.isLoggedIn();
    final String deliveryText = _deliveryText(addressController);
    final int notificationCount = notificationController.notificationModel?.notification?.length ?? 0;
    final int cartCount = cartController.cartList.length;
    final String profileImage = profileController.userInfoModel?.imageFullUrl?.path?.trim() ?? '';

    return Material(
      color: _deepGreen,
      child: Column(
        children: [
          Container(
            color: _deepGreen,
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      Images.logoWithNameImageWhite,
                      height: 31,
                      width: 92,
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () => RouterHelper.getAddressListScreen(action: RouteAction.push),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, color: _gold, size: 16),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('DELIVER TO', style: textBold.copyWith(color: Colors.white70, fontSize: 7, height: 1)),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            deliveryText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textBold.copyWith(color: Colors.white, fontSize: 9.5, height: 1),
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 13),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _badgeIcon(
                      icon: Icons.notifications_none_rounded,
                      count: notificationCount,
                      badgeColor: const Color(0xFFE63A3A),
                      onTap: () => RouterHelper.getNotificationRoute(action: RouteAction.push),
                    ),
                    const SizedBox(width: 2),
                    _badgeIcon(
                      icon: Icons.shopping_cart_outlined,
                      count: cartCount,
                      badgeColor: _gold,
                      onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => loggedIn
                          ? RouterHelper.getProfileScreen1Route(action: RouteAction.push)
                          : RouterHelper.getLoginRoute(action: RouteAction.push),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _gold, width: 1.2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: loggedIn && profileImage.isNotEmpty && profileImage != 'null'
                            ? CustomImageWidget(image: profileImage, fit: BoxFit.cover)
                            : const Icon(Icons.person_rounded, color: _deepGreen, size: 21),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.search_rounded, color: Color(0xFF6B7C78), size: 18),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Search products, brands and more...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(color: const Color(0xFF8E9996), fontSize: 11),
                          ),
                        ),
                        Container(
                          width: 34,
                          alignment: Alignment.center,
                          child: const Icon(Icons.mic_none_rounded, color: _deepGreen, size: 18),
                        ),
                        Container(
                          width: 43,
                          height: double.infinity,
                          alignment: Alignment.center,
                          color: _gold,
                          child: const Icon(Icons.arrow_forward_rounded, color: _deepGreen, size: 21),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => RouterHelper.getAddressListScreen(action: RouteAction.push),
            child: Container(
              height: 32,
              color: _mint,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 15, color: _deepGreen),
                  const SizedBox(width: 4),
                  Text('Deliver to ', style: textMedium.copyWith(color: _deepGreen, fontSize: 9)),
                  Expanded(
                    child: Text(
                      deliveryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(color: _deepGreen, fontSize: 9),
                    ),
                  ),
                  Text('INDIA', style: textBold.copyWith(color: _deepGreen, fontSize: 8.5)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: _deepGreen, size: 14),
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
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetSurface = dark ? const Color(0xFF151A19) : Colors.white;
    final Color softSurface = dark ? const Color(0xFF202624) : const Color(0xFFF8FAF9);
    final Color borderColor = dark ? Colors.white12 : _border;
    final Color primaryText = dark ? const Color(0xFFF2F5F4) : const Color(0xFF313936);

    return FractionallySizedBox(
      heightFactor: .96,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
        decoration: BoxDecoration(
          color: sheetSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                  decoration: BoxDecoration(color: softSurface, shape: BoxShape.circle),
                  child: Icon(Icons.close_rounded, color: dark ? Colors.white : _deepGreen, size: 24),
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
                  color: softSurface,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Search for items...', style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: dark ? Colors.white54 : const Color(0xFF9AA09D))),
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
                  Text('Theme mode', style: textRegular.copyWith(color: primaryText, fontSize: Dimensions.fontSizeDefault)),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: highlighted
                ? (dark ? const Color(0xFF153C36) : const Color(0xFFEAF4F1))
                : (dark ? const Color(0xFF202624) : Colors.white),
            border: Border.all(color: dark ? Colors.white12 : const Color(0xFFE4E9E7)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: textBold.copyWith(
              color: highlighted
                  ? (dark ? const Color(0xFFF5B82E) : const Color(0xFF063D39))
                  : (dark ? Colors.white : const Color(0xFF202927)),
              fontSize: Dimensions.fontSizeDefault,
            ),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected
              ? (dark ? const Color(0xFF315A52) : const Color(0xFFDCEBE7))
              : (dark ? const Color(0xFF202624) : const Color(0xFFF6F8F7)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: dark ? Colors.white : const Color(0xFF26312F)),
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
  IconData _fallbackIcon(String name) {
    final value = name.toLowerCase();
    if (value.contains('fashion') || value.contains('cloth')) return Icons.shopping_bag_outlined;
    if (value.contains('mobile') || value.contains('phone')) return Icons.phone_android_outlined;
    if (value.contains('electronic')) return Icons.laptop_mac_outlined;
    if (value.contains('beauty') || value.contains('cosmetic')) return Icons.face_retouching_natural_outlined;
    if (value.contains('kitchen')) return Icons.kitchen_outlined;
    if (value.contains('home')) return Icons.chair_outlined;
    if (value.contains('access')) return Icons.watch_outlined;
    if (value.contains('sport')) return Icons.sports_basketball_outlined;
    if (value.contains('kid') || value.contains('baby')) return Icons.child_friendly_outlined;
    return Icons.grid_view_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF111715) : Colors.white;
    final circleSurface = dark ? const Color(0xFF22302C) : const Color(0xFFF1F8F6);
    final border = dark ? Colors.white12 : const Color(0xFFDCE8E5);
    final textColor = dark ? const Color(0xFFF1F5F3) : const Color(0xFF263530);

    return Consumer<CategoryController>(
      builder: (context, categoryController, _) {
        final categories = categoryController.categoryList;
        if (categories.isEmpty) return Container(height: 76, color: surface);
        final visible = categories.length > 16 ? categories.take(16).toList() : categories;

        return Container(
          height: 76,
          color: surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final category = visible[index];
              final imagePath = category.imageFullUrl?.path?.trim() ?? '';
              return InkWell(
                onTap: () => RouterHelper.getBrandCategoryRoute(
                  action: RouteAction.push,
                  isBrand: false,
                  id: category.id,
                  name: category.name,
                ),
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 65,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: circleSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePath.isNotEmpty && imagePath != 'null'
                            ? CustomImageWidget(image: imagePath, fit: BoxFit.cover)
                            : Icon(_fallbackIcon(category.name ?? ''), color: dark ? const Color(0xFFF5B82E) : const Color(0xFF063D39), size: 22),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textMedium.copyWith(color: textColor, fontSize: 8.5, height: 1),
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

