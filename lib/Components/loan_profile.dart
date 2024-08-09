import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class LoanProfile extends StatelessWidget {
  String? dateTime, profilename, tenureInYears;
  double? totalIntrestAmount, totalAmount, monthlyEmi, intrestrate, loanvalue;
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
    this.intrestrate,
    this.loanvalue,
    this.id,
    this.delete,
    this.update,
  });

  factory LoanProfile.fromJson(Map<String, dynamic> json) {
    return LoanProfile(
      dateTime: json['dateTime'],
      profilename: json['profilename'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      totalIntrestAmount: (json['totalIntrestAmount'] as num?)?.toDouble(),
      monthlyEmi: (json['monthlyEmi'] as num?)?.toDouble(),
      tenureInYears: json['tenureInYears'],
      intrestrate: (json['intrestrate'] as num?)?.toDouble(),
      loanvalue: (json['loanvalue'] as num?)?.toDouble(),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "dateTime": dateTime,
      "profilename": profilename,
      "totalAmount": totalAmount,
      "totalIntrestAmount": totalIntrestAmount,
      "tenureInYears": tenureInYears,
      "monthlyEmi": monthlyEmi,
      "intrestrate": intrestrate,
      "loanvalue": loanvalue,
      "id": id,
    };
  }

  String indianFormatNumber(double amount) {
    return NumberFormat.currency(locale: 'HI', symbol: '₹ ', decimalDigits: 0)
        .format(amount)
        .toString();
  }

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
              Text(
                  "${AppLocalizations.of(context)!.loanEmi} : ${indianFormatNumber(monthlyEmi!)}"),
              Text("${AppLocalizations.of(context)!.tenure} : $tenureInYears")
            ],
          ),
          Text(
              "${AppLocalizations.of(context)!.totalPayment} : ${indianFormatNumber(totalAmount!)}"),
          Text(
              "${AppLocalizations.of(context)!.totalIntrest} : ${indianFormatNumber(totalIntrestAmount!)}"),
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
                    child: Text(AppLocalizations.of(context)!.delete)),
                ElevatedButton(
                    onPressed: () {
                      update!(id!);
                    },
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    child: Text(AppLocalizations.of(context)!.update))
              ],
            ),
          )
        ],
      ),
    );
  }
}
