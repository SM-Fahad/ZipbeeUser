import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';
import 'package:flutter/material.dart';

class GoogleMapScreen extends StatelessWidget {
  const GoogleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Screen'),
      ),
      body: GoogleMapWidget(),
      // body: PracticeMap(), // Only for Testing
    );
  }
}