// ignore_for_file: prefer_const_constructors

import 'package:effektio/common/store/separatedThemes.dart';
import 'package:effektio/common/widget/OnboardingWidget.dart';
import 'package:effektio/screens/OnboardingScreens/LogIn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:effektio/common/store/AppConstants.dart';
import 'package:themed/themed.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreentate createState() => _SignupScreentate();
}

class _SignupScreentate extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    lastNameController.dispose();
    firstNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: SvgPicture.asset('assets/images/logo.svg'),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Lets get Started',
                style: AuthTheme.authTitleStyle,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Create an account to explore',
                style: AuthTheme.authbodyStyle,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppCommonTheme.textFieldColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 10.0,
                              top: 12,
                              right: 10,
                            ),
                            border: InputBorder.none,
                            hintText:
                                'First Name', // pass the hint text parameter here
                            hintStyle:
                                TextStyle(color: AuthTheme.hintTextColor),
                          ),
                          style: TextStyle(color: AuthTheme.textFieldTextColor),
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter First Name' : null,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppCommonTheme.textFieldColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 10.0,
                              top: 12,
                              right: 10,
                            ),
                            border: InputBorder.none,
                            hintText:
                                'Last name', // pass the hint text parameter here
                            hintStyle:
                                TextStyle(color: AuthTheme.hintTextColor),
                          ),
                          style: TextStyle(color: AuthTheme.textFieldTextColor),
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter Last Name' : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                height: 60,
                decoration: BoxDecoration(
                  color: AppCommonTheme.textFieldColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 10.0, top: 12, right: 10),
                    border: InputBorder.none,
                    hintText:
                        'Email Address', // pass the hint text parameter here
                    hintStyle: TextStyle(color: AuthTheme.hintTextColor),
                  ),
                  style: TextStyle(color: AuthTheme.textFieldTextColor),
                  validator: (value) => ValidConstants.isEmail(value!)
                      ? null
                      : 'Please enter vaild email',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: AuthTheme.authbodyStyle,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'By clicking to sign up you agree to our ',
                      ),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            debugPrint('Terms of Service"');
                          },
                        text: 'Terms and Condition',
                        style: AuthTheme.authbodyStyle +
                            AppCommonTheme.primaryColor,
                      ),
                      TextSpan(text: ' and that you have read our '),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            debugPrint('policy"');
                          },
                        text: 'Privacy Policy',
                        style: AuthTheme.authbodyStyle +
                            AppCommonTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              CustomOnbaordingButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {}
                },
                title: 'Sign up',
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account ?  ',
                    style: AuthTheme.authbodyStyle,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign in ',
                      style: AuthTheme.authbodyStyle +
                          AppCommonTheme.primaryColor,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
