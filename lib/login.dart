import 'package:flutter/material.dart';
import 'package:todo/main.dart';
import 'package:todo/login_format.dart';
import 'package:todo/user_database.dart';

class MainLoginControl extends StatelessWidget {
  const MainLoginControl({super.key});

  @override
  Widget build(BuildContext context) {
    return const Login();
  }
}

class LoginControl {
  Future<(User?, bool)> addUser(User? user) async {
    bool success = false;
    (user, success) = await UserDatabase.instance.create(user!);
    return (user, success);
    //notifyListeners();
  }

  Future<(User?, bool)> loginUser(String email, String password) async {
    User? user;
    bool success = false;
    (user, success) = await UserDatabase.instance.validateUser(email, password);
    return (user, success);
    // throw Exception('Incorrect email/password');
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: loginPage(context));
  }

  Widget loginPage(BuildContext context) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.displayMedium!
        .copyWith(fontFamily: 'Raleway', color: theme.primaryColorLight);
    var hintStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColor);
    var textStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);

    String email = "";
    String password = "";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Sign in", style: titleStyle),
          const SizedBox(height: 80),
          const SignUp().createTextField(context, "Email",
              "E.g. johndoe@gmail.com", (value) => {email = value}),
          const SizedBox(height: 20),
          const SignUp().createTextField(
              context, "Password", "", (value) => {password = value}),
          const SizedBox(height: 40),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.focusColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  fixedSize: const Size(300, 50)),
              onPressed: () async {
                debugPrint(email);
                debugPrint(password);
                User? user;
                bool success = false;
                (user, success) =
                    await LoginControl().loginUser(email, password);
                if (success) {
                  Home.user = user!;
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Home()),
                      (route) => false);
                }
              },
              child: Text("Login", style: textStyle)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Dont have an account?", style: hintStyle),
              TextButton(
                  style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      padding: const EdgeInsets.all(5)),
                  onPressed: () async {
                    await Navigator.push(context, _createRouteSignUp());
                  },
                  child: Text("Sign up here",
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.focusColor)))
            ],
          ),
        ],
      ),
    );
  }

  Route _createRouteSignUp() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignUp(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
              position: animation.drive(tween), child: child);
        });
  }
}

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true, body: signUpPage(context));
  }

  Widget signUpPage(BuildContext context) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.displayMedium!
        .copyWith(fontFamily: 'Raleway', color: theme.primaryColorLight);
    var hintStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColor);
    var textStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);

    String fname = "";
    String lname = "";
    String email = "";
    String password = "";

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Sign up", style: titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 80),
            createTextField(
                context, "First name", "E.g. John", (value) => {fname = value}),
            const SizedBox(height: 20),
            createTextField(
                context, "Last name", "E.g. Doe", (value) => {lname = value}),
            const SizedBox(height: 20),
            createTextField(context, "Email", "E.g. johndoe@gmail.com",
                (value) => {email = value}),
            const SizedBox(height: 20),
            createTextField(
                context, "Password", "", (value) => {password = value}),
            const SizedBox(height: 40),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.focusColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    fixedSize: const Size(300, 50)),
                onPressed: () async {
                  User? user = User(
                      fname: fname,
                      lname: lname,
                      email: email,
                      password: password);
                  bool success = false;
                  (user, success) = await LoginControl().addUser(user);
                  if (success) {
                    Home.user = user!;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Home()),
                        (route) => false);
                  }
                },
                child: Text("Create account", style: textStyle)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?", style: hintStyle),
                TextButton(
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        padding: const EdgeInsets.all(5)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Sign in",
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: theme.focusColor)))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget createTextField(BuildContext context, String label, String hint,
      Function(String) onChanged) {
    var theme = Theme.of(context);
    var hintStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColor);
    var textStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);
    var isPassword = label == "Password" ? true : false;
    var isName = label == "First name" || label == "Last name" ? true : false;
    var isEmail = label == "Email" ? true : false;

    return SizedBox(
      width: 300,
      child: TextFormField(
        textCapitalization:
            isName ? TextCapitalization.words : TextCapitalization.none,
        cursorColor: theme.focusColor,
        style: textStyle,
        onChanged: onChanged,
        obscureText: isPassword,
        enableSuggestions: isPassword,
        autocorrect: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : null,
        decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.focusColor, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            hintText: hint,
            hintStyle: hintStyle,
            labelText: label,
            labelStyle: textStyle),
      ),
    );
  }
}
