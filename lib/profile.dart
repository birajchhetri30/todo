import 'package:flutter/material.dart';
import 'package:todo/main.dart';
import 'package:todo/login_format.dart';
import 'package:todo/login.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    User user = Home.user!;

    var theme = Theme.of(context);
    var textStyle = theme.textTheme.headlineMedium!
        .copyWith(fontFamily: 'Raleway', color: theme.primaryColorLight);
    var buttonTextStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);
    var errorButtonText =
        theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onError);

    var isEnabled = true;

    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 250,
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.canvasColor,
                  toolbarHeight: 100.0,
                  flexibleSpace: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 300,
                          child: FlexibleSpaceBar(
                            centerTitle: false,
                            title:
                                Text("Hello, ${user.fname}", style: textStyle),
                            titlePadding: const EdgeInsets.all(20),
                          )),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: IconButton(
                            onPressed: () {
                              showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return createAlertDialog(
                                      context: context,
                                      content: null,
                                      mainButtonColor: theme.focusColor,
                                      mainButtonText: "Sign out",
                                      mainButtonOnPressed: () {
                                        Phoenix.rebirth(context);
                                      },
                                    );
                                  });
                            },
                            tooltip: "Sign out",
                            iconSize: 30,
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                )
              ];
            },
            body: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        createTextField(context, "First Name", user.fname, "",
                            (value) => null, isEnabled, 170),
                        createTextField(context, "Last Name", user.lname, "",
                            (value) => null, isEnabled, 170)
                      ],
                    ),
                    const SizedBox(height: 20),
                    createTextField(context, "Email", user.email, "",
                        (value) => null, isEnabled),
                    const SizedBox(height: 20),
                    createTextField(context, "Password", user.password, "",
                        (value) => null, isEnabled),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.focusColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(300, 50),
                      ),
                      child: Text("Save changes", style: buttonTextStyle),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                        onPressed: () {
                          showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return createAlertDialog(
                                    context: context,
                                    content: Text(
                                        'If you delete your account, all your tasks will be lost.',
                                        style: TextStyle(
                                            color: theme.primaryColorLight)),
                                    mainButtonColor: theme.colorScheme.error,
                                    mainButtonText: "Delete",
                                    mainButtonOnPressed: () {
                                      //user.delete();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Login()),
                                          (route) => false);
                                    });
                              });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            fixedSize: const Size.fromHeight(40)),
                        child: Text("Delete account", style: errorButtonText))
                  ],
                ),
              ),
            )));
  }

  Widget createAlertDialog({
    required BuildContext context,
    Widget? content,
    required Color mainButtonColor,
    required String mainButtonText,
    required void Function() mainButtonOnPressed,
  }) {
    var theme = Theme.of(context);

    return AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Are you sure?',
            style: TextStyle(color: theme.primaryColorLight)),
        content: content,
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: mainButtonColor),
            onPressed: mainButtonOnPressed,
            child: Text(mainButtonText,
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.onError)),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: theme.focusColor)))
        ]);
  }

  Widget createTextField(BuildContext context, String label, String text,
      String hint, Function(String) onChanged, bool isEnabled,
      [double width = 300]) {
    var theme = Theme.of(context);
    var hintStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColor);
    var textStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);
    var isPassword = label == "Password" ? true : false;
    var isName = label == "First name" || label == "Last name" ? true : false;
    var isEmail = label == "Email" ? true : false;

    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: text,
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
            enabled: isEnabled,
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
