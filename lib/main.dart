import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yfsguhnsdciedbcqwlsq.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlmc2d1aG5zZGNpZWRiY3F3bHNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1Mjg0MzMsImV4cCI6MjEwMjEwNDQzM30.xGrH-JaTscXny29xBWlE5o4XnKhu5sVKyPmrim0zs4k',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _connectionStatus = "Checking connection...";

  @override
  void initState() {
    super.initState();
    _checkSupabaseConnection();
  }

  Future<void> _checkSupabaseConnection() async {
    try {
    final client = Supabase.instance.client;
    final response = await client.from('test_items').select().limit(1);
    if (response.isNotEmpty) {
      final itemName = response[0]['name'];
      setState(() {
        _connectionStatus = "✅ Fetched from Supabase: \"$itemName\"";
      });
    } else {
      setState(() {
        _connectionStatus = "⚠️ Connected, but no rows found";
      });
    }
  } catch (e) {
    setState(() {
      _connectionStatus = "❌ Connection error: $e";
    });
  }
}

void _incrementCounter() {
  setState(() {
    _counter++;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _connectionStatus,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}