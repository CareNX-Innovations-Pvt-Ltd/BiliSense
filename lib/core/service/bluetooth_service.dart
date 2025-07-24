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
  List<StreamSubscription> _characteristicSubscriptions = [];

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
    await disconnect(); // cleanup before connecting

    _connectedDevice = device;
    // Don't call _initController() here since disconnect() already handles it

    await device.connect(autoConnect: false);
    final services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        await _setupNotification(characteristic);
        _writeCharacteristic = characteristic;
      }
    }
  }

  Future<void> _setupNotification(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);

    // Store the subscription so we can cancel it later
    final subscription = characteristic.lastValueStream.listen((data) {
      debugPrint('data received: $data');
      double result = decoder.decodeData(data);
      _jaundiceValueController?.add(result);
    });

    _characteristicSubscriptions.add(subscription);
  }

  Future<void> writeCommand(List<int> bytes) async {
    if (_writeCharacteristic != null) {
      await _writeCharacteristic!.write(bytes, withoutResponse: true);
    }
  }

  Future<void> disconnect() async {
    print('Disconnecting from device: ${_connectedDevice?.name}');

    // Cancel all characteristic subscriptions
    for (var subscription in _characteristicSubscriptions) {
      await subscription.cancel();
    }
    _characteristicSubscriptions.clear();

    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }

    _writeCharacteristic = null;

    // Close and recreate the stream controller
    await _jaundiceValueController?.close();
    _initController();
  }

  // Add a dispose method for proper cleanup when the service is no longer needed
  Future<void> dispose() async {
    await disconnect();
    await _jaundiceValueController?.close();
    _jaundiceValueController = null;
  }
}