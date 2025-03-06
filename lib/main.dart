import 'package:caching/register.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(231, 238, 253, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPasswordCtrl = TextEditingController();

  void signIn() {
    String email = "abc@gmail.com";
    String password = "123456";

    String enteredEmail = _loginEmailCtrl.text;
    String enteredPassword = _loginPasswordCtrl.text;

    void showAlert(String status, String desc) {
      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(status),
          content: Text(desc),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (enteredEmail == email) {
      showAlert("Login Success", "Welcome to Cachingg");
    } else {
      showAlert("Login Unsuccessful", "Incorrect Credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //title: Text(widget.title),
      //),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          color: Color.fromRGBO(255, 242, 192, 1),
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
                    thickness: 3,
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
                    controller: _loginEmailCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Enter Address"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _loginPasswordCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: signIn,
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Color.fromRGBO(236, 157, 171, 1)),
                              foregroundColor: WidgetStateProperty.all(
                                  Color.fromRGBO(0, 0, 0, 1))),
                          child: Text("Sign In",
                              style: TextStyle(fontWeight: FontWeight.w900))),
                      SizedBox(
                        width: 80,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Color.fromRGBO(236, 157, 171, 1)),
                              foregroundColor: WidgetStateProperty.all(
                                  Color.fromRGBO(0, 0, 0, 1))),
                          child: Text("Register",
                              style: TextStyle(fontWeight: FontWeight.w900)))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }
}
