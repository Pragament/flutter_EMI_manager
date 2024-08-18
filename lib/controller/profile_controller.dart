import 'dart:convert';
import 'package:emi_calculator/Components/model/lend.dart';
import 'package:emi_calculator/Components/model/loan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  RxList<dynamic> profileList = <dynamic>[].obs;
  RxList<dynamic> filteredList = <dynamic>[].obs;
  Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  RxString selectedType = 'All'.obs;
  late SharedPreferences sp;

  @override
  void onInit() {
    super.onInit();
    getProfiles(); // Load profiles when the controller is initialized
  }

  Future<void> getProfiles() async {
    sp = await SharedPreferences.getInstance();
    List<String>? myList = sp.getStringList("profileList") ?? [];
    profileList.value = myList.map((e) {
      final data = json.decode(e);
      if (data['loanType'] != null) {
        return Loan.fromJson(data);
      } else {
        return Lend.fromJson(data);
      }
    }).toList();
    filterProfiles(); // Apply filters after loading profiles
  }

  void filterProfiles() {
    filteredList.value = profileList.where((profile) {
      bool dateMatch = true;
      bool typeMatch = selectedType.value == 'All' ||
          (profile is Loan && selectedType.value == 'Loan') ||
          (profile is Lend && selectedType.value == 'Lend');

      if (dateRange.value != null) {
        if (profile is Loan) {
          if (profile.endDate != null) {
            dateMatch = profile.startDate.isAfter(dateRange.value!.start) &&
                profile.endDate!.isBefore(dateRange.value!.end);
          } else {
            dateMatch = profile.startDate.isAfter(dateRange.value!.start);
          }
        } else if (profile is Lend) {
          dateMatch = profile.lendDate.isAfter(dateRange.value!.start) &&
              profile.lendDate.isBefore(dateRange.value!.end);
        }
      }

      return dateMatch && typeMatch;
    }).toList();
  }

  Future<void> showDateRangePickerDialog(BuildContext context) async {
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: dateRange.value,
    );

    if (pickedDateRange != null && pickedDateRange != dateRange.value) {
      dateRange.value = pickedDateRange;
      filterProfiles(); // Apply filters after selecting the date range
    }
  }

  void deleteProfile(int index) {
    Get.dialog(
      AlertDialog(
        actions: [
          ElevatedButton(
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: () {
              profileList.removeAt(index);
              List<String> data =
                  profileList.map((e) => jsonEncode(e.toJson())).toList();
              sp.setStringList("profileList", data);
              Get.back();
              filterProfiles(); // Apply filters after deleting
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void updateProfile(int index) {
    var profile = profileList[index];
    if (profile is Loan) {
      Get.find<CalculatorController>().updateLoanDetails(profile);
    }
    Get.toNamed("/calculator");
  }

  double calculatePaidPercent(double paidAmount, double totalAmount) {
    if (totalAmount == 0) return 0;
    return (paidAmount / totalAmount) * 100;
  }
}

class CalculatorController extends GetxController {
  RxDouble tYear = 0.0.obs;
  RxDouble irate = 0.0.obs;
  RxDouble lAmount = 0.0.obs;

  void updateLoanDetails(Loan loan) {
    tYear.value = loan.tenure / 12.0;
    irate.value = loan.interest;
    lAmount.value = loan.amount;
  }
}
