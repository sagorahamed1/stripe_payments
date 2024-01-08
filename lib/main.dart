import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

void main() async{

   WidgetsFlutterBinding.ensureInitialized();

   Stripe.publishableKey = "pk_test_51OVVcyFiDaJ8bQBjyv4imMqxSbWPo07q81rTzpcw7yUIlXiUBfFThslht2LC8uD5Ec5MuiW1SPyrasy8N6v3MfyJ00d1bz549n";

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
        useMaterial3: true,
      ),
      home: HomePage()
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stripe payments"),),


      body: Column(
        children: [
          TextButton(onPressed: (){displayPaymentSheet();}, child: Text("buy")),
          Center(
            child: TextButton(onPressed: (){
              makePayment("100","INR");
            }, child: Text("Buy now")),
          ),
        ],
      ),
    );
  }




  Map <String, dynamic>? paymentInternData;


  /// ------------------------make payment -------------------------
  Future<void> makePayment(String amount, String currency)async{

   try{
     paymentInternData = await createPaymentInter(amount, currency);
     if(paymentInternData != null){
       await Stripe.instance.initPaymentSheet(
           paymentSheetParameters: SetupPaymentSheetParameters(
                 // applePay: true,
                googlePay: PaymentSheetGooglePay(merchantCountryCode: "IN"),
               merchantDisplayName: "Proshepts",
               customerId: paymentInternData!["customer"],
               paymentIntentClientSecret: paymentInternData!["client_secret"],
               customerEphemeralKeySecret: paymentInternData!["ephemeralkey"]
           )
       );
       displayPaymentSheet();
     }
   }catch(e){
     print("error --------------$e");
   }
  }



  /// ----------------------create payment internt ---------------------
  createPaymentInter(String amount, String currency) async{
    try{
      Map <String, dynamic> body = {
        "amount" : calculateAmount(amount),
        "currency" : currency,
        "payment_method_type[]":"card"
      };

      var response = await http.post(Uri.parse("https://api.stripe.com/v1/payment_intents"),
      body: body,
        headers: {
        "Authorization" : "Bearer sk_test_51OVVcyFiDaJ8bQBjNbxRzrInTwKZ0OX5zQ22QjOwJ5fBJEN4CJx1SkPmwCiDqmvO6UWOYuB5xMvV2SAjszbpCIDk009t0O7BqT",
          "Content-Type" : "application/x-www-form-urlencoded"
        }
      );

      return jsonDecode(response.body);
    }catch(e){
      print("error ===============$e");
    }
  }


  /// ------------------------display payment sheet ----------------------
  void displayPaymentSheet() async{
    try{
        await Stripe.instance.presentPaymentSheet();
        Get.snackbar("payment info", "payment succuss");
    }on Exception catch(e){
      if(e is Exception){
        print("error from Stripe ======++++++++++++$e");
      }else{
        print("unforneent error +++++++++++++++++++++++++$e");
      }
    }
  }


  /// ---------------------calculate amount ------------------------------>>>>
  calculateAmount(String amount) {
    final a = (int.parse(amount))*100;
    return a.toString();
  }
}

