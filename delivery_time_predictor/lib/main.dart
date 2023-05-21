import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Time Prediction',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: DeliveryPage(),
    );
  }
}

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final TextEditingController _deliveryPersonRatingController =
      TextEditingController();
  String? _weatherCondition;
  String? _roadTrafficDensity;
  String? _vehicleCondition;
  String? _multipleDeliveries;
  double? _distance;
  double? _deliveryPersonAge;

  void _submitPrediction() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/predict'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final prediction = responseData['predictions'][0];

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Predicted Delivery Time',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
                SizedBox(height: 10.0),
                Text(
                  '$prediction minutes',
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    } else {
      print('API call failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Time Prediction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Delivery Person Details',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              FlutterSlider(
                values: [_deliveryPersonAge ?? 18],
                min: 18,
                max: 55,
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _deliveryPersonAge = lowerValue;
                  });
                },
                tooltip: FlutterSliderTooltip(
                  format: (value) {
                    return value.toString();
                  },
                  positionOffset: FlutterSliderTooltipPositionOffset(
                    top: -40,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Age: ${_deliveryPersonAge?.toStringAsFixed(0) ?? ''}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Delivery Person Rating',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _deliveryPersonRatingController,
                decoration:
                    InputDecoration(labelText: 'Delivery Person Rating'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.0),
              Text(
                'Weather Conditions',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _weatherCondition,
                decoration: InputDecoration(labelText: 'Weather Conditions'),
                onChanged: (value) {
                  setState(() {
                    _weatherCondition = value!;
                  });
                },
                items: ['Sunny', 'Cloudy']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                'Road Traffic Density',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _roadTrafficDensity,
                decoration: InputDecoration(labelText: 'Road Traffic Density'),
                onChanged: (value) {
                  setState(() {
                    _roadTrafficDensity = value!;
                  });
                },
                items: ['High', 'Medium', 'Low']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                'Vehicle Condition',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _vehicleCondition,
                decoration: InputDecoration(labelText: 'Vehicle Condition'),
                onChanged: (value) {
                  setState(() {
                    _vehicleCondition = value!;
                  });
                },
                items: ['0', '1', '2']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                'Multiple Deliveries',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _multipleDeliveries,
                decoration: InputDecoration(labelText: 'Multiple Deliveries'),
                onChanged: (value) {
                  setState(() {
                    _multipleDeliveries = value!;
                  });
                },
                items: ['Yes', 'No']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                'Distance',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FlutterSlider(
                values: [_distance ?? 0],
                min: 0,
                max: 10,
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _distance = lowerValue;
                  });
                },
                tooltip: FlutterSliderTooltip(
                  format: (value) {
                    return value.toString();
                  },
                  positionOffset: FlutterSliderTooltipPositionOffset(
                    top: -40,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Distance: ${_distance?.toStringAsFixed(0) ?? ''} km',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitPrediction,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
