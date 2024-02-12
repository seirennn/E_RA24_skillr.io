import 'package:flutter/material.dart';

class UnderConstructionPage extends StatelessWidget {
  
  const UnderConstructionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Under Construction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/uncon.png',
              fit: BoxFit.cover
            ),
          ],
        ),
      ),
    );
  }
}