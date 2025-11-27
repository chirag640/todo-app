import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _codeSent = false;
  bool _codeVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual send code logic with backend
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent to ${_emailController.text}'),
          backgroundColor: AppColors.completed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  void _verifyCode() {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual verification logic with backend
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _codeVerified = true;
      });
    });
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // TODO: Implement actual password reset logic with backend
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset successfully! Please login.'),
            backgroundColor: AppColors.completed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header with rounded bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _codeSent
                                  ? _codeVerified
                                      ? 'Enter your new password'
                                      : 'Enter the verification code'
                                  : 'We\'ll send you a code',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                    ],
                  ),
                ),
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Email Field (always visible)
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.7.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_codeSent,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            fontSize: 12.sp,
                          ),
                          filled: true,
                          fillColor: _codeSent
                              ? AppColors.background
                              : AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),

                      if (_codeSent && !_codeVerified) ...[
                        SizedBox(height: 2.5.h),

                        // Verification Code Field
                        Text(
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.7.h),
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit code',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),

                        // SizedBox(height: 0.7.h),

                        // Resend Code
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _sendCode,
                            child: Text(
                              'Resend Code',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (_codeVerified) ...[
                        SizedBox(height: 2.h),

                        // New Password Field
                        Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.7.h),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: !_isPasswordVisible,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter new password',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: AppColors.iconSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.error,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.error,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.5.h),

                        // Confirm Password Field
                        Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.7.h),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          validator: _validateConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Confirm new password',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: AppColors.iconSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.error,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.error,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 4.h),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 6.5.h,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _codeVerified
                                  ? _resetPassword
                                  : _codeSent
                                      ? _verifyCode
                                      : _sendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                            disabledBackgroundColor:
                                AppColors.primary.withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 5.w,
                                  height: 5.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _codeVerified
                                      ? 'Reset Password'
                                      : _codeSent
                                          ? 'Verify Code'
                                          : 'Send Code',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
