import 'dart:async';
import 'dart:convert';
import 'package:commsult_delivery/pages/delivery.dart';
import 'package:commsult_delivery/class/finishTimeCalc.dart';
import 'package:flutter/material.dart';
import 'package:commsult_delivery/class/deliveryTimeCalc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Queue extends StatefulWidget {
  @override
  _Queue createState() => _Queue();
}

class _Queue extends State<Queue> {
  int n = 0;
  bool _visible = true;
  String _buttonText = "Reorder Stops";
  bool check = false;

  late Map<String, dynamic> jsonData;
  TimeWindowCalc timeWindowCalc = TimeWindowCalc();
  FinishTimeCalc finishTimeCalc = FinishTimeCalc();
/*
  @override
  void initState() {
    Data data = Data();
    listDeliverysTemp.addAll(data.getArray());

    listDeliverysTemp.forEach((listDeliverysTemps) {
      if (listDeliverysTemps.disabled == '1') {
        n++;
      }
    });

    super.initState();
  }*/

  Future<Map<String, dynamic>> getData() async {
    final jsonDatas = await getMapFromSharedPreferences();
    if (jsonDatas.isEmpty) {
      return {};
    } else {
      jsonData = jsonDatas;
      jsonData = await timeWindowCalc.calc(jsonData);
      //first time only
      if (!check) {
        for (int i = 0; i < jsonData['delivery']['stops'].length; i++) {
          if (jsonData['delivery']['stops'][i]['disabled'] == 1) {
            n++;
          }
        }
        check = true;
      }

      return jsonData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Delivery()),
          );
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 235, 66, 28),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Color.fromARGB(255, 255, 255, 255)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Delivery()),
                  );
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
                      visible:
                          snapshot.connectionState == ConnectionState.waiting,
                      child:
                          CircularProgressIndicator(), // Or any loading widget
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Container(
                        child: DeliveryQueue(jsonData: jsonData, n: n));
                  }
                }),
            bottomSheet: Container(
              width: MediaQuery.of(context).size.width,
              height: 130,
              color: Colors.white,
              child: Column(
                children: [
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _visible,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 235, 66, 28),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    9), // Adjust the radius as needed
                              ),
                            ),
                          ),
                          onPressed: () {
                            _finishStop();
                          },
                          child: const Text(
                            'Finish Current Stop',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 235, 66, 28),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  9), // Adjust the radius as needed
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (n == jsonData['delivery']['stops'].length - 1) {
                            _finishStop();
                          }

                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Delivery()),
                          );
                        },
                        child: Text(
                          _buttonText,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  void _finishStop() async {
    if (n >= 0 && n <= jsonData['delivery']['stops'].length) {
      if (n != -1) {
        setState(() {
          jsonData['delivery']['stops'][n]['disabled'] = 1;
        });
        jsonData = await finishTimeCalc.calcDelivery(jsonData);
      }
    } else {
      // Handle the case when the index is out of bounds
    }
    setState(() {
      n++;
      if (jsonData['delivery']['stops'].length <= n + 1) {
        _visible = false;
        _buttonText = "Finish Delivery";
      }
    });
    saveMapToSharedPreferences(jsonData);
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
}

class DeliveryQueue extends StatefulWidget {
  Map<String, dynamic> jsonData;
  int n = 0;
  DeliveryQueue({required this.jsonData, required this.n});
  final TimeWindowCalc timeWindowCalc = TimeWindowCalc();
  Future<Map<String, dynamic>> getData() async {
    jsonData = await timeWindowCalc.calc(jsonData);
    return jsonData;
  }

  @override
  _DeliveryQueueState createState() => _DeliveryQueueState();
}

class _DeliveryQueueState extends State<DeliveryQueue> {
  late Timer _everySec;
  String time = "";
  @override
  void initState() {
    super.initState();
    seccond();
    _everySec = Timer.periodic(const Duration(seconds: 5), (Timer t) {
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
    widget.getData();
  }

  @override
  Widget build(BuildContext context) {
    final stops = widget.jsonData['delivery']['stops'];
    int n = widget.n;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: (MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height) *
                0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Container(
                  child: const Text(
                    "Current Delivery",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  stops.length > n ? stops[n]['name'] : 'No More Data',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  stops.length > n ? stops[n]['address'] : '',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          stops.length > n
                              ? '${DateTime.parse(stops[n]['timeWindowSubs']).hour.toString().padLeft(2, '0')}:${DateTime.parse(stops[n]['timeWindowSubs']).minute.toString().padLeft(2, '0')} - ${DateTime.parse(stops[n]['timeWindowPlus']).hour.toString().padLeft(2, '0')}:${DateTime.parse(stops[n]['timeWindowPlus']).minute.toString().padLeft(2, '0')}'
                              : '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                        const Text(
                          'Estimated Time Arrival',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 30),
                    Column(
                      children: [
                        Text(
                          stops.length > n
                              ? '${DateTime.parse(stops[n]['stopStartTime']).hour.toString().padLeft(2, '0')}:${DateTime.parse(stops[n]['stopStartTime']).minute.toString().padLeft(2, '0')} '
                              : '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                        const Text(
                          'Expected Stop Finish',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (stops.length > n + 1) ...[
            const Divider(
              thickness: 1,
              color: Color.fromARGB(255, 208, 208, 208),
            ),
            Container(
              height: (MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height) *
                  0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Container(
                    child: const Text(
                      "Next Delivery",
                      style: TextStyle(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stops.length > n + 1
                        ? stops[n + 1]['name']
                        : 'No More Data',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stops.length > n + 1 ? stops[n + 1]['address'] : '',
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            stops.length > n + 1
                                ? '${DateTime.parse(stops[n + 1]['timeWindowSubs']).hour.toString().padLeft(2, '0')}:${DateTime.parse(stops[n + 1]['timeWindowSubs']).minute.toString().padLeft(2, '0')} - ${DateTime.parse(stops[n + 1]['timeWindowPlus']).hour.toString().padLeft(2, '0')}:${DateTime.parse(stops[n + 1]['timeWindowPlus']).minute.toString().padLeft(2, '0')}'
                                : '',
                          ),
                          const Text(
                            'Estimated Time Arrival',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 9),
                          ),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Column(
                        children: [
                          Text(
                            stops.length > n
                                ? '${DateTime.parse(stops[n + 1]['stopStartTime']).hour.toString().padLeft(2, '0')}:${DateTime.parse(stops[n + 1]['stopStartTime']).minute.toString().padLeft(2, '0')} '
                                : '',
                          ),
                          const Text(
                            'Expected Stop Finish',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
