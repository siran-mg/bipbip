import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/utils/form_validators.dart';

/// Account information step for registration
class AccountInfoStep extends StatefulWidget {
  /// Form key for validation
  final GlobalKey<FormState> formKey;
  
  /// Controller for email field
  final TextEditingController emailController;
  
  /// Controller for password field
  final TextEditingController passwordController;
  
  /// Controller for confirm password field
  final TextEditingController confirmPasswordController;

  /// Creates a new AccountInfoStep
  const AccountInfoStep({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<AccountInfoStep> createState() => _AccountInfoStepState();
}

class _AccountInfoStepState extends State<AccountInfoStep> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Entrez votre adresse email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: widget.passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: FormValidators.validatePassword,
          ),
          
          const SizedBox(height: 16),
          
          // Confirm password field
          TextFormField(
            controller: widget.confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              hintText: 'Confirmez votre mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isConfirmPasswordVisible,
            validator: (value) => FormValidators.validateConfirmPassword(
              value, 
              widget.passwordController.text,
            ),
          ),
        ],
      ),
    );
  }
}
