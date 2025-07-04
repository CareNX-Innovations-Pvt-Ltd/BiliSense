import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/presentation/login/login_cubit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool signUp = false;

  @override
  Widget build(BuildContext context) {
    // _emailController.text = 'pranav@carenx.com';
    // _passwordController.text = '1234567890';
    // _confirmPasswordController.text = '1234567890';
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
              if (state is LoginSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Welcome ${state.email}')),
                );
                context.goNamed(AppRoutes.mainNav);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/splash.png', height: 350),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                    Visibility(
                      visible: signUp,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Enter Name",
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    state is LoginLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            final name = _nameController.text.trim();
                            signUp
                                ? context.read<LoginCubit>().register(
                                  email,
                                  password,
                              name

                                )
                                : context.read<LoginCubit>().login(
                                  email,
                                  password,
                                );
                          },
                          child: signUp ? Text("Sign Up") : Text("Login"),
                        ),
                    Text.rich(
                      TextSpan(
                        text: signUp ? "Already have an account? ": "Don't have an account? " ,
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text:signUp ? "Login" : "Sign Up",
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      signUp = !signUp;
                                    });
                                  },
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
