import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/bluetooth_service.dart';
import 'package:bili_sense/presentation/test/test_cubit.dart';
import 'package:bili_sense/presentation/mother_details/mother_details_cubit.dart';
import 'package:bili_sense/presentation/widget/bilirubin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

class TestView extends StatefulWidget {
  final BluetoothDevice device;
  final MotherModel motherModel;

  const TestView({
    super.key,
    required this.device,
    required this.motherModel,
  });

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  String connectionStatus = "........";
  double? jaundiceData;
  final BleBluetoothService bleService = getIt<BleBluetoothService>();
  List<double> readings = [];
  late TestModel test;

  double averageBilirubin(List<double> readings) {
    if (readings.isEmpty) return 0;
    double sum = readings.reduce((a, b) => a + b);
    return sum / readings.length;
  }

  double _getAgeInHours(DateTime dob, DateTime createdAt) {
    if (dob.isAfter(createdAt)) return 0;
    return createdAt.difference(dob).inHours.toDouble();
  }


  @override
  void initState() {
    super.initState();
    _connectToMeter();
  }

  Future<void> _connectToMeter() async {
    try {
      await bleService.connectToDevice(widget.device);
      setState(() => connectionStatus = "Connected");

      bleService.jaundiceValues.listen((value) {
        setState(() {
          jaundiceData = value;
          if (value != 0.0) {
            readings.add(value);
          }
          if (readings.length > 3) {
            readings.removeAt(0);
          }
          double average = averageBilirubin(readings);
          debugPrint("Average Bilirubin: ${average.toStringAsFixed(2)} mg/dL");
        });
      });
    } catch (e) {
      debugPrint("Connection failed: $e");
      setState(() => connectionStatus = "Connection failed...");
    }
  }

  @override
  void dispose() {
    bleService.disconnect();
    super.dispose();
  }

  String getBilirubinSeverity(double bilirubin, double ageInHours) {
    if (ageInHours <= 24) {
      if (bilirubin < 6) {
        return 'Normal';
      } else {
        return 'High';
      }
    } else if (ageInHours <= 48) {
      if (bilirubin < 10) {
        return 'Normal';
      } else if (bilirubin < 15) {
        return 'Moderate';
      } else {
        return 'High';
      } // Phototherapy threshold starts at 15
    } else if (ageInHours <= 72) {
      if (bilirubin < 12) {
        return 'Normal';
      } else if (bilirubin < 18) {
        return 'Moderate';
      } else {
        return 'High';
      } // Phototherapy starts at 18
    } else {
      if (bilirubin < 15) {
        return 'Normal';
      } else if (bilirubin < 20) {
        return 'Moderate';
      } else {
        return 'High';
      } // Phototherapy starts at 20
    }
  }

  @override
  Widget build(BuildContext context) {
    final jaundiceDisplay = jaundiceData?.toStringAsFixed(2) ?? "--";

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Monitor Jaundice"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  connectionStatus = "Reconnecting...";
                  _connectToMeter();
                  readings.clear();
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/jaundice_meter.png',
                      width: 100,
                      height: 100,
                    ),
                    Text(
                      connectionStatus,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                BilirubinCircularCard(
                  bilirubinReading: double.tryParse(jaundiceDisplay) ?? 0.0,
                  completedTests: readings.length,
                  severityLabel: getBilirubinSeverity(
                    averageBilirubin(readings),
                    _getAgeInHours(
                      widget.motherModel.dob,
                      widget.motherModel.createdAt ?? DateTime.now(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (readings.length >= 3)
                  Text(
                    'Test Completed!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 24),
                Visibility(
                  visible: readings.length >= 3,
                  child: Column(
                    children: [
                      Text(
                        "Average Bilirubin level: ${averageBilirubin(readings).toStringAsFixed(2)} mg/dL, which is considered ${getBilirubinSeverity(averageBilirubin(readings), _getAgeInHours(widget.motherModel.dob, widget.motherModel.createdAt ?? DateTime.now()))}.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.maxFinite,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'Try Again',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<TestCubit, TestState>(
                  builder: (context, state) {
                    if (state is TestLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is TestError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    if (state is TestSuccess) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      });
                    }
                    return Column(
                      children: [
                        if (readings.length >= 3)
                          SizedBox(
                            width: double.maxFinite,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                test = TestModel(
                                  motherName: widget.motherModel.motherName,
                                  bilirubinReading: readings.last.toDouble(),
                                  createdAt: DateTime.now(),
                                  weight: widget.motherModel.weight ?? 0.0,
                                  dob: widget.motherModel.dob,
                                  doctorName:
                                      widget.motherModel.doctorName ??
                                      'unknown',
                                  readings: readings,
                                );
                                context.read<TestCubit>().saveTest(test);
                              },
                              child: const Text(
                                "Save Test",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
