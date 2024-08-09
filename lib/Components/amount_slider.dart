import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AmountSlider extends StatefulWidget {
  final String title;
  final double amount, min, max;
  final Function(double, int) updateValue;
  final int id;

  const AmountSlider({
    super.key,
    required this.amount,
    required this.min,
    required this.max,
    required this.updateValue,
    required this.id,
    required this.title,
    required String unit,
  });

  @override
  State<AmountSlider> createState() => _AmountSliderState();
}

class _AmountSliderState extends State<AmountSlider> {
  double? amount;
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Ensure `amount` is within the range
    amount = widget.amount.clamp(widget.min, widget.max);
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
                height: 40,
                width: 150,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Form(
                            key: _formKey,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.enterAmount,
                              ),
                              controller: _textController,
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == '' ||
                                    double.tryParse(value!) == null ||
                                    double.parse(value) < widget.min ||
                                    double.parse(value) > widget.max) {
                                  return "Please enter a valid value";
                                }
                                return null;
                              },
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () {
                                _textController.text = "";
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  double newAmount =
                                      double.parse(_textController.text);
                                  // Ensure `newAmount` is within the range
                                  amount =
                                      newAmount.clamp(widget.min, widget.max);
                                  widget.updateValue(amount!, widget.id);
                                  _textController.text = "";
                                  setState(() {});
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.save),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    widget.id == 3
                        ? amount!.toStringAsFixed(2)
                        : indianFormatNumber(amount!, widget.id),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: amount!,
            min: widget.min,
            max: widget.max,
            onChanged: (newValue) {
              // Ensure `newValue` is within the range
              amount = newValue.clamp(widget.min, widget.max);
              widget.updateValue(amount!, widget.id);
              setState(() {});
            },
          ),
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

  String indianFormatNumber(double amount, int id) {
    if (id == 2) return amount.toInt().toString();
    String format =
        NumberFormat.currency(locale: 'HI', symbol: '₹ ', decimalDigits: 0)
            .format(amount.toInt())
            .toString();
    return format;
  }
}
