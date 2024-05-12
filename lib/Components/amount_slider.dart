import 'package:flutter/material.dart';

class AmountSlider extends StatefulWidget {
  final String title;
  final double amount, min, max;
  final Function(double, int) updateValue;
  final int id;

  const AmountSlider(
      {super.key,
      required this.amount,
      required this.min,
      required this.max,
      required this.updateValue,
      required this.id,
      required this.title});

  @override
  State<AmountSlider> createState() => _AmountSliderState();
}

class _AmountSliderState extends State<AmountSlider> {
  double? amount;

  @override
  void initState() {
    super.initState();
    amount = widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 251, 238, 255),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title),
              Container(
                height: 30,
                width: 100,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Center(
                  child: Text(widget.id == 3
                      ? amount!.toStringAsFixed(2)
                      : "${amount!.toInt()}"),
                ),
              ),
            ],
          ),
          Slider(
              value: amount!,
              min: widget.min,
              max: widget.max,
              onChanged: (newValue) {
                amount = newValue;
                widget.updateValue(newValue, widget.id);
                setState(() {});
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.min.toInt()}"),
                Text("${widget.max.toInt()}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
