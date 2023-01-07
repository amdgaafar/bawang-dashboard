import 'dart:convert';
import 'dart:developer';

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

  // Fields
  int tempField = 1;
  int humidityField = 2;
  int soilMoistureField = 3;
  int waterPumpField = 4;
  int ledField = 12;

  // Loading state
  bool isLedStatusLoading = false;
  bool isDataLoading = false;

  String? ledStatus;

  void getLedStatus() async {
    setState(() {
      isLedStatusLoading = true;
    });

    try {
      var response = await Dio().get(
          "https://api.thingspeak.com/channels/1988838/fields/5.json?api_key=O6THQIAP2H8196RS&results=1");
      print(response);

      Map<String, dynamic> resData = json.decode(response.toString());
      var bawangObj = Bawang.fromJson(resData);

      setState(() {
        ledStatus = bawangObj.feeds![0].field5;
      });
      print(ledStatus);
      setState(() {
        isLedStatusLoading = false;
      });
    } catch (e) {
      print(e);
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
        String? temperatureValue = bawangObj.feeds![i].field1;
        String? humidityValue = bawangObj.feeds![i].field2;
        String? soilMoistureValue = bawangObj.feeds![i].field3;

        setState(() {
          temperatureList.add(double.parse(temperatureValue!));
          humidityList.add(double.parse(humidityValue!));
          soilMoistureList.add(double.parse(soilMoistureValue!));
        });
        setState(() {
          isDataLoading = false;
        });
      }
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
          children: [
            Icon(Icons.dashboard),
            const Text("Bawang Dashboard"),
            Icon(Icons.dashboard)
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
