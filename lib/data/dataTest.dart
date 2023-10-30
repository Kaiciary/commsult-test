class DataTest {
  Map<String, dynamic> jsonData = {
    "delivery": {
      "startTime": "",
      "finishTime": "DDMMYYY [T]",
      "plannedStartTime": "2023-10-27 14:30:00.000",
      "deliveryNumber": "A91JK0S7",
      "stops": [
        {
          "key": "174859",
          "number": 174859,
          "name": "Stop_1",
          "address": "Los Angeles",
          "stopIndex": 1,
          "timeWindowSubs": "",
          "timeWindowPlus": "",
          "stopStartTime": "",
          "stopEndTime": "",
          "unloadingTime": 10,
          "disabled": 0,
          "order": 1
        },
        {
          "key": "174860",
          "number": 174860,
          "name": "Stop_2",
          "address": "New York",
          "stopIndex": 2,
           "timeWindowSubs": "",
          "timeWindowPlus": "",
          "stopStartTime": "",
          "stopEndTime": "",
          "unloadingTime": 23,
          "disabled": 0,
          "order": 2
        },
        {
          "key": "174861",
          "number": 174861,
          "name": "Stop_3",
          "address": "11 Mapple Tree, Broklyn, New York",
          "stopIndex": 3,
           "timeWindowSubs": "",
          "timeWindowPlus": "",
          "stopStartTime": "",
          "stopEndTime": "",
          "unloadingTime": 5,
          "disabled": 0,
          "order": 3
        },
        {
          "key": "174862",
          "number": 174862,
          "name": "Stop_4",
          "address": "9 yellow st, Broklyn, New York",
          "stopIndex": 4,
           "timeWindowSubs": "",
          "timeWindowPlus": "",
          "stopStartTime": "",
          "stopEndTime": "",
          "unloadingTime": 15,
          "disabled": 0,
          "order": 4
        },
        {
          "key": "174863",
          "number": 174863,
          "name": "Stop_5",
          "address": "West Allogio, New York",
          "stopIndex": 5,
          "timeWindowSubs": "",
          "timeWindowPlus": "",
          "stopStartTime": "",
          "stopEndTime": "",
          "unloadingTime": 15,
          "disabled": 0,
          "order": 5
        }
      ],
      "matrix": {
        "base-stop_1": {"length": 50000, "duration": 30},
        "base-stop_2": {"length": 55000, "duration": 20},
        "base-stop_3": {"length": 60000, "duration": 30},
        "base-stop_4": {"length": 70000, "duration": 40},
        "base-stop_5": {"length": 65000, "duration": 25},
        "stop_1-base": {"length": 48000, "duration": 25},
        "stop_2-base": {"length": 53000, "duration": 18},
        "stop_3-base": {"length": 43000, "duration": 20},
        "stop_4-base": {"length": 33000, "duration": 25},
        "stop_5-base": {"length": 23000, "duration": 23},
        "stop_1-stop_2": {"length": 20000, "duration": 10},
        "stop_1-stop_3": {"length": 10000, "duration": 10},
        "stop_1-stop_4": {"length": 6000, "duration": 5},
        "stop_1-stop_5": {"length": 14000, "duration": 20},
        "stop_2-stop_1": {"length": 20000, "duration": 10},
        "stop_2-stop_3": {"length": 20000, "duration": 10},
        "stop_2-stop_4": {"length": 10000, "duration": 10},
        "stop_2-stop_5": {"length": 6000, "duration": 5},
        "stop_3-stop_1": {"length": 20000, "duration": 10},
        "stop_3-stop_2": {"length": 20000, "duration": 10},
        "stop_3-stop_4": {"length": 10000, "duration": 10},
        "stop_3-stop_5": {"length": 6000, "duration": 5},
        "stop_4-stop_1": {"length": 20000, "duration": 10},
        "stop_4-stop_2": {"length": 20000, "duration": 10},
        "stop_4-stop_3": {"length": 10000, "duration": 10},
        "stop_4-stop_5": {"length": 6000, "duration": 5},
        "stop_5-stop_1": {"length": 20000, "duration": 10},
        "stop_5-stop_2": {"length": 20000, "duration": 10},
        "stop_5-stop_3": {"length": 10000, "duration": 10},
        "stop_5-stop_4": {"length": 6000, "duration": 5},
      }
    }
  };

  // Getter method to access the JSON data
  Map<String, dynamic> getJsonData() {
    //String jsonString = jsonEncode(jsonData);
    return jsonData;
  }
}
