import 'dart:async';

import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/presentation/test/test_cubit.dart';
import 'package:bili_sense/presentation/mother_details/mother_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothListView extends StatefulWidget {
  final MotherModel motherModel;
  final List<TestModel> tests;

  const BluetoothListView({
    super.key,
    required this.motherModel,
    required this.tests,
  });

  @override
  BluetoothListViewState createState() => BluetoothListViewState();
}

class BluetoothListViewState extends State<BluetoothListView> {
  final List<BluetoothDevice> _devices = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkAndStart();
  }

  Future<void> _checkAndStart() async {
    await _checkPermissions();
    await ensureBluetoothIsOn();
    _startScan();
  }

  Future<void> ensureBluetoothIsOn() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startScan() {
    _clearDeviceList();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        final device = result.device;
        final name = device.platformName;

        if (name.isEmpty || _devices.any((d) => d.remoteId == device.remoteId)) continue;

        debugPrint("Found device: $name");

        setState(() {
          _devices.add(device);
        });
      }
    });
  }

  void _clearDeviceList() {
    setState(() {
      _devices.clear();
    });
  }

  void _onDeviceTap(BluetoothDevice device) async {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    context.pushNamed(
      AppRoutes.test,
      extra: {'device': device, 'motherModel': widget.motherModel},
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<TestCubit, TestState>(
        listener: (context, state) {
          if (state is TestSuccess) {
            context.read<MotherDetailsCubit>().fetchTests(widget.motherModel.motherName);
            // context.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Bluetooth Devices')),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                const Text(
                  'Connect to Bilirubin Meter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ensure Bluetooth is enabled and tap the icon below to start scanning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Image.asset('assets/jaundice_meter.png'),
                const SizedBox(height: 14),
                // BlinkIconWidget(
                //   onIconPath: 'assets/blue.png',
                //   offIconPath: 'assets/on.png',
                //   blinkDuration: const Duration(milliseconds: 1000),
                //   size: 50,
                //   isBlinking: _isScanning,
                //   onTap: _toggleScan,
                // ),
                const SizedBox(height: 18),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.platformName),
                        trailing: const Icon(
                          Icons.bluetooth,
                          color: Colors.blue,
                        ),
                        onTap: () => _onDeviceTap(device),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
