class FinishTimeCalc {
  late DateTime eta, excpectedFinishTime, timeWindowStart, timeWindowEnd;
  List<String> expectedFinishTimes = [];

  //calc excpectedfinishtime time when courrier finish the stop
  Future<Map<String, dynamic>> calcDelivery(jsonDatas) async {
    expectedFinishTimes.clear();
    Map<String, dynamic> jsonData = jsonDatas;

    for (int i = 0; i < jsonData['delivery']['stops'].length; i++) {
      if (jsonData['delivery']['stops'][0]['disabled'] == 1 &&
          jsonData['delivery']['stops'][1]['disabled'] == 0) {
        DateTime system = DateTime.now();
        jsonData['delivery']['stops'][0]['stopEndTime'] =
            system.toIso8601String();
      } else if (jsonData['delivery']['stops']
              [jsonData['delivery']['stops'].length - 1]['disabled'] ==
          1) {
        DateTime system = DateTime.now();

        jsonData['delivery']['stops'][jsonData['delivery']['stops'].length - 1]
            ['stopEndTime'] = system.toIso8601String();
      } else {
        if (i == 0) {
          i++;
        }

        if (jsonData['delivery']['stops'][i]['disabled'] == 1 &&
            jsonData['delivery']['stops'][i + 1]['disabled'] == 0) {
          DateTime system = DateTime.now();

          jsonData['delivery']['stops'][i]['stopEndTime'] =
              system.toIso8601String();
        }
      }
    }

    return jsonData;
  }
}
