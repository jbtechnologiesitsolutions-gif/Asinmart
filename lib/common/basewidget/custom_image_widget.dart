import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;

  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder = Images.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFit = fit ?? BoxFit.cover;
    return CachedNetworkImage(
      imageUrl: image,
      fit: effectiveFit,
      height: height,
      width: width,
      fadeInDuration: const Duration(milliseconds: 260),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholderFadeInDuration: const Duration(milliseconds: 120),
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF172320)
            : const Color(0xFFF2F5F3),
        alignment: Alignment.center,
        child: Image.asset(
          placeholder ?? Images.placeholder,
          height: height,
          width: width,
          fit: effectiveFit,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF172320)
            : const Color(0xFFF2F5F3),
        alignment: Alignment.center,
        child: Image.asset(
          placeholder ?? Images.placeholder,
          height: height,
          width: width,
          fit: effectiveFit,
        ),
      ),
    );
  }
}
