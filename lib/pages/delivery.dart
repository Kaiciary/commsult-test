import 'dart:async';
import 'dart:convert';

import 'package:commsult_delivery/data/dataTest.dart';
import 'package:commsult_delivery/class/deliveryTimeCalc.dart';
import 'package:flutter/material.dart';
import 'package:commsult_delivery/pages/queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Delivery extends StatefulWidget {
  @override
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  String buttonText = 'Start Delivery';

  DataTest dataTest = DataTest();
  late Map<String, dynamic> jsonData;
  TimeWindowCalc timeWindowCalc = TimeWindowCalc();
  bool isButtonDisabled = false;
  int n = -1;

  Future<Map<String, dynamic>> getData() async {
    final jsonDatas = await getMapFromSharedPreferences();
    n=-1;
    if (jsonDatas.isEmpty) {
      jsonData = dataTest.getJsonData();
      jsonData = await timeWindowCalc.calc(jsonData);
      return jsonData;
    } else {
      jsonData = jsonDatas;
      jsonData = await timeWindowCalc.calc(jsonData);
      for (int i = 0; i < jsonData['delivery']['stops'].length; i++) {
        if (jsonData['delivery']['stops'][i]['disabled'] == 1) {
          n++;
        }
      }
      return jsonData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 66, 28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: getData(), // Call the async function to fetch data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Visibility(
                visible: snapshot.connectionState == ConnectionState.waiting,
                child:
                    const CircularProgressIndicator(), // Or any loading widget
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return DeliveryList(jsonData: jsonData, n : n);
            }
          }),
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
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            onPressed: () {
              if (jsonData['delivery']['stops'][0]['disabled'] == 1) {
                buttonText = "Submit Stop Order";
              } else {
                buttonText = 'Start Delivery';
              }
              int indexLength = jsonData['delivery']['stops'].length - 1;
              if (jsonData['delivery']['stops'][indexLength]['disabled'] == 1) {
                null;
              } else {
                saveMapToSharedPreferences(jsonData);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Queue()),
                );
              }
            },
            child: Text(
              buttonText,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ),
      ),
    );
  }
}

void saveMapToSharedPreferences(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(data);

  await prefs.setString('mapData', jsonString);
}

Future<Map<String, dynamic>> getMapFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('mapData');
  if (jsonString != null) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  } else {
    return {};
  }
}

class DeliveryList extends StatefulWidget {
  Map<String, dynamic> jsonData;
  int n = 0;

  DeliveryList({required this.jsonData, required this.n});
  final TimeWindowCalc timeWindowCalc = TimeWindowCalc();

  Future<Map<String, dynamic>> getData() async {
    jsonData = await timeWindowCalc.calc(jsonData);
    return jsonData;
  }

  @override
  _DeliveryListState createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  late Timer _everySec;
  String time = "";

  @override
  void initState() {
    super.initState();
    seccond();
    _everySec = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        seccond();
      });
    });
  }

  @override
  void dispose() {
    _everySec.cancel(); // Cancel your timer here
    super.dispose();
  }

  void seccond() {
    DateTime startingTime;
    DateTime plannedStartTime =
        DateTime.parse(widget.jsonData['delivery']['plannedStartTime']);
    DateTime systemTime = DateTime.now();

    if (systemTime.isBefore(plannedStartTime)) {
      startingTime = plannedStartTime;
    } else {
      startingTime = systemTime;
    }

    String hour = startingTime.hour.toString().padLeft(2, '0');
    String minute = startingTime.minute.toString().padLeft(2, '0');
    String sec = startingTime.second.toString().padLeft(2, '0');
    time = '$hour:$minute:$sec';

    widget.getData();
  }

  @override
  Widget build(BuildContext context) {
    final stops = widget.jsonData['delivery']['stops'];

    return Stack(
      children: [
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: Wrap(
              children: [
                Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 30)),
                    Flexible(
                      flex: 1,
                      child: Text(
                        widget.jsonData['delivery']['deliveryNumber'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(left: 80)),
                    Expanded(
                      child: Text(
                        "Current Time $time",
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(10)),
                const Text(
                  "drag & drop to change list",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 1500,
                  width: 500,
                  child: ReorderableListView.builder(
                    itemBuilder: (context, index) {
                      final element = stops[index];
                      if (element['disabled'] == 1) {
                        String dateTimeFinish = '${element['stopEndTime']}';
                        DateTime dateTimeF = DateTime.parse(dateTimeFinish);

                        String hourFinish =
                            dateTimeF.hour.toString().padLeft(2, '0');
                        String minuteFinish =
                            dateTimeF.minute.toString().padLeft(2, '0');

                        String finishTime = '$hourFinish:$minuteFinish';

                        return Dismissible(
                          key: Key(element['key']),
                          direction: DismissDirection.none,
                          child: Padding(
                            key: Key(element['key']),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${element['name']}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '${element['address']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Finish Time $finishTime',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) {
                            // Disable the dismiss action
                          },
                        );
                      } else {
                        String dateTimeStart = '${element['timeWindowSubs']}';
                        DateTime dateTimeS = DateTime.parse(dateTimeStart);

                        String hourStart =
                            dateTimeS.hour.toString().padLeft(2, '0');
                        String minuteStart =
                            dateTimeS.minute.toString().padLeft(2, '0');

                        String startTime = '$hourStart:$minuteStart';

                        String dateTimeEnd = '${element['timeWindowPlus']}';
                        DateTime dateTimeE = DateTime.parse(dateTimeEnd);

                        String hourEnd =
                            dateTimeE.hour.toString().padLeft(2, '0');
                        String minuteEnd =
                            dateTimeE.minute.toString().padLeft(2, '0');

                        String endTime = '$hourEnd:$minuteEnd';

                        return Padding(
                          key: Key(element['key']),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${element['name']}'),
                                  Text(
                                    '${element['address']}',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                              Text(
                                '$startTime - $endTime',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemCount: stops.length,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex > widget.n && newIndex > widget.n) {
                          // Ensure the item is not moved
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final stop = stops.removeAt(oldIndex);
                          stops.insert(newIndex, stop);
                          widget.getData();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
