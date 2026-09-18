import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/modern_motion_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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

  int _columns(double width) {
    if (width >= 1100) return 5;
    if (width >= 760) return 4;
    if (width >= 520) return 3;
    return 2;
  }

  void _openCategory(dynamic category) {
    RouterHelper.getBrandCategoryRoute(
      action: RouteAction.push,
      isBrand: false,
      id: category.id,
      name: category.name,
      categoryModel: category,
      isAllProduct: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsinDesign.canvas(context),
      appBar: CustomAppBar(
        title: getTranslated('CATEGORY', context) ?? 'Categories',
        isBackButtonExist: false,
        showResetIcon: true,
        reset: IconButton(
          tooltip: 'Search',
          onPressed: () => RouterHelper.getSearchRoute(action: RouteAction.push),
          icon: Icon(Icons.search_rounded, color: AsinDesign.foreground(context), size: 24),
        ),
      ),
      body: Consumer<CategoryController>(
        builder: (context, controller, _) {
          if (controller.categoryList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AsinDesign.primary));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final count = _columns(constraints.maxWidth);
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: controller.categoryList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: count == 2 ? .94 : .88,
                ),
                itemBuilder: (context, index) {
                  final category = controller.categoryList[index];
                  return ModernFadeSlide(
                    delay: Duration(milliseconds: (index.clamp(0, 10) * 28).toInt()),
                    child: ModernPressable(
                      onTap: () => _openCategory(category),
                      borderRadius: BorderRadius.circular(AsinDesign.radiusLg),
                      child: Container(
                        decoration: AsinDesign.cardDecoration(context, radius: AsinDesign.radiusLg),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                color: AsinDesign.softCard(context),
                                child: CustomImageWidget(
                                  image: '${category.imageFullUrl?.path ?? ''}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textBold.copyWith(
                                      color: AsinDesign.foreground(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${category.totalProductCount ?? 0} items',
                                    style: textRegular.copyWith(color: AsinDesign.muted(context), fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
