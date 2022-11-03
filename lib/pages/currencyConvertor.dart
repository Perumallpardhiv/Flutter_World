import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_firebase/app/model/allcurrencies.dart';
import 'package:todo_firebase/app/model/ratesModels.dart';
import 'package:http/http.dart' as http;
import 'package:todo_firebase/app/utils/key.dart';
import 'package:todo_firebase/pages/anytoAny.dart';

class currency extends StatefulWidget {
  const currency({super.key});

  @override
  State<currency> createState() => _currencyState();
}

Future<RatesModel> fetchrates() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/latest.json?base=USD&app_id=' + key));
  final result = ratesModelFromJson(response.body);
  return result;
}

Future<Map> fetchcurrencies() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/currencies.json?app_id=' + key));
  final allCurrencies = allCurrenciesFromJson(response.body);
  return allCurrencies;
}

class _currencyState extends State<currency> {
  late Future<RatesModel> result;
  late Future<Map> allcurrencies;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      result = fetchrates();
      allcurrencies = fetchcurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Get.isDarkMode
                ? [
                    Color.fromARGB(255, 66, 66, 66),
                    Color.fromARGB(255, 52, 52, 52),
                  ]
                : [
                    Color.fromARGB(255, 147, 200, 243),
                    Color.fromARGB(255, 89, 147, 195),
                  ],
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
          ),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Currency Convertor',
              style: GoogleFonts.lato(
                  fontSize: 25,
                  color: Get.isDarkMode ? Colors.white : Colors.black),
            ),
            SingleChildScrollView(
              child: Form(
                key: formkey,
                child: FutureBuilder<RatesModel>(
                  future: result,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Center(
                      child: FutureBuilder<Map>(
                          future: allcurrencies,
                          builder: (context, currSnapshot) {
                            if (currSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnyToAny(
                                  currencies: currSnapshot.data!,
                                  rates: snapshot.data!.rates,
                                ),
                              ],
                            );
                          }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
