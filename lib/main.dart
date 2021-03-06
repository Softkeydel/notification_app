import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    // fetchProducts();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Notification app'),
    );
  }
}

sendNotification(String token, String msg) async {

  final response = await http.post('https://fcm.googleapis.com/fcm/send',
      body: json.encode({
        "to": token,
        "notification": {
          "title": 'You have a new message',
          "body": msg,
        }
  }),
      headers: { 'Content-type': 'application/json',
        "Authorization": "key=AAAAdWtohHE:APA91bG_E6HVrQcpJbr03RlKHWDe-3jSjQhp5bfPjFkyzdKNkOZB3JiEi6hkRzHkQwuhrzW6W2H1WAmJrp1sLqHnwUxXQ2Z_ir5-Y0ZoHODiTL-ks-BAO__w7L-ztorCqOys0-agOb-Pw8oM215rLzdwrxWY7tqN-Q"
  });
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseMessaging messaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  final textEditingController = TextEditingController();
  String msg;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var androidSettings = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = new InitializationSettings(android: androidSettings, iOS: IOSInitializationSettings());
    localNotifications.initialize(initializationSettings);

    messaging.configure(
        onMessage: (message) async {
          print(message);
          showNotification(message['notification']['title'], message['notification']['body']);
          setState(() {
            msg = message["notification"]["body"];
          });
        }
    );
  }

  void showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high);

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    await localNotifications.show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      textEditingController.dispose();
      super.dispose();
    }


    void onClick() {
      FirebaseMessaging().getToken().then((token) {
        if (!textEditingController.text.isEmpty) {
          sendNotification(token, textEditingController.text);
        }
      });
    }

    @override
    Widget build(BuildContext context) {
      // This method is rerun every time setState is called, for instance as done
      // by the _incrementCounter method above.
      //
      // The Flutter framework has been optimized to make rerunning build methods
      // fast, so that you can just rebuild anything that needs updating rather
      // than having to individually change instances of widgets.
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    hintText: 'Enter your message',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  controller: textEditingController,
                ),
              ),
              Text(
                msg == null ? '' : 'You have a new message',
              ),
              Text(msg == null ? '' : '$msg',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onClick,
          tooltip: 'Click',
          child: Icon(Icons.send),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
  }
