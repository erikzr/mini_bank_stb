// lib/models/user_model.dart

class UserData {
  final int id;
  final String customerName;
  final String username;
  final String email;
  final String phone;
  final String cifNumber;
  final List<Account> accounts;
  final double totalBalance;

  UserData({
    required this.id,
    required this.customerName,
    required this.username,
    required this.email,
    required this.phone,
    required this.cifNumber,
    required this.accounts,
    required this.totalBalance,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    // Mengambil data user dari response
    final user = json['user'] as Map<String, dynamic>;
    
    // Mengambil accounts dari response dengan null check
    final accountsJson = json['accounts'] as List<dynamic>? ?? [];
    final accountsList = accountsJson
        .map((account) => Account.fromJson(account))
        .toList();

    return UserData(
      id: user['id'] ?? 0,
      customerName: user['name'] ?? '',
      username: user['username'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone'] ?? '',
      cifNumber: user['cif_number'] ?? '',
      accounts: accountsList,
      totalBalance: accountsList.fold(
        0,
        (sum, account) => sum + account.availableBalance,
      ),
    );
  }
}

class Account {
  final String accountNumber;
  final double availableBalance;

  Account({
    required this.accountNumber,
    required this.availableBalance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['account_number']?.toString() ?? '',
      availableBalance: double.tryParse(json['available_balance']?.toString() ?? '0') ?? 0,
    );
  }
}