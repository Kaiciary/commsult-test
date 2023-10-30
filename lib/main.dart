import 'package:commsult_delivery/pages/delivery.dart';
import 'package:flutter/material.dart';
import 'package:commsult_delivery/data/dataTest.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commsult Delivery',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.

        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Commsult Delivery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    //_requestWritePermission();
  }

  final TextEditingController _textDeliveryController = TextEditingController();
  DataTest dataTest = DataTest();
  late Map<String, dynamic> jsonData;
  String message = "";

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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: const Color.fromARGB(255, 235, 66, 28),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  children: [
                    const Center(
                      child: Text(
                        "Delivery Number",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      controller: _textDeliveryController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(
                                width: 1,
                                color: Color.fromARGB(255, 145, 145, 145)),
                          ),
                          hintText: 'Ex. A91JK0S7',
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 149, 149, 149),
                              fontSize: 14,
                              fontWeight: FontWeight.w300)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Center(
                      child: Text(
                        message,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 129, 129, 129)),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 90,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                const Color.fromARGB(255, 235, 66, 28),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(9), // Adjust the radius as needed
                ),
              ),
            ),
            onPressed: () {
              String text = _textDeliveryController.text;
              jsonData = dataTest.getJsonData();
              if (text == jsonData['delivery']['deliveryNumber']) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Delivery()),
                );
              } else {
                setState(() {
                  message = "Invalid Delivery Number";
                });
              }
            },
            child: const Text(
              'SEARCH DELIVERY',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ),
      ),
    );
  }
}
