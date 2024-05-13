import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:emi_calculator/Components/loan_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculator/controller/language_change_controller.dart';

bool updateProfileFlag = false;
int profileIndex = 0;
double? tYear = 0, irate = 0, lAmount;

enum Language { english, hindi, telugu }

class ProfileList extends StatefulWidget {
  const ProfileList({super.key});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  List<String>? myList = List.empty(growable: true);
  List<LoanProfile> profileList = List.empty(growable: true);
  late SharedPreferences sp;

  void getProfiles() async {
    sp = await SharedPreferences.getInstance();
    myList = sp.getStringList("profileList");
    if (myList != null) {
      profileList =
          myList!.map((e) => LoanProfile.fromJson(json.decode(e))).toList();
    }

    setState(() {});
  }

  @override
  void initState() {
    getProfiles();
    super.initState();
  }

  void deleteProfile(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.addProfile),
            actions: [
              ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  onPressed: () {
                    profileList.removeAt(index);
                    List<String> data =
                        profileList.map((e) => jsonEncode(e.toJson())).toList();
                    sp.setStringList("profileList", data);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text(AppLocalizations.of(context)!.delete))
            ],
          );
        });
  }

  void updateProfile(int index) {
    setState(() {
      updateProfileFlag = true;
      profileIndex = index;
      tYear = double.parse(profileList[index].tenureInYears!);
      irate = double.parse(profileList[index].intrestrate!);
      lAmount = double.parse(profileList[index].loanvalue!);
    });
    Navigator.popAndPushNamed(context, "/calculator");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.popAndPushNamed(context, "/calculator");
            },
          ),
          actions: [
            Consumer<LanguageChangeController>(
                builder: (context, provider, child) {
              return PopupMenuButton(
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
                            value: Language.english, child: Text("English")),
                        const PopupMenuItem(
                            value: Language.hindi, child: Text("hindi")),
                        const PopupMenuItem(
                            value: Language.telugu, child: Text("telugu"))
                      ]);
            })
          ],
        ),
        body: ListView.builder(
            itemCount: profileList.length,
            itemBuilder: (context, index) => LoanProfile(
                  dateTime: profileList[index].dateTime,
                  profilename: profileList[index].profilename,
                  totalAmount: profileList[index].totalAmount,
                  totalIntrestAmount: profileList[index].totalIntrestAmount,
                  monthlyEmi: profileList[index].monthlyEmi,
                  tenureInYears: profileList[index].tenureInYears,
                  intrestrate: profileList[index].intrestrate,
                  loanvalue: profileList[index].loanvalue,
                  id: index,
                  delete: deleteProfile,
                  update: updateProfile,
                )));
  }
}
