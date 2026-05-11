import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'loginPage.dart';
import 'widgets/custom_appbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password, 3: Success
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> sendOTP() async {
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    var result = await AuthService.sendOTP(email: emailController.text);

    setState(() {
      isLoading = false;
    });

    if (result['status']) {
      setState(() {
        _currentStep = 1;
        errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to your email')),
      );
    } else {
      setState(() {
        errorMessage = result['message'] ?? 'Failed to send OTP';
      });
    }
  }

  Future<void> performPasswordReset() async {
    if (otpController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter OTP';
      });
      return;
    }

    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter password';
      });
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (newPasswordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    var result = await AuthService.performPasswordReset(
      email: emailController.text,
      otp: otpController.text,
      newPassword: newPasswordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result['status']) {
      setState(() {
        _currentStep = 3;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = result['message'] ?? 'Failed to reset password';
      });
    }
  }

  void goBack() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reset Password',
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
        elevation: 0,
        onBackPressed: _currentStep == 0
            ? () => Navigator.pop(context)
            : (_currentStep < 3 ? goBack : null),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOTPStep();
      case 2:
        return _buildNewPasswordStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your email address and we\'ll send you an OTP to reset your password',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 40),
        Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
        SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Verify OTP',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'We\'ve sent a 6-digit code to ${emailController.text}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 40),
        Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        TextField(
          controller: otpController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: 'Enter 6-digit OTP',
            prefixIcon: Icon(Icons.lock),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
        SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _currentStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Verify OTP',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Create New Password',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your new password below',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 40),
        Text('New Password', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        TextField(
          controller: newPasswordController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: 'Enter new password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20),
        Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        TextField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: 'Confirm password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
        SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : performPasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.green,
              size: 60,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Password Reset Successful!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'Your password has been reset successfully. Please log in with your new password.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Back to Login',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
