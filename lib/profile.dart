import 'package:flutter/material.dart';
import 'package:todo/main.dart';
import 'package:todo/login_format.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:todo/user_database.dart';

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

    String? newFname = Home.user?.fname;
    String? newLname = Home.user?.lname;
    String? newEmail = Home.user?.email;
    String? newPassword = Home.user?.password;
    bool changed = false; // to enable button if any textfield value changes
    bool emailChanged = false;

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
                    createTextField(context, "First Name", user.fname, "",
                        (value) {
                      newFname = value;
                      if (newFname != Home.user?.fname) {
                        changed = true;
                      }
                    }, isEnabled),
                    SizedBox(height: 20),
                    createTextField(context, "Last Name", user.lname, "",
                        (value) {
                      newLname = value;
                      if (newLname != Home.user?.lname) {
                        changed = true;
                      }
                    }, isEnabled),
                    const SizedBox(height: 20),
                    createTextField(context, "Email", user.email, "", (value) {
                      newEmail = value;
                      if (newEmail != Home.user?.email) {
                        changed = true;
                        emailChanged = true;
                      }
                    }, isEnabled),
                    const SizedBox(height: 20),
                    createTextField(context, "Password", user.password, "",
                        (value) {
                      newPassword = value;
                      if (newPassword != Home.user?.password) {
                        changed = true;
                      }
                    }, isEnabled),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        showDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return createAlertDialog(
                                  context: context,
                                  mainButtonColor: theme.focusColor,
                                  mainButtonText: "Proceed",
                                  mainButtonOnPressed: () async {
                                    bool success = await changeUserDetails(
                                        id: user.id,
                                        fname: newFname,
                                        lname: newLname,
                                        email: newEmail,
                                        password: newPassword,
                                        emailChanged: emailChanged);

                                    if (success) {
                                      Phoenix.rebirth(context);
                                    } else {
                                      // ADD validator here
                                    }
                                  },
                                  content: Text(
                                      "You will be logged out if you want to save changes.",
                                      style: TextStyle(
                                          color: theme.primaryColorLight)));
                            });
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
                    const SizedBox(height: 25),
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
                                      user.deleteUser();
                                      Phoenix.rebirth(context);
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

  Future<bool> changeUserDetails(
      {int? id,
      String? fname,
      String? lname,
      String? email,
      String? password,
      bool? emailChanged}) async {
    User user = User(
        id: id!,
        fname: fname!,
        lname: lname!,
        email: email!,
        password: password!);

    if (emailChanged!) {
      int idExists = await UserDatabase.instance.conditionalUpdate(user);
      if (idExists == -1) {
        return false;
      }
      return true;
    }

    await UserDatabase.instance.update(user);
    return true;
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
