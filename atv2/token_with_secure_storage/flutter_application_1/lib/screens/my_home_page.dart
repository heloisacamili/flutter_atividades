import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadToken(); 
  }

  Future<void> _storeToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token); 
  }

  Future<void> _loadToken() async {
    String? token = await _secureStorage.read(key: 'auth_token');
    setState(() {
      _token = token ?? 'No token found';
    });
  }

  void _generateAndStoreToken() {
    String token = 'sample_token_${DateTime.now().millisecondsSinceEpoch}';  
    _storeToken(token); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Secure Storage Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Stored Token: $_token',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateAndStoreToken,
              child: const Text('Generate & Store Token'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadToken,
              child: const Text('Load Token'),
            ),
          ],
        ),
      ),
    );
  }
}