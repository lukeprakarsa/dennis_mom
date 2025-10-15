import 'package:flutter/material.dart';

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({
    super.key,
    required this.imageUrl,
    this.width = 50,
    this.height = 50,
    this.fit = BoxFit.cover,
    this.backgroundColor,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? '').trim();

    // If empty, render a transparent box (no error)
    if (url.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    // Otherwise try to load the image and fall back to transparent if it fails
    return Container(
      width: width,
      height: height,
      color: backgroundColor, // optional neutral bg if you want
      child: Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stack) {
          // If the URL fails to load, render transparent
          return SizedBox(width: width, height: height);
        },
      ),
    );
  }
}