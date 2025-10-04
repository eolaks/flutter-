import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REST Countries API',
      theme: ThemeData(primarySwatch: Colors.green),
      home: CountryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CountryScreen extends StatefulWidget {
  @override
  _CountryScreenState createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  Map<String, dynamic>? countryData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCountry();
  }

  Future<void> fetchCountry() async {
    try {
      final url = Uri.parse('https://restcountries.com/v3.1/name/nigeria');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          countryData = data[0];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REST Countries: Nigeria'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : countryData == null
          ? Center(child: Text('No data found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flag Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  countryData!['flags']['png'],
                  width: 180,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),

              // Country Information
              Text(
                countryData!['name']['common'],
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              InfoRow(
                  label: "Capital:",
                  value: countryData!['capital'][0]),
              InfoRow(
                  label: "Region:",
                  value: countryData!['region']),
              InfoRow(
                  label: "Population:",
                  value:
                  countryData!['population'].toString()),

              SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: fetchCountry,
                icon: Icon(Icons.refresh),
                label: Text("Refresh Data"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable Widget for displaying info rows
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
