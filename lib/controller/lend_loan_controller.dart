import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:emi_calculator/Components/model/lend.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class LendController extends GetxController {
  final GlobalKey<FormBuilderState> fbKey = GlobalKey<FormBuilderState>();

  // FocusNodes
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

  void saveLend(Function? actionCallback) async {
    if (fbKey.currentState?.saveAndValidate() ?? false) {
      var formData = fbKey.currentState!.value;
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

      SharedPreferences sp = await SharedPreferences.getInstance();
      List<String>? storedProfiles = sp.getStringList('profileList') ?? [];
      storedProfiles.add(jsonEncode(newLend.toJson()));
      await sp.setStringList('profileList', storedProfiles);

      actionCallback?.call();
      Get.back();
    }
  }

  // Form field configurations
  FormBuilderTextField contactPersonField(BuildContext context) {
    return FormBuilderTextField(
      name: "contactPerson",
      focusNode: contactPersonFocus,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: "Contact Person*",
        prefixIcon: Icon(Icons.contacts),
      ),
      validator: FormBuilderValidators.required(),
      onEditingComplete: () => FocusScope.of(context).requestFocus(amountFocus),
    );
  }

  FormBuilderTextField amountField(BuildContext context) {
    return FormBuilderTextField(
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
    );
  }

  FormBuilderTextField interestField(BuildContext context) {
    return FormBuilderTextField(
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
    );
  }

  FormBuilderDateTimePicker lendDateField() {
    return FormBuilderDateTimePicker(
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
    );
  }

  FormBuilderDateTimePicker expectedReturnDateField() {
    return FormBuilderDateTimePicker(
      name: "expectedReturnDate",
      focusNode: returnDateFocus,
      textInputAction: TextInputAction.next,
      inputType: InputType.date,
      format: DateFormat("dd-MMM-yyyy"),
      decoration: const InputDecoration(
        labelText: "Expected Return Date",
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  FormBuilderTextField phoneField(BuildContext context) {
    return FormBuilderTextField(
      name: "phone",
      focusNode: phoneFocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: "Phone Number",
        prefixIcon: Icon(Icons.phone),
      ),
      validator: phoneValidator,
      onEditingComplete: () => FocusScope.of(context).requestFocus(emailFocus),
    );
  }

  FormBuilderTextField emailField(BuildContext context) {
    return FormBuilderTextField(
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
    );
  }

  FormBuilderTextField otherLoanInfoField() {
    return FormBuilderTextField(
      name: "otherLoanInfo",
      focusNode: otherLoanInfoFocus,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        labelText: "Additional Info",
        prefixIcon: Icon(Icons.more),
      ),
    );
  }
}
