import 'package:emi_calculator/Components/add_loan_screen.dart';
import 'package:emi_calculator/Components/calculator_interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculator/constants.dart';
import 'package:emi_calculator/controller/language_change_controller.dart';
import 'package:emi_calculator/Components/profile_list.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key, this.actionCallback});

  final Function? actionCallback; // Optional callback

  @override
  _LoanListScreenState createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/calculator');
          },
        ),
        actions: [
          Consumer<LanguageChangeController>(
            builder: (context, provider, child) {
              return PopupMenuButton<Language>(
                onSelected: (Language item) {
                  if (Language.english.name == item.name) {
                    provider.changeLanguage(const Locale("en"));
                  } else if (Language.hindi.name == item.name) {
                    provider.changeLanguage(const Locale("hi"));
                  } else {
                    provider.changeLanguage(const Locale("te"));
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<Language>>[
                  const PopupMenuItem(
                    value: Language.english,
                    child: Text("English"),
                  ),
                  const PopupMenuItem(
                    value: Language.hindi,
                    child: Text("Hindi"),
                  ),
                  const PopupMenuItem(
                    value: Language.telugu,
                    child: Text("Telugu"),
                  ),
                ],
              );
            },
          ),
        ],
        title: const Row(
          children: [
            Text(
              'Saved Loans',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(width: 8), // Space between texts
            Text(
              ' Saved Lends',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
      ),
      body: const ProfileList(),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/addLoan',
                  arguments: {'actionCallback': widget.actionCallback},
                );
              },
              heroTag: 'addLoanButton', // Unique heroTag
              backgroundColor: secondaryColor, // Set the background color
              label: const Text('Add New Loan'),
              icon: const Icon(Icons.add),
              // Set a consistent minimum size
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Positioned(
            bottom: 80, // Adjust this value to position the second FAB
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/addLend',
                  arguments: {'actionCallback': widget.actionCallback},
                );
              },
              heroTag: 'addLendLoanButton', // Unique heroTag
              backgroundColor: secondaryColor, // Set the background color
              label: const Text('Add Lend Loan'),
              icon: const Icon(Icons.add), // Use a different icon if needed
              // Set a consistent minimum size
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
