import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/login.dart';
import 'package:todo/task_format.dart';
import 'package:todo/login_format.dart';
import 'package:todo/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData myTheme = ThemeData(
        cardColor: const Color.fromARGB(255, 28, 28, 28),
        canvasColor: Colors.black,
        primaryColor: const Color.fromARGB(255, 127, 127, 127),
        primaryColorLight: Colors.white,
        focusColor: const Color.fromARGB(255, 137, 99, 242));

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ToDo App',
          theme: myTheme,
          //darkTheme: ThemeData(colorScheme: ColorScheme.dark()),
          home: const MainLoginControl()),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Task> todoList = [];
  int remaining = 0;
  User user = Home.user!;

  MyAppState() {
    onStart();
  }

  void onStart() async {
    todoList = await user.userTasks.readAllTasks();
    remaining = await user.userTasks.getRecordCount();
    notifyListeners();
  }

  void add(String task) async {
    var t1 = Task(status: false, task: task);
    var newTask = await user.userTasks.create(t1);
    remaining++;
    todoList.add(newTask);

    notifyListeners();
  }

  bool getStatus(Task task) {
    return task.status;
  }

  void changeStatus(Task task, bool value) async {
    task = Task(index: task.index, status: value, task: task.task);
    user.userTasks.update(task);
    if (value) {
      remaining--;
    } else {
      remaining++;
    }

    todoList = await user.userTasks.readAllTasks();
    //todoList[task.index] = (index: task.index, status: value, task: task.task);
    notifyListeners();
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  static User? user;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var page;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var txtStyle = theme.textTheme.displaySmall!
        .copyWith(fontFamily: 'Raleway', color: theme.primaryColorLight);

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200,
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.canvasColor,
                  toolbarHeight: 100.0,
                  flexibleSpace: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 250,
                        child: FlexibleSpaceBar(
                          centerTitle: false,
                          title: Text("ToDo", style: txtStyle),
                          titlePadding: const EdgeInsets.all(20),
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: AddTodo(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: IconButton(
                            iconSize: 40,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Profile()),
                                  (route) => false);
                            },
                            icon: const Icon(
                              Icons.person,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                )
              ];
            },
            body: Container(
                decoration: BoxDecoration(color: theme.canvasColor),
                child: const TabBarView(
                  children: [ToDoPage(), Completed()],
                )),
          ),
          bottomNavigationBar: PreferredSize(
              preferredSize: _tabBar.preferredSize,
              child: Material(color: theme.canvasColor, child: _tabBar))),
    );
  }

  TabBar get _tabBar {
    var theme = Theme.of(context);
    return TabBar(
        indicatorColor: theme.primaryColorLight,
        labelColor: theme.primaryColorLight,
        unselectedLabelColor: theme.primaryColor,
        onTap: (value) => {
              setState(() {
                if (value == 0) {
                  page = const ToDoPage();
                } else {
                  page = const Completed();
                }
              })
            },
        tabs: const <Widget>[
          Tab(icon: Icon(Icons.checklist), text: "ToDo"),
          Tab(icon: Icon(Icons.done), text: "Completed")
        ]);
  }
}

class ToDoPage extends StatelessWidget {
  const ToDoPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var remaining = appState.remaining;
    if (remaining == 0) {
      return Center(
          child: Text("Nothing\n  ToDo",
              style: theme.textTheme.displaySmall!
                  .copyWith(fontFamily: 'Raleway', color: theme.primaryColor)));
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: ListView(
            padding: const EdgeInsets.all(10),
            physics: const BouncingScrollPhysics(),
            children: [
              for (var task in appState.todoList)
                if (!task.status) createCard(task, context)
            ],
          ),
        ),
      ],
    );
  }

  Widget createCard(Task task, BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var cardStyle = theme.cardColor;
    var txtStyle = theme.textTheme.bodyLarge!
        .copyWith(fontFamily: 'Raleway', color: theme.colorScheme.onBackground);

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardStyle,
        elevation: 5.0,
        margin: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(task.task, style: txtStyle),
            ),
            Stack(children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    value: appState.getStatus((task)),
                    onChanged: (bool? value) {
                      appState.changeStatus(task, value!);
                    },
                    checkColor: Colors.white,
                    activeColor: theme.focusColor,
                  )),
            ])
          ]),
        ));
  }
}

class Completed extends StatelessWidget {
  const Completed({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return ListView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        children: [
          for (var task in appState.todoList)
            if (task.status) const ToDoPage().createCard(task, context)
        ]);
  }
}

class AddTodo extends StatelessWidget {
  const AddTodo({super.key});

  @override
  Widget build(BuildContext context) {
    String task = "";
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    var txtStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);
    return IconButton(
      icon: const Icon(Icons.add),
      iconSize: 40,
      color: theme.primaryColorLight,
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
            backgroundColor: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(children: [
                    Center(
                      heightFactor: 2,
                      child: Text(
                        "Create ToDo",
                        style: txtStyle,
                      ),
                    ),
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close,
                              size: 20, color: theme.primaryColorLight),
                          onPressed: () => Navigator.pop(context),
                        ))
                  ]),
                  TextField(
                      style: TextStyle(color: theme.primaryColorLight),
                      cursorColor: theme.focusColor,
                      textCapitalization: TextCapitalization.sentences,
                      contextMenuBuilder: contextMenu,
                      maxLines: null,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          appState.add(value);
                          Navigator.pop(context);
                        }
                      },
                      onChanged: (value) {
                        task = value;
                      },
                      decoration: InputDecoration(
                        isDense: false,
                        hintText: "Example: Start Flutter app",
                        hintStyle: TextStyle(color: theme.primaryColor),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.focusColor)),
                      )),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.focusColor,
                      ),
                      onPressed: () {
                        if (task.isNotEmpty) {
                          appState.add(task);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"))
                ],
              ),
            )),
      ),
    );
  }

  Widget contextMenu(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar(
        anchors: editableTextState.contextMenuAnchors,
        children: editableTextState.contextMenuButtonItems
            .map((ContextMenuButtonItem buttonItem) {
          return CupertinoButton(
            borderRadius: null,
            color: const Color.fromARGB(255, 47, 47, 47),
            padding: const EdgeInsets.all(8),
            onPressed: buttonItem.onPressed,
            pressedOpacity: 0.5,
            child: SizedBox(
              width: 40,
              child: Text(
                CupertinoTextSelectionToolbarButton.getButtonLabel(
                    context, buttonItem),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
        }).toList());
  }
}
