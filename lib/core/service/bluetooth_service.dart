import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'lc_jaundice_decoder.dart';

class BleBluetoothService {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  final LCJaundiceDecoder decoder = LCJaundiceDecoder();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;

  StreamController<double>? _jaundiceValueController;

  Stream<double> get jaundiceValues =>
      _jaundiceValueController?.stream ?? const Stream.empty();

  BleBluetoothService() {
    _initController();
  }

  void _initController() {
    _jaundiceValueController?.close();
    _jaundiceValueController = StreamController<double>.broadcast();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    _initController();
    await device.connect(autoConnect: false);

    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        await _setupNotification(characteristic);
        _writeCharacteristic = characteristic;
      }
    }
  }

  Future<void> _setupNotification(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((data) {
      debugPrint('data received: $data');
      double result = decoder.decodeData(data);
      _jaundiceValueController?.add(result);
    });
  }

  Future<void> writeCommand(List<int> bytes) async {
    if (_writeCharacteristic != null) {
      await _writeCharacteristic!.write(bytes, withoutResponse: true);
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }

    await _jaundiceValueController?.close();
    _jaundiceValueController = null;
  }
}