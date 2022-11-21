import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_poc/ui/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO 1: Please change this text with your publishing api key
  Stripe.publishableKey =
      "Your Stripe Publishing key"; //Your Stripe Publishing key <= replace this text with you stripe publishing key
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Payment POC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
