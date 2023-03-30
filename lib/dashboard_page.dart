import 'dart:convert';

import 'package:bawang_dashboard/models/Bawang.dart';
import 'package:bawang_dashboard/widgets/my_sensor_card.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String readAPI = "O6THQIAP2H8196RS";
  String writeAPI = "Y82H1TUDTF2LPTMD";
  String baseURL = "https://api.thingspeak.com/";
  String channelID = "1988838";
  int resultsCount = 8;

  List<double> temperatureList = [0];
  List<double> humidityList = [0];
  List<double> soilMoistureList = [0];
  bool isWaterPumpActive = false;

  // Fields
  int tempField = 1;
  int humidityField = 2;
  int soilMoistureField = 3;
  int waterPumpField = 4;
  int ledField = 12;

  // Loading state
  bool isLedStatusLoading = false;
  bool isDataLoading = false;

  // Results
  String waterPumpRes = "-1";
  bool isWaterPumpLoading = false;

  String waterPumpZeroRes = "-1";
  bool isWaterPumpZeroLoading = false;

  String? ledStatus;

  void getLedStatus() {
    var dt = DateTime.now();
    print(dt.hour);
    if (int.parse(dt.hour.toString()) < 16 &&
        int.parse(dt.hour.toString()) > 1) {
      setState(() {
        ledStatus = "0";
      });
    } else {
      setState(() {
        ledStatus = "1";
      });
    }
  }

  void getData() async {
    temperatureList = [0];
    humidityList = [0];
    soilMoistureList = [0];

    setState(() {
      isDataLoading = true;
    });

    try {
      String resultsCountString = resultsCount.toString();
      var response = await Dio().get(
          "https://api.thingspeak.com/channels/1988838/feeds.json?api_key=O6THQIAP2H8196RS&results=$resultsCountString");

      Map<String, dynamic> resData = json.decode(response.toString());
      print(resData);
      var bawangObj = Bawang.fromJson(resData);

      for (int i = 0; i < resultsCount; i++) {
        // Temperature
        String? temperatureValue = bawangObj.feeds![i].field1;
        temperatureValue == null
            ? temperatureValue = '0.0'
            : temperatureValue = temperatureValue;

        // Humidity
        String? humidityValue = bawangObj.feeds![i].field2;
        humidityValue == null
            ? humidityValue = '0.0'
            : humidityValue = humidityValue;

        // Soil Moisture
        String? soilMoistureValue = bawangObj.feeds![i].field3;
        soilMoistureValue == null
            ? soilMoistureValue = '0.0'
            : soilMoistureValue = soilMoistureValue;

        // Water pump status
        String? waterPumpStatus = bawangObj.feeds![i].field4;
        waterPumpStatus == null
            ? waterPumpStatus = '0'
            : waterPumpStatus = waterPumpStatus;

        setState(() {
          temperatureList.add(double.parse(temperatureValue!));
          humidityList.add(double.parse(humidityValue!));
          soilMoistureList.add(double.parse(soilMoistureValue!));
          waterPumpStatus == '1'
              ? isWaterPumpActive = true
              : isWaterPumpActive = false;
          isDataLoading = false;
        });
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  void waterPump() async {
    setState(() {
      isWaterPumpLoading = true;
    });

    try {
      var response = await Dio().get(
          "https://api.thingspeak.com/update?api_key=Y82H1TUDTF2LPTMD&field1=24&field2=91&field3=68.58&field4=1");
      print(response.toString());
      getData();
      setState(() {
        waterPumpRes = response.toString();
        isWaterPumpLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void waterPumpZero() async {
    setState(() {
      isWaterPumpZeroLoading = true;
    });

    try {
      var response = await Dio().get(
          "https://api.thingspeak.com/update?api_key=Y82H1TUDTF2LPTMD&field1=24&field2=91&field3=68.58&field4=0");
      print(response.toString());
      getData();
      setState(() {
        waterPumpZeroRes = response.toString();
        isWaterPumpZeroLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Bawang Dashboard"),
          ],
        ),
        elevation: 12,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ElevatedButton(
                              onPressed: getLedStatus,
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 60)),
                              child: isLedStatusLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : const Text("LED status"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon((ledStatus == null)
                              ? Icons.error
                              : (ledStatus == "1")
                                  ? Icons.light_mode
                                  : (ledStatus == "0")
                                      ? Icons.light_mode_outlined
                                      : Icons.error)
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: getData,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 60)),
                          child: isDataLoading
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text("Refresh Data"),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: waterPump,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isWaterPumpActive
                                        ? Colors.green
                                        : Colors.grey,
                                    minimumSize: const Size(120, 60),
                                  ),
                                  child: isWaterPumpLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Icon(Icons.water_drop),
                                ),
                                waterPumpRes == '0'
                                    ? const Text("Fail, wait 5s",
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold))
                                    : waterPumpRes == '-1'
                                        ? const Text("No data, press")
                                        : const Text("Successful",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: waterPumpZero,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isWaterPumpActive
                                        ? Colors.grey
                                        : Colors.green,
                                    minimumSize: const Size(120, 60),
                                  ),
                                  child: isWaterPumpZeroLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Icon(Icons.water_drop_outlined),
                                ),
                                waterPumpZeroRes == '0'
                                    ? const Text("Fail, wait 5s",
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold))
                                    : waterPumpZeroRes == '-1'
                                        ? const Text("No data, press")
                                        : const Text("Successful",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                MySensorCard(
                  value: temperatureList[temperatureList.length - 1],
                  name: "Temperature",
                  assetImage: const AssetImage('assets/images/temperature.png'),
                  unit: '\'C',
                  trendData: temperatureList,
                  linePoint: Colors.redAccent,
                ),
                MySensorCard(
                  value: humidityList[humidityList.length - 1],
                  name: "Humidity",
                  assetImage:
                      const AssetImage('assets/images/humidity_icon.png'),
                  unit: "%",
                  trendData: humidityList,
                  linePoint: Colors.lightBlueAccent,
                ),
                MySensorCard(
                  value: soilMoistureList[soilMoistureList.length - 1],
                  name: "Soil moisture",
                  assetImage:
                      const AssetImage('assets/images/soil-analysis.png'),
                  unit: "%",
                  trendData: soilMoistureList,
                  linePoint: Colors.brown,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
