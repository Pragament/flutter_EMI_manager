import 'package:emi_calculator/Components/model/lend.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddLend extends StatefulWidget {
  final Lend? lend;
  final String? lendId;
  final Function? actionCallback;

  const AddLend({super.key, this.lend, this.lendId, this.actionCallback});

  @override
  _AddLendState createState() => _AddLendState();
}

class _AddLendState extends State<AddLend> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final FocusNode amountFocus = FocusNode();
  final FocusNode interestFocus = FocusNode();
  final FocusNode startDateFocus = FocusNode();
  final FocusNode returnDateFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode contactPersonFocus = FocusNode();
  final FocusNode otherLoanInfoFocus = FocusNode();

  @override
  void dispose() {
    amountFocus.dispose();
    interestFocus.dispose();
    startDateFocus.dispose();
    returnDateFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    contactPersonFocus.dispose();
    otherLoanInfoFocus.dispose();
    super.dispose();
  }

  String? phoneValidator(String? value) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void saveLend() async {
    if (_fbKey.currentState?.saveAndValidate() ?? false) {
      // Convert the form data into a Lend object
      var formData = _fbKey.currentState!.value;
      Lend newLend = Lend(
        contactPerson: formData['contactPerson'],
        amount: double.parse(formData['amount']),
        interest: double.parse(formData['interest']),
        lendDate: formData['lendDate'],
        expectedReturnDate: formData['expectedReturnDate'],
        phone: formData['phone'],
        email: formData['email'],
        otherLoanInfo: formData['otherLoanInfo'],
      );

      // Save to SharedPreferences under "profileList" key
      SharedPreferences sp = await SharedPreferences.getInstance();
      List<String>? storedProfiles = sp.getStringList('profileList') ?? [];
      storedProfiles.add(jsonEncode(newLend.toJson()));
      await sp.setStringList('profileList', storedProfiles);

      // Optionally, call a callback
      widget.actionCallback?.call();

      // Optionally, navigate back or show a success message
      Navigator.of(context).pop(); // or show a SnackBar, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Lend'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FormBuilder(
              key: _fbKey,
              initialValue: {
                'amount': widget.lend?.amount.toString(),
                'interest': widget.lend?.interest.toString() ?? '0.0',
                'phone': widget.lend?.phone ?? '',
                'email': widget.lend?.email ?? '',
                'contactPerson': widget.lend?.contactPerson ?? '',
                'otherLoanInfo': widget.lend?.otherLoanInfo ?? '',
              },
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: [
                  FormBuilderTextField(
                    name: "contactPerson",
                    focusNode: contactPersonFocus,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Contact Person*",
                      prefixIcon: Icon(Icons.contacts),
                    ),
                    validator: FormBuilderValidators.required(),
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(amountFocus),
                  ),
                  FormBuilderTextField(
                    name: "amount",
                    focusNode: amountFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Loan Amount*",
                      prefixIcon: Icon(Icons.money),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(100),
                      FormBuilderValidators.max(10000000),
                    ]),
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(interestFocus),
                  ),
                  FormBuilderTextField(
                    name: "interest",
                    focusNode: interestFocus,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Loan Interest (in %)*",
                      prefixIcon: Icon(Icons.percent),
                    ),
                    validator: FormBuilderValidators.numeric(),
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(startDateFocus),
                  ),
                  FormBuilderDateTimePicker(
                    name: "lendDate",
                    focusNode: startDateFocus,
                    textInputAction: TextInputAction.next,
                    inputType: InputType.date,
                    format: DateFormat("dd-MMM-yyyy"),
                    decoration: const InputDecoration(
                      labelText: "Lend Date*",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  FormBuilderDateTimePicker(
                    name: "expectedReturnDate",
                    focusNode: returnDateFocus,
                    textInputAction: TextInputAction.next,
                    inputType: InputType.date,
                    format: DateFormat("dd-MMM-yyyy"),
                    decoration: const InputDecoration(
                      labelText: "Expected Return Date",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  FormBuilderPhoneField(
                    name: "phone",
                    focusNode: phoneFocus,
                    keyboardType: TextInputType.phone,
                    defaultSelectedCountryIsoCode: 'IN',
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: phoneValidator,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(emailFocus),
                  ),
                  FormBuilderTextField(
                    name: "email",
                    focusNode: emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: FormBuilderValidators.email(),
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(otherLoanInfoFocus),
                  ),
                  FormBuilderTextField(
                    name: "otherLoanInfo",
                    focusNode: otherLoanInfoFocus,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "Additional Info",
                      prefixIcon: Icon(Icons.more),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Text color
                        ),
                        onPressed: saveLend,
                        child: const Text("Save"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Background color
                        ),
                        onPressed: () {
                          _fbKey.currentState?.reset();
                        },
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
