import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class OrderTypeButton extends StatelessWidget {
  final String? text;
  final int index;

  const OrderTypeButton({super.key, required this.text, required this.index});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<OrderController>(
        builder: (context, orderController,_) {
          return TextButton(onPressed: () => orderController.setIndex(index),
            style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
            child: Container(height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: orderController.orderTypeIndex == index ? AsinDesign.primary : AsinDesign.card(context),
                border: Border.all(color: orderController.orderTypeIndex == index ? AsinDesign.primary : AsinDesign.line(context)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    text!,
                    style: titilliumBold.copyWith(
                      color: orderController.orderTypeIndex == index ? Colors.white : AsinDesign.foreground(context),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}