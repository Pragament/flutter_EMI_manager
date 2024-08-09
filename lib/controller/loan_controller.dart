import 'dart:convert';
import 'package:emi_calculator/Components/model/loan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanController extends GetxController {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxInt currentStep = 0.obs;
  final RxBool complete = false.obs;

  final RxString loanTenureLabel = 'Year'.obs;
  int tenureMultiple = 12;

  // Focus nodes
  final FocusNode loanTypeFocus = FocusNode();
  final FocusNode accountNameFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();
  final FocusNode tenureFocus = FocusNode();
  final FocusNode interestFocus = FocusNode();
  final FocusNode startDateFocus = FocusNode();

  @override
  void onClose() {
    loanTypeFocus.dispose();
    accountNameFocus.dispose();
    amountFocus.dispose();
    tenureFocus.dispose();
    interestFocus.dispose();
    startDateFocus.dispose();
    super.onClose();
  }

  void saveLoan(Function? actionCallback) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      var formData = formKey.currentState!.value;

      // Create a new Loan object
      Loan newLoan = Loan(
        loanType: formData['loanType'],
        accountName: formData['accountName'],
        amount: double.parse(formData['amount']),
        tenure: int.parse(formData['tenure']) * tenureMultiple,
        interest: double.parse(formData['interest']),
        startDate: formData['startDate'],
      );

      // Save the new loan to SharedPreferences
      SharedPreferences sp = await SharedPreferences.getInstance();
      List<String> storedLoans = sp.getStringList('profileList') ?? [];
      storedLoans.add(jsonEncode(newLoan.toJson()));
      await sp.setStringList('profileList', storedLoans);

      // Call the action callback if provided
      actionCallback?.call();

      // Navigate back to the previous screen
      Get.back();
    }
  }

  void next() {
    if (currentStep.value + 1 < getSteps().length) {
      goTo(currentStep.value + 1);
    } else {
      complete.value = true;
    }
  }

  void cancel() {
    if (currentStep.value > 0) {
      goTo(currentStep.value - 1);
    }
  }

  void goTo(int step) {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      currentStep.value = step;
    }
  }

  void toggleTenureLabel() {
    if (loanTenureLabel.value == 'Month') {
      loanTenureLabel.value = 'Year';
      tenureMultiple = 12;
    } else {
      loanTenureLabel.value = 'Month';
      tenureMultiple = 1;
    }
  }

  List<Step> getSteps() {
    return [
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
              onEditingComplete: () => Get.focusScope?.nextFocus(),
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
              onEditingComplete: () => Get.focusScope?.nextFocus(),
            ),
            FormBuilderTextField(
              name: "tenure",
              focusNode: tenureFocus,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Loan Tenure",
                prefixIcon: const Icon(Icons.timer),
                suffixText: loanTenureLabel.value,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: toggleTenureLabel,
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(1),
                FormBuilderValidators.max(40 * 12),
              ]),
              onEditingComplete: () => Get.focusScope?.nextFocus(),
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
              onEditingComplete: () => Get.focusScope?.nextFocus(),
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
      // Add more steps if needed
    ];
  }
}
