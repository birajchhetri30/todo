import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:todo/login.dart';
import 'package:todo/task_format.dart';
import 'package:todo/login_format.dart';
import 'package:todo/profile.dart';

void main() {
  runApp(Phoenix(child: const MyApp()));
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
    debugPrint("Remaining: $remaining");
    notifyListeners();
  }

  void add(String task) async {
    var t1 = Task(status: false, task: task);
    var newTask = await user.userTasks.create(t1);
    remaining = await user.userTasks.getRecordCount();

    todoList.add(newTask);

    notifyListeners();
  }

  void edit(String oldTask, String newTask) async {
    for (Task each in todoList) {
      if (each.task == oldTask) {
        debugPrint("Edited ${each.task} to $newTask");
        Task updatedTask =
            Task(index: each.index, status: false, task: newTask);
        await user.userTasks.update(updatedTask);
        break;
      }
    }
    todoList = await user.userTasks.readAllTasks();
    notifyListeners();
  }

  bool getStatus(Task task) {
    return task.status;
  }

  void changeStatus(Task task, bool value) async {
    task = Task(index: task.index, status: value, task: task.task);

    await user.userTasks.update(task);

    remaining = await user.userTasks.getRecordCount();
    todoList = await user.userTasks.readAllTasks();
    notifyListeners();
  }

  void deleteAllCompleted() async {
    await user.userTasks.deleteAllCompleted();
    todoList = await user.userTasks.readAllTasks();

    notifyListeners();
  }

  void deleteTask(Task task) async {
    await user.userTasks.deleteTask(task);
    todoList = await user.userTasks.readAllTasks();
    remaining = await user.userTasks.getRecordCount();

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
                            splashRadius: 25,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Profile()));
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
                if (!task.status)
                  ResuableWidgets().createCard(task, context, true)
            ],
          ),
        ),
      ],
    );
  }
}

class Completed extends StatelessWidget {
  const Completed({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Stack(children: [
      ListView(
          padding: const EdgeInsets.all(10),
          physics: const BouncingScrollPhysics(),
          children: [
            for (var task in appState.todoList)
              if (task.status)
                ResuableWidgets().createCard(task, context, false)
          ]),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FloatingActionButton(
              backgroundColor: theme.colorScheme.error,
              onPressed: () {
                appState.deleteAllCompleted();
              },
              child: Icon(Icons.delete, color: theme.colorScheme.onError)),
        ),
      )
    ]);
  }
}

class AddTodo extends StatelessWidget {
  const AddTodo({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return IconButton(
      icon: const Icon(Icons.add),
      splashRadius: 25,
      iconSize: 40,
      color: theme.primaryColorLight,
      onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return ResuableWidgets().createDialog(context,
                cardTitle: "Create ToDo",
                buttonText: "Add",
                task: "",
                onPressed: "OnCreate");
          }),
    );
  }
}

class ResuableWidgets {
  Widget createCard(Task task, BuildContext context, bool editable) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var cardStyle = theme.cardColor;
    var txtStyle = theme.textTheme.bodyLarge!
        .copyWith(fontFamily: 'Raleway', color: theme.colorScheme.onBackground);

    return GestureDetector(
      onTap: () {
        if (editable) {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return createDialog(context,
                    cardTitle: "Edit ToDo",
                    buttonText: "Done",
                    initialValue: task.task,
                    task: task.task,
                    onPressed: "OnEdit");
              });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardStyle,
        elevation: 5.0,
        margin: const EdgeInsets.all(10.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(task.task, style: txtStyle),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    appState.deleteTask(task);
                  },
                  splashRadius: 15,
                  icon: Icon(
                    Icons.close,
                    color: theme.primaryColor,
                  ),
                  iconSize: 20,
                ),
                Checkbox(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  value: appState.getStatus((task)),
                  onChanged: (value) {
                    appState.changeStatus(task, value!);
                  },
                  checkColor: Colors.white,
                  activeColor: theme.focusColor,
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget createDialog(
    BuildContext context, {
    required String cardTitle,
    required String buttonText,
    String? initialValue,
    String task = "",
    required String onPressed,
  }) {
    //var appState = context.watch<MyAppState>();
    var appState = Provider.of<MyAppState>(context, listen: false);
    var theme = Theme.of(context);
    var txtStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorLight);

    return Dialog(
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
                    cardTitle,
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
              TextFormField(
                  initialValue: initialValue,
                  style: TextStyle(color: theme.primaryColorLight),
                  cursorColor: theme.focusColor,
                  textCapitalization: TextCapitalization.sentences,
                  contextMenuBuilder: contextMenu,
                  maxLines: null,
                  onChanged: (value) {
                    task = value;
                  },
                  decoration: InputDecoration(
                    isDense: false,
                    hintText: (initialValue == null)
                        ? "Example: Start Flutter app"
                        : null,
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
                    if (onPressed == "OnCreate") {
                      if (task.isNotEmpty) {
                        appState.add(task);
                      }
                    } else if (onPressed == "OnEdit") {
                      if (task.isNotEmpty) {
                        appState.edit(initialValue!, task);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text(buttonText))
            ],
          ),
        ));
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
