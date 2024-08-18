import 'package:emi_calculator/controller/loan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'model/loan.dart';

class AddLoan extends StatelessWidget {
  final Loan? loan;
  final String? loanId;
  final Function? actionCallback;

  AddLoan({this.loan, this.loanId, this.actionCallback, super.key});

  final LoanController controller = Get.put(LoanController());

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
      body: Obx(
        () => Column(
          children: <Widget>[
            Expanded(
              child: FormBuilder(
                key: controller.formKey,
                initialValue: {
                  'loanType': loanId != null ? loan?.loanType : 'Other Loan',
                  'accountName': loanId != null ? loan?.accountName : '',
                  'amount': loanId != null ? loan?.amount.toString() : '',
                  'tenure':
                      loanId != null ? (loan!.tenure / 12).toString() : '',
                  'interest': loanId != null ? loan?.interest.toString() : '',
                  'startDate':
                      loanId != null ? loan?.startDate : DateTime.now(),
                  // additional fields...
                },
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: controller.currentStep.value,
                  onStepContinue: controller.next,
                  onStepTapped: (step) => controller.goTo(step),
                  onStepCancel: controller.cancel,
                  steps: controller.getSteps(),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => controller.saveLoan(actionCallback),
                  child: const Text("Save"),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.formKey.currentState?.reset();
                  },
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
