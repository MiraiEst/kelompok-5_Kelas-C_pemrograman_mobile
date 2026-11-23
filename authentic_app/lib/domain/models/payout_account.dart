/// Seller's bank account for payouts.
class PayoutAccount {
  const PayoutAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  final String bankName;
  final String accountNumber;
  final String accountHolder;

  /// "BCA ••21": only the last 2 digits are ever shown.
  String get masked {
    final n = accountNumber;
    return '$bankName ••${n.length <= 2 ? n : n.substring(n.length - 2)}';
  }

  Map<String, dynamic> toMap() => {
    'bankName': bankName,
    'accountNumber': accountNumber,
    'accountHolder': accountHolder,
  };

  factory PayoutAccount.fromMap(Map<String, dynamic> d) => PayoutAccount(
    bankName: d['bankName'] as String? ?? '',
    accountNumber: d['accountNumber'] as String? ?? '',
    accountHolder: d['accountHolder'] as String? ?? '',
  );

  static const banks = ['BCA', 'BNI', 'BRI', 'Mandiri', 'CIMB Niaga', 'Permata', 'BSI', 'Danamon'];
}
