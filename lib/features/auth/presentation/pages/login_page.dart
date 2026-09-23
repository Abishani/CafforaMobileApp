import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_scope.dart';
import '../widgets/login_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.initialCreateAccount = false});

  final bool initialCreateAccount;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isCreateAccount;

  @override
  void initState() {
    super.initState();
    _isCreateAccount = widget.initialCreateAccount;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final auth = AuthScope.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isCreateAccount) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your name'),
            duration: Duration(milliseconds: 1200),
          ),
        );
        return;
      }
      final error = await auth.signUp(
        name: name,
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(milliseconds: 1200),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/profile');
    } else {
      final error = await auth.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(milliseconds: 1200),
          ),
        );
        return;
      }
      Navigator.of(context)
          .pushReplacementNamed(auth.isAdmin ? '/admin' : '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.ink),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  LoginBrand(
                    title: _isCreateAccount ? 'Create account' : 'Welcome back',
                    subtitle: _isCreateAccount
                        ? 'Join Caffora and start ordering today.'
                        : 'Sign in to continue your Caffora experience.',
                  ),
                  const SizedBox(height: 32),
                  if (_isCreateAccount) ...[
                    LoginField(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 18),
                  ],
                  LoginField(
                    label: 'Email address',
                    hint: 'you@example.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 18),
                  LoginField(
                    label: 'Password',
                    hint: _isCreateAccount
                        ? 'Create a password'
                        : 'Enter your password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  if (!_isCreateAccount) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: palette.accentDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else
                    const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(_isCreateAccount ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: palette.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: palette.border)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SocialLoginButton(
                    label: 'Continue with Google',
                    icon: const GoogleIcon(),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    label: 'Continue with Apple',
                    icon: Icon(
                      Icons.apple,
                      size: 18,
                      color: palette.ink,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isCreateAccount
                            ? 'Already have an account?'
                            : "Don't have an account?",
                        style: TextStyle(color: palette.body, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isCreateAccount = !_isCreateAccount;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isCreateAccount ? 'Sign in' : 'Create account',
                          style: TextStyle(
                            color: palette.accentDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'By continuing, you agree to Caffora\'s Terms & Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.muted,
                      fontSize: 11,
                      height: 16 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
