import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedRailIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = Provider.of<CategoryController>(context, listen: false);
      if (controller.categoryList.isEmpty) {
        await controller.getCategoryList(false);
      }
    });
  }

  IconData _categoryIcon(String name) {
    final value = name.toLowerCase();
    if (value.contains('fashion') || value.contains('cloth') || value.contains('wear')) return Icons.checkroom_outlined;
    if (value.contains('mobile') || value.contains('phone')) return Icons.phone_android_rounded;
    if (value.contains('electronic') || value.contains('laptop')) return Icons.laptop_mac_rounded;
    if (value.contains('beauty') || value.contains('cosmetic')) return Icons.face_retouching_natural_outlined;
    if (value.contains('kitchen')) return Icons.kitchen_outlined;
    if (value.contains('home') || value.contains('decor')) return Icons.chair_outlined;
    if (value.contains('access') || value.contains('watch')) return Icons.watch_outlined;
    if (value.contains('sport') || value.contains('fitness')) return Icons.sports_basketball_outlined;
    if (value.contains('kid') || value.contains('baby') || value.contains('toy')) return Icons.child_friendly_outlined;
    if (value.contains('book') || value.contains('station')) return Icons.menu_book_outlined;
    if (value.contains('food') || value.contains('health')) return Icons.health_and_safety_outlined;
    if (value.contains('furniture')) return Icons.weekend_outlined;
    if (value.contains('auto') || value.contains('car')) return Icons.directions_car_outlined;
    return Icons.category_outlined;
  }

  String _subCategoryImage(BuildContext context, String? icon) {
    final raw = icon?.trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.baseUrls
            ?.categoryImageUrl
            ?.trim() ??
        '';
    if (base.isEmpty) return raw;
    return '${base.replaceAll(RegExp(r'/+$'), '')}/${raw.replaceAll(RegExp(r'^/+'), '')}';
  }

  void _openParent(CategoryModel category) {
    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: category.id,
      name: category.name,
      categoryModel: category,
      isAllProduct: true,
    );
  }

  void _openSub(SubCategory subCategory) {
    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: subCategory.id,
      name: subCategory.name,
      subCategory: subCategory,
      isAllProduct: true,
    );
  }

  int _rightColumns(double width) {
    if (width >= 900) return 5;
    if (width >= 650) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AsinDesign.canvas(context),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AsinDesign.card(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Home',
          onPressed: () => RouterHelper.getDashboardRoute(
            action: RouteAction.pushReplacement,
            page: 'home',
          ),
          icon: Icon(Icons.arrow_back_rounded, color: AsinDesign.foreground(context)),
        ),
        titleSpacing: 0,
        title: Text(
          'All Categories',
          style: textBold.copyWith(
            color: AsinDesign.foreground(context),
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => RouterHelper.getSearchRoute(action: RouteAction.push),
            icon: Icon(Icons.search_rounded, color: AsinDesign.foreground(context), size: 27),
          ),
          Consumer<CartController>(
            builder: (context, cartController, _) {
              final count = cartController.cartList.length;
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: InkWell(
                  onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: AsinDesign.foreground(context), size: 26),
                        if (count > 0)
                          Positioned(
                            right: 1,
                            top: 0,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: AsinDesign.gold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: textBold.copyWith(color: const Color(0xFF17231F), fontSize: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AsinDesign.line(context)),
        ),
      ),
      body: Consumer<CategoryController>(
        builder: (context, controller, _) {
          if (controller.categoryList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AsinDesign.primary));
          }

          final categories = controller.categoryList;
          if (_selectedRailIndex > categories.length) {
            _selectedRailIndex = 0;
          }
          final CategoryModel? selectedCategory = _selectedRailIndex == 0
              ? null
              : categories[_selectedRailIndex - 1];
          final subCategories = selectedCategory?.subCategories ?? <SubCategory>[];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 86,
                child: Container(
                  color: dark ? const Color(0xFF151A19) : const Color(0xFFF7F8FA),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      final selected = _selectedRailIndex == index;
                      final title = index == 0 ? 'For You' : (categories[index - 1].name ?? '');
                      final icon = index == 0 ? Icons.auto_awesome_rounded : _categoryIcon(title);

                      return InkWell(
                        onTap: () => setState(() => _selectedRailIndex = index),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 102),
                          decoration: BoxDecoration(
                            color: selected ? AsinDesign.card(context) : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: selected ? AsinDesign.gold : Colors.transparent,
                                width: 4,
                              ),
                              bottom: BorderSide(color: AsinDesign.line(context)),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected ? AsinDesign.primarySoft : (dark ? const Color(0xFF202624) : const Color(0xFFEAF5F1)),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AsinDesign.line(context)),
                                ),
                                child: Icon(
                                  icon,
                                  size: 25,
                                  color: selected ? AsinDesign.primary : AsinDesign.muted(context),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: (selected ? textBold : textRegular).copyWith(
                                  color: selected ? AsinDesign.foreground(context) : AsinDesign.muted(context),
                                  fontSize: 9.5,
                                  height: 1.05,
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
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _rightColumns(constraints.maxWidth);
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 90),
                      children: [
                        if (selectedCategory != null && subCategories.isNotEmpty) ...[
                          Text(
                            selectedCategory.name ?? 'Categories',
                            style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subCategories.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: .82,
                            ),
                            itemBuilder: (context, index) {
                              final sub = subCategories[index];
                              final image = _subCategoryImage(context, sub.icon);
                              return _CategoryImageTile(
                                title: sub.name ?? '',
                                image: image,
                                fallbackIcon: _categoryIcon(sub.name ?? ''),
                                onTap: () => _openSub(sub),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                        ],
                        Text(
                          'Explore Categories',
                          style: textBold.copyWith(color: AsinDesign.foreground(context), fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 11,
                            crossAxisSpacing: 10,
                            childAspectRatio: .80,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _CategoryImageTile(
                              title: category.name ?? '',
                              image: category.imageFullUrl?.path?.trim() ?? '',
                              fallbackIcon: _categoryIcon(category.name ?? ''),
                              onTap: () => _openParent(category),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryImageTile extends StatelessWidget {
  final String title;
  final String image;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _CategoryImageTile({
    required this.title,
    required this.image,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AsinDesign.softCard(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AsinDesign.line(context)),
              ),
              clipBehavior: Clip.antiAlias,
              child: image.isEmpty
                  ? Icon(fallbackIcon, color: AsinDesign.muted(context), size: 34)
                  : CustomImageWidget(image: image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textBold.copyWith(
              color: AsinDesign.foreground(context),
              fontSize: 10.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
