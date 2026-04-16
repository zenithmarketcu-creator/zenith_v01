// lib/src/presentation/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  const LoadingWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        color: Colors.white,
      ),
    );
  }
}
