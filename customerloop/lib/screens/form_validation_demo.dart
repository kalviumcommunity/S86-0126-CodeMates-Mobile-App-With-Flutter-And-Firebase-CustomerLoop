import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormValidationDemo extends StatefulWidget {
  const FormValidationDemo({super.key});

  @override
  State<FormValidationDemo> createState() => _FormValidationDemoState();
}

class _FormValidationDemoState extends State<FormValidationDemo> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isFormValid = false;
  bool _autoValidate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  // Validators
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Enter a valid number';
    }
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    if (age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid website URL';
    }
    return null;
  }

  void _checkFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  void _submitForm() {
    setState(() {
      _autoValidate = true;
    });

    if (_formKey.currentState!.validate()) {
      // Form is valid - show success
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Success! ✅'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Form submitted successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Name: ${_nameController.text}'),
                  Text('Email: ${_emailController.text}'),
                  Text('Phone: ${_phoneController.text}'),
                  Text('Age: ${_ageController.text}'),
                  if (_websiteController.text.isNotEmpty)
                    Text('Website: ${_websiteController.text}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _resetForm();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before submitting'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _ageController.clear();
    _websiteController.clear();
    setState(() {
      _isFormValid = false;
      _autoValidate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Validation Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode:
              _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
          onChanged: _checkFormValidity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Colors.blue[50],
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill out all fields with valid data to enable the submit button',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'example@domain.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '1234567890',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age *',
                  hintText: 'Must be 18 or older',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: _validateAge,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'At least 8 characters',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
                validator: _validatePassword,
                onChanged: (_) {
                  // Revalidate confirm password when password changes
                  if (_confirmPasswordController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 8),
              // Password Requirements
              const _PasswordRequirements(),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_confirmPasswordVisible,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 16),

              // Website Field (Optional)
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website (Optional)',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: _validateWebsite,
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isFormValid ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Submit Form'),
              ),
              const SizedBox(height: 12),

              // Reset Button
              OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Reset Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          _RequirementItem(text: '• At least 8 characters'),
          _RequirementItem(text: '• One uppercase letter (A-Z)'),
          _RequirementItem(text: '• One number (0-9)'),
          _RequirementItem(text: '• One special character (!@#\$%^&*)'),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;

  const _RequirementItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600]));
  }
}
