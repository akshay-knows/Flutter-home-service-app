import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: _iconSize,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  double get _iconSize {
    final shortestSide = [width, height].whereType<double>().fold<double?>(
          null,
          (min, value) => min == null || value < min ? value : min,
        );
    return shortestSide == null ? 24 : shortestSide.clamp(18, 36).toDouble();
  }
}
