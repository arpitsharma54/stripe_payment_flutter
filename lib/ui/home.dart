import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stripe Payment"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(),
          Material(
            color: Colors.green,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              splashColor: Colors.white.withOpacity(0.3),
              onTap: () async {
                print("Button Pressed");
                await makePayment();
              },
              child: isLoading
                  ? const SizedBox(
                      height: 50,
                      width: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 50,
                      width: 200,
                      child: Center(
                        child: Text(
                          "Pay",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    setState(() {
      isLoading = true;
    });
    try {
      paymentIntentData = await createPaymentIntent("20", "USD");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Stripe POC",
          // applePay: const PaymentSheetApplePay(merchantCountryCode: "+91"),
          // googlePay: const PaymentSheetGooglePay(
          //     merchantCountryCode: "+91", testEnv: true, currencyCode: "US")
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception = ${e.toString()}");
    }
  }

  displayPaymentSheet() async {
    try {
      print("displayPaymentSheet");
      await Stripe.instance.presentPaymentSheet().then((value) {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));
      });
      paymentIntentData = null;

      setState(() {
        isLoading = false;
      });
    } on StripeException catch (e) {
      print("Exception = ${e.toString()}");
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                content: Text("Cancelled"),
              ));
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card"
      };

      final url = Uri.parse("https://api.stripe.com/v1/payment_intents");
      // TODO 2: Please change this text with your secure api key
      var response = await http.post(url, body: body, headers: {
        "Authorization":
            "Bearer 'Your Stripe Secure Api Key'", //'Your Stripe Secure Api Key' <= Replace this text with you Stripe secure spi key
        "Content-Type": "application/x-www-form-urlencoded"
      });
      print("Payment Intent Body->>> ${response.body.toString()}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Exception = ${e.toString()}");
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
