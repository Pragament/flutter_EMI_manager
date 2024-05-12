import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:emi_calculator/controller/language_change_controller.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculator/Components/amount_slider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:emi_calculator/Components/loan_profile.dart';
import 'package:emi_calculator/Components/profile_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { english, hindi, telugu }

class CalculatorInterface extends StatefulWidget {
  const CalculatorInterface({super.key});

  @override
  State<CalculatorInterface> createState() => _CalculatorInterfaceState();
}

class _CalculatorInterfaceState extends State<CalculatorInterface> {
  late double monthlyEmi, totalIntrest = 0, totalPayment = 0, years = 0;

  final TextEditingController _textController = TextEditingController();

  double loanAmount = 1000000, intrestRate = 7.5, loanTenure = 15;

  late SharedPreferences sp;

  final _formKey = GlobalKey<FormState>();

  List<String>? profileList = List.empty(growable: true);
  List<LoanProfile> myList = List.empty(growable: true);

  void getProfiles() async {
    sp = await SharedPreferences.getInstance();
    profileList = sp.getStringList("profileList");
    if (profileList != null) {
      myList = profileList!
          .map((e) => LoanProfile.fromJson(json.decode(e)))
          .toList();
    }
    setState(() {});
  }

  void updateValue(double value, int id) {
    setState(() {
      if (id == 1) {
        loanAmount = value;
      } else if (id == 2) {
        loanTenure = value;
      } else if (id == 3) {
        intrestRate = value;
      }
    });
    calculateTotal();
  }

  void calculateTotal() {
    double mothlyIntrest = (intrestRate / 12) / 100;
    double months = loanTenure * 12;
    monthlyEmi = loanAmount *
        mothlyIntrest *
        pow((1 + mothlyIntrest), months) /
        (pow((1 + mothlyIntrest), months) - 1);

    totalPayment = monthlyEmi * months;

    totalIntrest = totalPayment - loanAmount;

    years = loanTenure;

    setState(() {});
  }

  void instantiate() async {
    sp = await SharedPreferences.getInstance();
  }

  void update() {
    if (myList.isNotEmpty) {
      setState(() {
        updateProfileFlag = false;
        myList[profileIndex].dateTime =
            DateFormat('\tkk:mm:ss\nEEE d MMM yyyy').format(DateTime.now());
        myList[profileIndex].totalAmount = totalPayment.toInt().toString();
        myList[profileIndex].totalIntrestAmount =
            totalIntrest.toStringAsFixed(2);
        myList[profileIndex].tenureInYears = years.toInt().toString();
        myList[profileIndex].monthlyEmi = monthlyEmi.toInt().toString();
        List<String> data = myList.map((e) => jsonEncode(e.toJson())).toList();
        sp.setStringList("profileList", data);
      });
      Navigator.pushNamedAndRemoveUntil(
          context, "/profiles", ModalRoute.withName('/calculator'));
    }
  }

  @override
  void initState() {
    instantiate();
    getProfiles();
    calculateTotal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lang),
        actions: [
          !updateProfileFlag
              ? TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/profiles');
                  },
                  child: Text(AppLocalizations.of(context)!.profile))
              : Text("is $updateProfileFlag"),
          Consumer<LanguageChangeController>(
              builder: (context, provide, child) {
            return PopupMenuButton(
                onSelected: (Language item) {
                  if (Language.english.name == item.name) {
                    provide.changeLanguage(const Locale("en"));
                  } else if (Language.hindi.name == item.name) {
                    provide.changeLanguage(const Locale("hi"));
                  } else {
                    provide.changeLanguage(const Locale("te"));
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<Language>>[
                      const PopupMenuItem(
                          value: Language.english, child: Text("English")),
                      const PopupMenuItem(
                          value: Language.hindi, child: Text("Hindi")),
                      const PopupMenuItem(
                          value: Language.telugu, child: Text("Telugu")),
                    ]);
          })
        ],
      ),
      body: Center(
        child: Column(children: [
          AmountSlider(
              id: 1,
              min: 100000,
              max: 100000000,
              amount: loanAmount,
              updateValue: updateValue,
              title: AppLocalizations.of(context)!.loanAmount),
          AmountSlider(
              id: 2,
              min: 1,
              max: 30,
              amount: loanTenure,
              updateValue: updateValue,
              title: AppLocalizations.of(context)!.tenure),
          AmountSlider(
              id: 3,
              min: 1,
              max: 15,
              amount: intrestRate,
              updateValue: updateValue,
              title: AppLocalizations.of(context)!.intrest),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 50,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.loanEmi),
                        Text("${monthlyEmi.toInt()}")
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 50,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.totalIntrest),
                        Text(totalIntrest.toStringAsFixed(2))
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 50,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.totalPayment),
                        Text("${totalPayment.toInt()}")
                      ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  !updateProfileFlag
                      ? showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context)!.addProfile),
                              content: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _textController,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .enterProfile),
                                  validator: (value) => value == ""
                                      ? "Please enter profile name"
                                      : null,
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel)),
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        myList.add(LoanProfile(
                                          dateTime: DateFormat(
                                                  '\tkk:mm:ss\nEEE d MMM yyyy')
                                              .format(DateTime.now()),
                                          profilename: _textController.text,
                                          totalAmount:
                                              totalPayment.toInt().toString(),
                                          totalIntrestAmount:
                                              totalIntrest.toInt().toString(),
                                          tenureInYears:
                                              years.toInt().toString(),
                                          monthlyEmi:
                                              monthlyEmi.toInt().toString(),
                                        ));

                                        List<String> data = myList
                                            .map((e) => jsonEncode(e.toJson()))
                                            .toList();

                                        setState(() {
                                          sp.setStringList("profileList", data);
                                          _textController.text = "";
                                        });

                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.save))
                              ],
                            );
                          })
                      : update();
                },
                child: Text(AppLocalizations.of(context)!.saveProfile)),
          )
        ]),
      ),
    );
  }
}
