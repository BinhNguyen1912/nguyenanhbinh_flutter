// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Device Dashboard',
      home: const IoTDeviceDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IoTDeviceDashboard extends StatefulWidget {
  const IoTDeviceDashboard({super.key});
  @override
  State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
}

class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
  final _baseUrl = 'http://192.168.5.153:8080';
  List<Device> _devices = [];
  final _deviceNameController = TextEditingController();
  final _deviceTopicController = TextEditingController();
  final _payloadController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    final response = await http.get(Uri.parse('$_baseUrl/devices'));
    if (response.statusCode == 200) {
      final List list = json.decode(response.body);
      setState(() {
        _devices = list.map((json) => Device.fromJson(json)).toList();
      });
    }
  }

  Future<void> createDevice() async {
    if (_deviceNameController.text.isEmpty ||
        _deviceTopicController.text.isEmpty)
      return;
    final response = await http.post(
      Uri.parse('$_baseUrl/devices'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _deviceNameController.text,
        'topic': _deviceTopicController.text,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      _deviceNameController.clear();
      _deviceTopicController.clear();
      fetchDevices();
    }
  }

  Future<void> controlDevice(int id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/devices/$id/control'),
      headers: {'Content-Type': 'text/plain'},
      body: _payloadController.text,
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lệnh đã gửi')));
    }
  }

  Future<void> _showTelemetryDialog(int deviceId, String deviceName) async {
    List<Telemetry> telemetries = await fetchTelemetry(deviceId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Telemetry - $deviceName'),
        content: SizedBox(
          width: double.maxFinite,
          child: telemetries.isEmpty
              ? const Text('Không có dữ liệu')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: telemetries.length,
                  itemBuilder: (context, index) {
                    final t = telemetries[index];
                    return ListTile(
                      title: Text(t.value),
                      subtitle: Text(t.timestamp),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<List<Telemetry>> fetchTelemetry(int deviceId) async {
    final response = await http.get(Uri.parse('$_baseUrl/telemetry/$deviceId'));
    if (response.statusCode == 200) {
      final List list = json.decode(response.body);
      return list.map((json) => Telemetry.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Device Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '📋 Danh sách thiết bị',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ..._devices.map(
              (d) => Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  title: Text(d.name),
                  subtitle: Text(d.topic),
                  trailing: ElevatedButton(
                    onPressed: () => controlDevice(d.id),
                    child: const Text('Gửi lệnh'),
                  ),
                  onTap: () => _showTelemetryDialog(d.id, d.name),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '➕ Thêm thiết bị mới',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(labelText: 'Tên thiết bị'),
            ),
            TextField(
              controller: _deviceTopicController,
              decoration: const InputDecoration(labelText: 'Topic MQTT'),
            ),
            ElevatedButton(
              onPressed: createDevice,
              child: const Text('Tạo thiết bị'),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎮 Nhập lệnh điều khiển',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _payloadController,
              decoration: const InputDecoration(hintText: '{data:20}'),
            ),
          ],
        ),
      ),
    );
  }
}

class Device {
  final int id;
  final String name;
  final String topic;
  Device({required this.id, required this.name, required this.topic});
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(id: json['id'], name: json['name'], topic: json['topic']);
  }
}

class Telemetry {
  final String timestamp;
  final String value;
  Telemetry({required this.timestamp, required this.value});
  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(timestamp: json['timestamp'], value: json['value']);
  }
}
