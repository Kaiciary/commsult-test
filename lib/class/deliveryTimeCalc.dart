/*
void main() {
  TimeWindowCalc timeWindowCalc = TimeWindowCalc();
  timeWindowCalc.calc();
}*/
import 'dart:developer';
class TimeWindowCalc {
  late DateTime startingTime,
      eta,
      timeWindowStart,
      timeWindowEnd,
      excpectedFinishTime;
  List<String> namePairs = [];
  List<String> timeWindowSubs = [];
  List<String> timeWindowPlus = [];
  List<String> expectedFinishTimes = [];

  Future<Map<String, dynamic>> calc(jsonDatas) async {
    expectedFinishTimes.clear();
    timeWindowSubs.clear();
    timeWindowPlus.clear();
    Map<String, dynamic> jsonData = jsonDatas;
    DateTime plannedStartTime =
        DateTime.parse(jsonData['delivery']['plannedStartTime']);
    DateTime systemTime = DateTime.now();

    if (systemTime.isBefore(plannedStartTime)) {
      startingTime = plannedStartTime;
    } else {
      startingTime = systemTime;
    }

    //jsonData['delivery']['startTime'] = startingTime.toIso8601String();

    bool firstKeyProcessed = false;
    String firstName = jsonData['delivery']['stops'][0]['name'].toLowerCase();
    jsonData['delivery']['matrix'].forEach((key, value) {
      if (key.startsWith("base-$firstName")) {
        if (!firstKeyProcessed) {
          int duration = value['duration'];

          eta = startingTime.add(Duration(minutes: duration));

          firstKeyProcessed = true;
        }
      }
    });

    eta =
        DateTime(eta.year, eta.month, eta.day, eta.hour, (eta.minute ~/ 5) * 5);

    timeWindowStart = eta.subtract(const Duration(minutes: 15));
    timeWindowEnd = eta.add(const Duration(minutes: 15));

    excpectedFinishTime = eta.add(
        Duration(minutes: jsonData['delivery']['stops'][0]['unloadingTime']));

    expectedFinishTimes.add(excpectedFinishTime.toIso8601String());

    int n = 0;
    int m = 1;
    for (int i = 0; i < jsonData['delivery']['stops'].length - 1; i++) {
      String firstName = jsonData['delivery']['stops'][i]['name'].toLowerCase();
      String secondName =
          jsonData['delivery']['stops'][i + 1]['name'].toLowerCase();
      namePairs.add(firstName);
      namePairs.add(secondName);
    }

    List<String> uniqueList = [];

    for (var item in namePairs) {
      if (!uniqueList.contains(item)) {
        uniqueList.add(item);
      }
    }

    for (int i = 0; i < jsonData['delivery']['stops'].length; i++) {
      if (i == 0) {
        i++;
      }
      if (jsonData['delivery']['stops'][i - 1]['stopEndTime'] != "") {
        excpectedFinishTime =
            DateTime.parse(jsonData['delivery']['stops'][i - 1]['stopEndTime']);
      }
    }

    for (int i = 0; i < uniqueList.length; i++) {
      jsonData['delivery']['matrix'].forEach((key, value) {
        String pattern = "${uniqueList[n]}-${uniqueList[m]}";
        key = key.trim();
        pattern = pattern.trim();

        if (key.startsWith(pattern)) {
          if (uniqueList.length >= m) {
            int duration = value['duration'];
            eta = excpectedFinishTime.add(Duration(minutes: duration));
            eta = DateTime(
                eta.year, eta.month, eta.day, eta.hour, (eta.minute ~/ 5) * 5);
            timeWindowStart = eta.subtract(const Duration(minutes: 15));
            timeWindowSubs.add(timeWindowStart.toIso8601String());
            timeWindowEnd = eta.add(const Duration(minutes: 15));
            timeWindowPlus.add(timeWindowEnd.toIso8601String());
            if (uniqueList.length - 2 != n) {
              n++;
              m = n + 1;
            }
            excpectedFinishTime = eta.add(Duration(
                minutes: jsonData['delivery']['stops'][n]['unloadingTime']));

            expectedFinishTimes.add(excpectedFinishTime.toIso8601String());
          }
        }
      });
    }

    for (int i = 0; i < jsonData['delivery']['stops'].length; i++) {
      jsonData['delivery']['stops'][i]['timeWindowSubs'] = timeWindowSubs[i];
      jsonData['delivery']['stops'][i]['timeWindowPlus'] = timeWindowPlus[i];
      //estimated finish time
      if (jsonData['delivery']['stops'][i]['disabled'] == 0) {
        jsonData['delivery']['stops'][i]['stopStartTime'] =
            expectedFinishTimes[i];
      }
    }
    return jsonData;
  }
}
