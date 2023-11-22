import 'package:flutter/material.dart';
import 'package:todo/main.dart';
import 'package:todo/login_format.dart';

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

    var isEnabled = true;

    return Scaffold(
        body: NestedScrollView(
            physics: BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
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
                              isEnabled = true;
                            },
                            iconSize: 30,
                            icon: const Icon(
                              Icons.edit,
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
                      //crossAxisAlignment: CrossAxisAlignment.end,
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.focusColor,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        fixedSize: const Size(300, 50),
                      ),
                      child: Text("Save changes", style: buttonTextStyle),
                    ),
                  ],
                ),
              ),
            )));
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
