import 'dart:math';

class Loan {
  final String loanType;
  final String accountName;
  final double amount; // Required field
  final int tenure; // in months
  final double interest;
  final DateTime startDate;

  // Optional fields
  final String? accountNumber;
  final String? bankName;
  final String? phone;
  final String? email;
  final String? contactPerson;
  final String? otherLoanInfo;

  final double? processingFee;
  final double? otherCharges;
  final double? partPayment;
  final double? advancePayment;
  final double? insuranceCharges;
  final bool? moratorium;
  final int? moratoriumMonth;
  final String? moratoriumType;

  // Calculated fields
  final double? monthlyEmi;
  final double? totalEmi;
  final DateTime? endDate;
  final double paid; // New field

  Loan({
    required this.loanType,
    required this.accountName,
    required this.amount,
    required this.tenure,
    required this.interest,
    required this.startDate,
    this.accountNumber,
    this.bankName,
    this.phone,
    this.email,
    this.contactPerson,
    this.otherLoanInfo,
    this.processingFee,
    this.otherCharges,
    this.partPayment,
    this.advancePayment,
    this.insuranceCharges,
    this.moratorium,
    this.moratoriumMonth,
    this.moratoriumType,
    this.monthlyEmi,
    this.totalEmi,
    this.endDate,
    this.paid = 0.0, // Default to 0 if not provided
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value) ?? 0;
      } else if (value is num) {
        return value.toDouble();
      }
      return 0;
    }

    return Loan(
      loanType: json['loanType'] ?? '',
      accountName: json['accountName'] ?? '',
      amount: toDouble(json['amount']),
      tenure: json['tenure'] ?? 0,
      interest: toDouble(json['interest']),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      accountNumber: json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      otherLoanInfo: json['otherLoanInfo'] ?? '',
      processingFee: toDouble(json['processingFee']),
      otherCharges: toDouble(json['otherCharges']),
      partPayment: toDouble(json['partPayment']),
      advancePayment: toDouble(json['advancePayment']),
      insuranceCharges: toDouble(json['insuranceCharges']),
      moratorium: json['moratorium'] ?? false,
      moratoriumMonth: json['moratoriumMonth'] ?? 0,
      moratoriumType: json['moratoriumType'] ?? '',
      monthlyEmi: toDouble(json['monthlyEmi']),
      totalEmi: toDouble(json['totalEmi']),
      paid: toDouble(json['paid']),
    );
  }

  Map<String, dynamic> toJson() => {
        'loanType': loanType,
        'accountName': accountName,
        'amount': amount,
        'tenure': tenure,
        'interest': interest,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'accountNumber': accountNumber,
        'bankName': bankName,
        'phone': phone,
        'email': email,
        'contactPerson': contactPerson,
        'otherLoanInfo': otherLoanInfo,
        'processingFee': processingFee,
        'otherCharges': otherCharges,
        'partPayment': partPayment,
        'advancePayment': advancePayment,
        'insuranceCharges': insuranceCharges,
        'moratorium': moratorium,
        'moratoriumMonth': moratoriumMonth,
        'moratoriumType': moratoriumType,
        'monthlyEmi': monthlyEmi,
        'totalEmi': totalEmi,
        'paid': paid,
      };

  // Calculate the total payable amount
  double calculateTotalPayable() {
    double ratePerMonth = interest / 12 / 100;
    double totalAmount = amount * pow(1 + ratePerMonth, tenure);
    return totalAmount;
  }

  // Calculate the EMI amount
  double calculateMonthlyEmi() {
    double ratePerMonth = interest / 12 / 100;
    return (amount * ratePerMonth * pow(1 + ratePerMonth, tenure)) /
        (pow(1 + ratePerMonth, tenure) - 1);
  }
}
