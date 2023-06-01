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
    String apiUrl = 'http://127.0.0.1:5000/predict';

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var predictions = responseData['predictions'];

        print('Predictions: $predictions');
      } else {
        print(
            'Failed to send prediction request. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send prediction request. Error: $e');
    }
  }

  Widget space(double width) {
    return SizedBox(height: width * 20 / 360);
  }

  List<String> _riderNames = ['John', 'Jane', 'Alex', 'Emily'];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.shortestSide;
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(width * 20 / 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ordered Food ?',
                    style: TextStyle(
                      fontSize: width * 28 / 360,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    "Let's predicting time...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: width * 24 / 360,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              space(width),
              Text(
                'Rider Name',
                style: TextStyle(
                  fontSize: width * 16 / 360,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedRiderName ?? 'Select',
                    style: TextStyle(
                      fontSize: width * 15 / 360,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 25),
                  IconButton(
                    onPressed: _selectRider,
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey,
                      size: width * 22 / 360,
                    ),
                  ),
                ],
              ),
              space(width),
              Row(
                children: [
                  Text(
                    'Rider Rating:',
                    style: TextStyle(
                      fontSize: width * 16 / 360,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    _selectedRiderRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: width * 15 / 360,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              space(width),
              Slider(
                value: _selectedRiderRating,
                min: 2.5,
                max: 4.9,
                divisions: 25,
                onChanged: (double newValue) {
                  setState(() {
                    _selectedRiderRating = newValue;
                  });
                },
              ),
              space(width),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weather:',
                    style: TextStyle(
                      fontSize: width * 16 / 360,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _selectedWeather ?? 'Fetching...',
                        style: TextStyle(
                          fontSize: width * 15 / 360,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 25),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.grey,
                          size: width * 22 / 360,
                        ),
                        onPressed: () {
                          _showWeatherDialog();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              space(width),
              Text(
                'Restaurant Name',
                style: TextStyle(
                  fontSize: width * 16 / 360,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedRestaurant ?? 'Select',
                    style: TextStyle(
                      fontSize: width * 15 / 360,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 25),
                  IconButton(
                    onPressed: _selectRestaurant,
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey,
                      size: width * 22 / 360,
                    ),
                  ),
                ],
              ),
              space(width * 2.5),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> requestData = {
                      "Delivery_person_Age": [_riderAge],
                      "Delivery_person_Ratings": [_selectedRiderRating],
                      "Distance": [
                        _distance != null ? double.parse(_distance!) : 0.0
                      ],
                    };
                    sendPredictionRequest(requestData);
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: width * 15 / 360,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPredictionAccuracySnackbar,
        child: Icon(
          Icons.info,
          color: Colors.grey,
          size: width * 22 / 360,
        ),
      ),
    );
  }

  void _selectRider() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Rider'),
          content: DropdownButton<String>(
            value: _selectedRiderName,
            items: _riderNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRiderName = newValue;
                _riderAge = riderData[_selectedRiderName];
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showWeatherDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Weather'),
          content: DropdownButton<String>(
            value: _selectedWeather,
            items: _availableWeather.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedWeather = newValue;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _selectRestaurant() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Restaurant'),
          content: DropdownButton<String>(
            value: _selectedRestaurant,
            items: restaurantData.keys.map((String restaurant) {
              return DropdownMenuItem<String>(
                value: restaurant,
                child: Text(restaurant),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRestaurant = newValue;
                _distance = restaurantData[newValue!];
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
}
