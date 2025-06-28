import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Splash screen shown while checking authentication session
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchmentWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.primaryBrown.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.explore,
                size: 60,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 32),

            // App title
            Text(
              'Project Atlas',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Your Study Journey Continues...',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                color: AppColors.primaryBrown.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),

            Text(
              'Checking your session...',
              style: TextStyle(fontSize: 14, color: AppColors.fadeGray),
            ),
          ],
        ),
      ),
    );
  }
}
