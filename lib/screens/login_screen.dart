import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../providers/auth_provider.dart';
import '../services/validation_service.dart';
import 'register_screen.dart';
import '../screens/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / judul
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                        ),
                        child: const Icon(
                          Icons.watch,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    const Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.title,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk untuk mengelola jam tangan Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.caption,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXl),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final result = ValidationService.validateEmail(v);
                        return result.isValid ? null : result.error;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingMd),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (v) {
                        final result = ValidationService.validatePassword(v);
                        return result.isValid ? null : result.error;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    // Tombol Masuk
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppConstants.btnLogin),
                    ),
                    const SizedBox(height: AppSizes.spacingMd),
                    // Link ke Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: AppSizes.caption,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            AppConstants.btnRegister,
                            style: TextStyle(
                              fontSize: AppSizes.caption,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Info akun demo
                    const SizedBox(height: AppSizes.spacingLg),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Akun demo:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Admin: admin@chronostore.id / admin123\nPelanggan: pelanggan@chronostore.id / pelanggan123',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
