import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:emi_calculator/Components/model/lend.dart';
import 'package:emi_calculator/controller/lend_loan_controller.dart';

class AddLend extends StatelessWidget {
  final Lend? lend;
  final String? lendId;
  final Function? actionCallback;

  AddLend({super.key, this.lend, this.lendId, this.actionCallback});

  final LendController _lendController = Get.put(LendController());

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
              key: _lendController.fbKey,
              initialValue: {
                'amount': lend?.amount.toString(),
                'interest': lend?.interest.toString() ?? '0.0',
                'phone': lend?.phone ?? '',
                'email': lend?.email ?? '',
                'contactPerson': lend?.contactPerson ?? '',
                'otherLoanInfo': lend?.otherLoanInfo ?? '',
              },
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: [
                  _lendController.contactPersonField(context),
                  _lendController.amountField(context),
                  _lendController.interestField(context),
                  _lendController.lendDateField(),
                  _lendController.expectedReturnDateField(),
                  _lendController.phoneField(context),
                  _lendController.emailField(context),
                  _lendController.otherLoanInfoField(),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () =>
                            _lendController.saveLend(actionCallback),
                        child: const Text("Save"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          _lendController.fbKey.currentState?.reset();
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
