import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

class PaymentAmount extends StatelessWidget {
  const PaymentAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${AppConstants.proMonthlyPrice} FCFA',
            style: AppTextStyles.h1.copyWith(fontSize: 48),
          ),
          Text(AppConstants.eachMonth, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
