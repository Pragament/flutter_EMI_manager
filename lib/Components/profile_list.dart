import 'dart:convert';
import 'package:emi_calculator/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/loan.dart';
import 'model/lend.dart';

bool updateProfileFlag = false;
int profileIndex = 0;
double? tYear = 0, irate = 0, lAmount;

class ProfileList extends StatefulWidget {
  const ProfileList({super.key});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  List<String>? myList = [];
  List<dynamic> profileList = [];
  List<dynamic> filteredList = [];
  late SharedPreferences sp;

  DateTimeRange? _dateRange;
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    getProfiles();
  }

  Future<void> getProfiles() async {
    sp = await SharedPreferences.getInstance();
    myList = sp.getStringList("profileList") ?? [];
    profileList = myList!.map((e) {
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
    setState(() {
      filteredList = profileList.where((profile) {
        bool dateMatch = true;
        bool typeMatch = _selectedType == 'All' ||
            (profile is Loan && _selectedType == 'Loan') ||
            (profile is Lend && _selectedType == 'Lend');

        if (_dateRange != null) {
          if (profile is Loan) {
            // Check if endDate is null
            if (profile.endDate != null) {
              dateMatch = profile.startDate.isAfter(_dateRange!.start) &&
                  profile.endDate!.isBefore(_dateRange!.end);
            } else {
              dateMatch = profile.startDate.isAfter(_dateRange!.start);
            }
          } else if (profile is Lend) {
            dateMatch = profile.lendDate.isAfter(_dateRange!.start) &&
                profile.lendDate.isBefore(_dateRange!.end);
          }
        }

        return dateMatch && typeMatch;
      }).toList();
    });
  }

  Future<void> showDateRangePickerDialog() async {
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _dateRange,
    );

    if (pickedDateRange != null && pickedDateRange != _dateRange) {
      setState(() {
        _dateRange = pickedDateRange;
        filterProfiles(); // Apply filters after selecting the date range
      });
    }
  }

  void deleteProfile(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            ElevatedButton(
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () => Navigator.pop(context),
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
                Navigator.pop(context);
                filterProfiles(); // Apply filters after deleting
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void updateProfile(int index) {
    setState(() {
      updateProfileFlag = true;
      profileIndex = index;
      if (profileList[index] is Loan) {
        tYear = (profileList[index] as Loan).tenure / 12.0;
        irate = (profileList[index] as Loan).interest;
        lAmount = (profileList[index] as Loan).amount;
      }
    });
    Navigator.popAndPushNamed(context, "/calculator");
  }

  double calculatePaidPercent(double paidAmount, double totalAmount) {
    if (totalAmount == 0) return 0;
    return (paidAmount / totalAmount) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: showDateRangePickerDialog,
                  child: Text(
                    _dateRange == null
                        ? 'Select Date Range'
                        : 'Date Range: ${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedType,
                  items: ['All', 'Loan', 'Lend']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      filterProfiles(); // Apply filters after selecting type
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                var profile = filteredList[index];
                if (profile is Loan) {
                  final totalAmount = profile.calculateTotalPayable();
                  final paidAmount = profile.paid;
                  final paidPercent =
                      calculatePaidPercent(paidAmount, totalAmount);

                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    '${profile.accountName} - ${profile.loanType}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text('Loan Amount ₹${profile.amount}'),
                                  trailing: Text(
                                      'Monthly EMI ₹${profile.calculateMonthlyEmi().toStringAsFixed(2)}'),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Payable ₹${totalAmount.toStringAsFixed(2)}'),
                                      Text(
                                          'Paid ₹${paidAmount.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 20.0,
                                      child: LinearProgressIndicator(
                                        value: totalAmount > 0
                                            ? paidPercent / 100
                                            : 0,
                                        backgroundColor: Colors.grey[200],
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: Text(
                                          '${paidPercent.toStringAsFixed(1)}% paid',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.5),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              child: Container(
                                height: 50,
                                color: tertiaryColor, // Color for Loan
                                child: PopupMenuButton<String>(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  color: Colors.white,
                                  onSelected: (String result) {
                                    if (result == 'edit') {
                                      updateProfile(index);
                                    } else if (result == 'delete') {
                                      deleteProfile(index);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (profile is Lend) {
                  final lendDate =
                      DateFormat('MMM d, yyyy').format(profile.lendDate);
                  final expectedReturnDate = DateFormat('MMM d, yyyy')
                      .format(profile.expectedReturnDate);

                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    profile.contactPerson,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Amount ₹${profile.amount}'),
                                  trailing: Text(
                                      '${profile.interest.toStringAsFixed(2)}%'),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Lend on',
                                          ),
                                          Text(lendDate,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Expected Return',
                                          ),
                                          Text(expectedReturnDate,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              child: Container(
                                height: 50,
                                color: secondaryColor, // Color for Lend
                                child: PopupMenuButton<String>(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  color: Colors.white,
                                  onSelected: (String result) {
                                    if (result == 'edit') {
                                      updateProfile(index);
                                    } else if (result == 'delete') {
                                      deleteProfile(index);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
