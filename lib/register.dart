import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _registerEmailCtrl = TextEditingController();
  final TextEditingController _registerPasswordCtrl = TextEditingController();
  final TextEditingController _registerNameCtrl = TextEditingController();
  final TextEditingController _registerPhoneNumberCtrl =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordCtrl =
      TextEditingController();

  void register() {
    String registerEmail = _registerEmailCtrl.text;
    String registerPassword = _registerPasswordCtrl.text;

    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Register successful"),
        content: Text("Proceed to login"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Color.fromRGBO(255, 242, 192, 1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset("assets/images/logo.png")),
                  Text(
                    "Welcome to\nCachingg",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 48),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Divider(
                    height: 8.0,
                    thickness: 2,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Sign In",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 48),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  TextField(
                    controller: _registerEmailCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Enter Address"),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _registerPasswordCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _registerConfirmPasswordCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Confirm Password"),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _registerPhoneNumberCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Phone Number"),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _registerNameCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Name"),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  ElevatedButton(
                      onPressed: register,
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Color.fromRGBO(236, 157, 171, 1)),
                          foregroundColor: WidgetStateProperty.all(
                              Color.fromRGBO(0, 0, 0, 1))),
                      child: Text("Register",
                          style: TextStyle(fontWeight: FontWeight.w900)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
