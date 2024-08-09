class Lend {
  final double amount;
  final double interest;
  final DateTime lendDate;
  final DateTime expectedReturnDate;

  final String phone;
  final String email;
  final String contactPerson;
  final String otherLoanInfo;

  Lend({
    required this.amount,
    required this.interest,
    required this.lendDate,
    required this.expectedReturnDate,
    required this.phone,
    required this.email,
    required this.contactPerson,
    this.otherLoanInfo = '', // Default value for optional field
  });

  Lend.fromJson(Map<String, dynamic> json)
      : amount = json['amount']?.toDouble() ?? 0.0,
        interest = json['interest']?.toDouble() ?? 0.0,
        lendDate = json['lendDate'] != null
            ? DateTime.parse(json['lendDate'])
            : DateTime.now(),
        expectedReturnDate = json['expectedReturnDate'] != null
            ? DateTime.parse(json['expectedReturnDate'])
            : DateTime.now(),
        phone = json['phone'] ?? '',
        email = json['email'] ?? '',
        contactPerson = json['contactPerson'] ?? '',
        otherLoanInfo = json['otherLoanInfo'] ?? '';

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'interest': interest,
        'lendDate': lendDate.toIso8601String(),
        'expectedReturnDate': expectedReturnDate.toIso8601String(),
        'phone': phone,
        'email': email,
        'contactPerson': contactPerson,
        'otherLoanInfo': otherLoanInfo,
      };
}
