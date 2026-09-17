import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

/// Flipkart-style category browser: a compact parent-category rail on the left
/// and a clean sub-category grid on the right. All routing and data still come
/// from the existing category APIs/controllers.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const Color _green = Color(0xFF063D39);
  static const Color _gold = Color(0xFFF5B82E);
  static const Color _page = Color(0xFFF7F8F6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCategory());
  }

  Future<void> _initializeCategory() async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    if (categoryController.categoryList.isEmpty) {
      await categoryController.getCategoryList(false);
    }
    if (!mounted || categoryController.categoryList.isEmpty) return;

    categoryController.onChangeSelectedIndex(0, isUpdate: false);
    await Provider.of<ProductController>(context, listen: false).initBrandOrCategoryProductList(
      isBrand: false,
      id: categoryController.categoryList.first.id,
      offset: 1,
      isUpdate: false,
    );
  }

  Future<void> _selectParent(int index, CategoryController controller) async {
    controller.onChangeSelectedIndex(index);
    await Provider.of<ProductController>(context, listen: false).initBrandOrCategoryProductList(
      isBrand: false,
      id: controller.categoryList[index].id,
      offset: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: CustomAppBar(title: getTranslated('CATEGORY', context)),
      body: Consumer<CategoryController>(
        builder: (context, categoryController, _) {
          if (categoryController.categoryList.isEmpty || categoryController.categorySelectedIndex == null) {
            return const Center(child: CircularProgressIndicator(color: _green));
          }

          final selectedIndex = categoryController.categorySelectedIndex!.clamp(0, categoryController.categoryList.length - 1).toInt();
          final selectedCategory = categoryController.categoryList[selectedIndex];
          final subCategories = selectedCategory.subCategories ?? <SubCategory>[];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 94,
                height: double.infinity,
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categoryController.categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryController.categoryList[index];
                    final selected = selectedIndex == index;
                    return InkWell(
                      onTap: () => _selectParent(index, categoryController),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFEAF4F1) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(color: selected ? _gold : Colors.transparent, width: 3),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAF9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? _green.withValues(alpha: .25) : const Color(0xFFE5E9E7)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: CustomImageWidget(image: '${category.imageFullUrl?.path}', fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              category.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: (selected ? textBold : textMedium).copyWith(
                                color: selected ? _green : const Color(0xFF343A3A),
                                fontSize: 9.5,
                                height: 1.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedCategory.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textBold.copyWith(color: const Color(0xFF202624), fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () => RouterHelper.getBrandCategoryRoute(
                              action: RouteAction.push,
                              isBrand: false,
                              id: selectedCategory.id,
                              name: selectedCategory.name,
                              categoryModel: selectedCategory,
                              isAllProduct: true,
                            ),
                            child: Text('View all', style: textBold.copyWith(color: _green, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: subCategories.isEmpty
                          ? _EmptySubCategory(category: selectedCategory)
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
                              physics: const BouncingScrollPhysics(),
                              itemCount: subCategories.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 9,
                                crossAxisSpacing: 9,
                                childAspectRatio: .82,
                              ),
                              itemBuilder: (context, index) {
                                final sub = subCategories[index];
                                return InkWell(
                                  onTap: () => RouterHelper.getBrandCategoryRoute(
                                    action: RouteAction.push,
                                    isBrand: false,
                                    id: sub.id,
                                    name: sub.name ?? selectedCategory.name,
                                    categoryModel: selectedCategory,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE4E8E6)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F7F5),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(Icons.category_outlined, color: _green, size: 27),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          sub.name ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: textMedium.copyWith(color: const Color(0xFF303735), fontSize: 10.5, height: 1.12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptySubCategory extends StatelessWidget {
  final CategoryModel category;
  const _EmptySubCategory({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => RouterHelper.getBrandCategoryRoute(
          action: RouteAction.push,
          isBrand: false,
          id: category.id,
          name: category.name,
          categoryModel: category,
          isAllProduct: true,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3E8E6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.grid_view_rounded, color: Color(0xFF063D39), size: 34),
              const SizedBox(height: 8),
              Text('View all ${category.name ?? 'products'}', textAlign: TextAlign.center, style: textBold.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
