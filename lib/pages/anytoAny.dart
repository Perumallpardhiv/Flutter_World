import 'package:flutter/material.dart';

class AnyToAny extends StatefulWidget {
  final rates;
  final Map currencies;
  const AnyToAny({Key? key, @required this.rates, required this.currencies})
      : super(key: key);

  @override
  _AnyToAnyState createState() => _AnyToAnyState();
}

class _AnyToAnyState extends State<AnyToAny> {
  TextEditingController amountController = TextEditingController();

  String dropdownValue1 = 'AUD';
  String dropdownValue2 = 'AUD';
  String answer = 'Converted Currency :)';

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Card(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            TextFormField(
              key: ValueKey('amount'),
              controller: amountController,
              decoration: InputDecoration(hintText: 'Enter Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: dropdownValue1,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              iconSize: 24,
              elevation: 16,
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Colors.grey.shade400,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue1 = newValue!;
                });
              },
              items: widget.currencies.keys
                  .toSet()
                  .toList()
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Center(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('To', style: TextStyle(fontSize: 15),)),
            ),
            SizedBox(height: 15),
            DropdownButton<String>(
              value: dropdownValue2,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              iconSize: 24,
              elevation: 16,
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Colors.grey.shade400,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue2 = newValue!;
                });
              },
              items: widget.currencies.keys
                  .toSet()
                  .toList()
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    answer = amountController.text +
                        ' ' +
                        dropdownValue1 +
                        ' = ' +
                        convertany(widget.rates, amountController.text,
                            dropdownValue1, dropdownValue2) +
                        ' ' +
                        dropdownValue2;
                  });
                },
                child: Text('Convert'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor)),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(height: 10),
            Center(child: Text(answer)),
          ],
        ),
      ),
    );
  }
}

String convertany(Map exchangeRates, String amount, String currencybase,
    String currencyfinal) {
  String output = (double.parse(amount) /
          exchangeRates[currencybase] *
          exchangeRates[currencyfinal])
      .toStringAsFixed(2)
      .toString();

  return output;
}
