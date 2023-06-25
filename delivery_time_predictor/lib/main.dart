import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: RestaurantScreen(),
    );
  }
}

class RestaurantScreen extends StatefulWidget {
  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  Location _location = Location();
  PermissionStatus? _permissionStatus;
  bool _serviceEnabled = false;
  String? _selectedRiderName;
  double _selectedRiderRating = 3.0;
  String? _selectedWeather;
  String? _riderAge;
  String? _selectedRestaurant;
  double _predictionAccuracy = 0.0;
  double _prediction = 0.0;
  String? _distance;

  Map<String, String> riderData = {
    'John': '25',
    'Jane': '30',
    'Alex': '28',
    'Emily': '27',
  };

  Map<String, String> restaurantData = {
    'Restaurant A': '2.5',
    'Restaurant B': '3.2',
    'Restaurant C': '1.8',
    'Restaurant D': '4.0',
  };
  List<String> _weatherConditions = ['Sunny', 'Rainy', 'Cloudy', 'Windy'];
  List<String> _availableWeather = [];

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    // Fetch location-based weather data
    LocationData? locationData = await _location.getLocation();
    await fetchWeatherData(locationData.latitude, locationData.longitude);
  }

  Future<void> fetchWeatherData(latitude, longitude) async {
    String apiKey = '4ad54bdd85cb54d2733a6a36b1352c6d';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var weatherData = data['weather'];
        List<String> weatherConditions = [];
        for (var condition in weatherData) {
          weatherConditions.add(condition['main']);
        }
        setState(() {
          _availableWeather = weatherConditions;
          _selectedWeather =
              _availableWeather.isNotEmpty ? _availableWeather[0] : null;
        });
      } else {
        print('Failed to fetch weather data. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch weather data. Error: $e');
    }
  }

  Future<void> sendPredictionRequest(Map<String, dynamic> requestData) async {
    // Simulating prediction request with a random value
    final random = Random();
    double predictionValue = 24 + random.nextDouble() * (58 - 24);
    double predictionAccuracy = 0.85;

    setState(() {
      _prediction = predictionValue;
      _predictionAccuracy = predictionAccuracy;
    });
  }

  void _showPrediction() {
    // Simulating prediction with a random value
    final random = Random();
    double predictValue = 24 + random.nextDouble() * (58 - 24);
    setState(() {
      _prediction = predictValue;
    });
  }

  void _showPredictionAccuracySnackbar() {
    final random = Random();
    double accuracy = 78.4617 + random.nextDouble() * (80.0371 - 78.4617);

    setState(() {
      _predictionAccuracy = accuracy;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The last prediction was made with an accuracy of $_predictionAccuracy',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.shortestSide;
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Prediction'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rider',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedRiderName,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRiderName = newValue;
                    _riderAge = riderData[newValue];
                  });
                },
                items: riderData.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: width * 0.02),
              Text(
                'Rider Age: $_riderAge',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: width * 0.04),
              Text(
                'Restaurant',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedRestaurant,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRestaurant = newValue;
                  });
                },
                items: restaurantData.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: width * 0.02),
              Text(
                'Restaurant Rating: ${restaurantData[_selectedRestaurant ?? ""]}',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: width * 0.04),
              Text(
                'Weather',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedWeather,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWeather = newValue;
                  });
                },
                items: _availableWeather
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: width * 0.04),
              Text(
                'Distance (in km)',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _distance = value;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter distance',
                ),
              ),
              SizedBox(height: width * 0.04),
              ElevatedButton(
                onPressed: () {
                  _showPrediction();
                },
                child: Text('Predict Delivery Time'),
              ),
              SizedBox(height: width * 0.04),
              if (_prediction != 0.0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your food will be here in...',
                      style: TextStyle(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: width * 0.02),
                    Text(
                      '${_prediction.toStringAsFixed(0)} minutes',
                      style: TextStyle(
                          fontSize: width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPredictionAccuracySnackbar,
        child: Icon(Icons.info_outline),
      ),
    );
  }
}
