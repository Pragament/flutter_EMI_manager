import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class LoanProfile extends StatelessWidget {
  String? dateTime,
      profilename,
      totalAmount,
      totalIntrestAmount,
      tenureInYears,
      monthlyEmi;

  final int? id;

  final Function(int)? delete;
  final Function(int)? update;

  LoanProfile({
    super.key,
    this.dateTime,
    this.profilename,
    this.totalAmount,
    this.totalIntrestAmount,
    this.monthlyEmi,
    this.tenureInYears,
    this.id,
    this.delete,
    this.update,
  });

  factory LoanProfile.fromJson(Map<String, dynamic> json) => LoanProfile(
        dateTime: json["dateTime"],
        profilename: json["profilename"],
        totalAmount: json["totalAmount"],
        totalIntrestAmount: json["totalIntrestAmount"],
        tenureInYears: json["tenureInYears"],
        monthlyEmi: json["monthlyEmi"],
        id: json["id"],
        delete: (int) => dynamic,
        update: (int) => dynamic,
      );

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime,
        "profilename": profilename,
        "totalAmount": totalAmount,
        "totalIntrestAmount": totalIntrestAmount,
        "tenureInYears": tenureInYears,
        "monthlyEmi": monthlyEmi
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 238, 255),
          border: Border.all(width: 1, color: Colors.purple)),
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profilename!,
                  style: const TextStyle(fontSize: 25),
                ),
                Text(dateTime!)
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${AppLocalizations.of(context)!.loanEmi} : $monthlyEmi"),
              Text("${AppLocalizations.of(context)!.tenure} : $tenureInYears")
            ],
          ),
          Text("${AppLocalizations.of(context)!.totalPayment} : $totalAmount"),
          Text(
              "${AppLocalizations.of(context)!.totalIntrest} : $totalIntrestAmount"),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      delete!(id!);
                    },
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    child: const Text("Delete")),
                ElevatedButton(
                    onPressed: () {
                      update!(id!);
                    },
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    child: const Text("Edit"))
              ],
            ),
          )
        ],
      ),
    );
  }
}
