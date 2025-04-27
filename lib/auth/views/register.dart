import 'package:caching/auth/auth_service.dart';
import 'package:caching/auth/views/login.dart';
import 'package:flutter/material.dart';
import 'package:caching/utilities/design.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final design = Design();
  final TextEditingController registerEmailCtrl = TextEditingController();
  final TextEditingController registerPasswordCtrl = TextEditingController();
  final TextEditingController registerNameCtrl = TextEditingController();
  final TextEditingController registerPhoneCtrl = TextEditingController();

  void register() async {
    final _auth = AuthService();

    try {
      await _auth.signUpWithEmailPassword(registerEmailCtrl.text, registerPasswordCtrl.text, registerNameCtrl.text, registerPhoneCtrl.text);
      Navigator.pop(context);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Register",
                style: design.titleText,
              ),
              TextField(
                controller: registerNameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: registerEmailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                obscureText: true,
                controller: registerPasswordCtrl,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              TextField(
                controller: registerPhoneCtrl,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              ElevatedButton(onPressed: register, child: Text("Register"))
            ],
          ),
        ),
      ),
    );
  }
}
