import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: AppColors.laranja, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(Icons.pets_rounded,
                size: size * 0.52, color: AppColors.creme),
          ),
          Positioned(
            right: -size * 0.04,
            top: -size * 0.04,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: AppColors.amarelo,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.creme, width: size * 0.04),
              ),
              child: Icon(Icons.favorite_rounded,
                  size: size * 0.2, color: AppColors.cinza),
            ),
          ),
        ],
      ),
    );
  }
}
