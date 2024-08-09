import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/loan.dart';
import 'dart:math';

class AddLoan extends StatefulWidget {
  final Loan? loan;
  final String? loanId;
  final Function? actionCallback;

  const AddLoan({this.loan, this.loanId, this.actionCallback, super.key});

  @override
  _AddLoanState createState() => _AddLoanState();
}

class _AddLoanState extends State<AddLoan> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  late FocusNode loanTypeFocus;
  late FocusNode accountNameFocus;
  late FocusNode amountFocus;
  late FocusNode tenureFocus;
  late FocusNode interestFocus;
  late FocusNode startDateFocus;

  String loanTenureLabel = 'Year';
  int tenureMultiple = 12;

  int currentStep = 0;
  bool complete = false;

  List<Step> steps = [];

  @override
  void initState() {
    super.initState();
    loanTypeFocus = FocusNode();
    accountNameFocus = FocusNode();
    amountFocus = FocusNode();
    tenureFocus = FocusNode();
    interestFocus = FocusNode();
    startDateFocus = FocusNode();

    steps = [
      Step(
        title: const Text('Required*'),
        content: Column(
          children: [
            FormBuilderDropdown<String>(
              name: "loanType",
              focusNode: loanTypeFocus,
              decoration: const InputDecoration(
                labelText: "Loan Type",
                prefixIcon: Icon(Icons.search),
              ),
              validator: FormBuilderValidators.required(),
              items: [
                'Personal Loan',
                'Home Loan',
                'Gold Loan',
                'Auto Loan',
                'Education Loan',
                'Other Loan'
              ]
                  .map((loanType) =>
                      DropdownMenuItem(value: loanType, child: Text(loanType)))
                  .toList(),
            ),
            FormBuilderTextField(
              name: "accountName",
              focusNode: accountNameFocus,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Account's Nick Name",
                prefixIcon: Icon(Icons.account_circle),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(2),
                FormBuilderValidators.maxLength(25),
              ]),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            FormBuilderTextField(
              name: "amount",
              focusNode: amountFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Principal Loan Amount",
                prefixIcon: Icon(Icons.money),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(500),
                FormBuilderValidators.max(10000000),
              ]),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            FormBuilderTextField(
              name: "tenure",
              focusNode: tenureFocus,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Loan Tenure",
                prefixIcon: const Icon(Icons.timer),
                suffixText: loanTenureLabel,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => setState(() {
                    if (loanTenureLabel == 'Month') {
                      loanTenureLabel = 'Year';
                      tenureMultiple = 12;
                    } else {
                      loanTenureLabel = 'Month';
                      tenureMultiple = 1;
                    }
                  }),
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(1),
                FormBuilderValidators.max(40 * 12),
              ]),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            FormBuilderTextField(
              name: "interest",
              focusNode: interestFocus,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Loan Interest (in %)",
                prefixIcon: Icon(Icons.percent),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(6.0),
                FormBuilderValidators.max(40),
              ]),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            FormBuilderDateTimePicker(
              name: "startDate",
              focusNode: startDateFocus,
              textInputAction: TextInputAction.done,
              inputType: InputType.date,
              format: DateFormat("dd-MMM-yyyy"),
              decoration: const InputDecoration(
                labelText: "Loan Start Date",
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: FormBuilderValidators.required(),
            ),
          ],
        ),
      ),
      // Additional steps...
    ];
  }

  void saveLoan() async {
    if (_fbKey.currentState?.saveAndValidate() ?? false) {
      // Convert the form data into a Loan object
      var formData = _fbKey.currentState!.value;
      Loan newLoan = Loan(
        loanType: formData['loanType'],
        accountName: formData['accountName'],
        amount: double.parse(formData['amount']),
        tenure: int.parse(formData['tenure']) *
            tenureMultiple, // Convert years to months if needed
        interest: double.parse(formData['interest']),
        startDate: formData['startDate'],
      );

      // Save to SharedPreferences
      SharedPreferences sp = await SharedPreferences.getInstance();
      List<String>? storedLoans = sp.getStringList('profileList') ?? [];
      storedLoans.add(jsonEncode(newLoan.toJson()));
      await sp.setStringList('profileList', storedLoans);

      // Notify ProfileList to update
      widget.actionCallback?.call(); // Call the callback to refresh data

      // Optionally, navigate back or show a success message
      Navigator.of(context).pop();
    }
  }

  next() {
    if (currentStep + 1 < steps.length) {
      goTo(currentStep + 1);
    } else {
      setState(() => complete = true);
    }
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    if (_fbKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        currentStep = step;
      });
    }
  }

  @override
  void dispose() {
    loanTypeFocus.dispose();
    accountNameFocus.dispose();
    amountFocus.dispose();
    tenureFocus.dispose();
    interestFocus.dispose();
    startDateFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Add new Loan'),
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
                'loanType': widget.loanId != null
                    ? widget.loan?.loanType
                    : 'Other Loan',
                'accountName':
                    widget.loanId != null ? widget.loan?.accountName : '',
                'amount':
                    widget.loanId != null ? widget.loan?.amount.toString() : '',
                'tenure': widget.loanId != null
                    ? (widget.loan!.tenure / 12).toString()
                    : '',
                'interest': widget.loanId != null
                    ? widget.loan?.interest.toString()
                    : '',
                'startDate': widget.loanId != null
                    ? widget.loan?.startDate
                    : DateTime.now(),
                // additional fields...
              },
              child: Stepper(
                type: StepperType.vertical,
                currentStep: currentStep,
                onStepContinue: () {
                  print('Current Step: $currentStep'); // Debug print
                  if (_fbKey.currentState?.saveAndValidate() ?? false) {
                    next();
                  } else {
                    print('Validation failed'); // Debug print
                  }
                },
                onStepTapped: (step) {
                  print('Tapped Step: $step'); // Debug print
                  goTo(step);
                },
                onStepCancel: () {
                  print('Current Step on Cancel: $currentStep'); // Debug print
                  cancel();
                },
                steps: steps,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed:
                    saveLoan, // Fix: pass the function reference, not call it
                child: const Text("Save"),
              ),
              ElevatedButton(
                onPressed: () {
                  print('Reset action triggered'); // Debug print
                  _fbKey.currentState?.reset();
                },
                child: const Text("Reset"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
