import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Reusable loading indicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.message,
  });

  final double? size;
  final Color? color;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 8.h,
            height: size ?? 8.h,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 2.h),
            Text(
              message!,
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ],
      ),
    );
  }
}
