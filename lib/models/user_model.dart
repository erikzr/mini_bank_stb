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
    try {
      // Mengambil data user dari response
      final user = json['user'] as Map<String, dynamic>? ?? {};
      
      // Mengambil accounts dari response dengan null check
      final accountsJson = json['accounts'] as List<dynamic>? ?? [];
      final accountsList = accountsJson
          .map((account) => Account.fromJson(account))
          .toList();

      return UserData(
        id: int.tryParse(user['id']?.toString() ?? '0') ?? 0,
        customerName: user['name']?.toString() ?? '',
        username: user['username']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
        phone: user['phone']?.toString() ?? '',
        cifNumber: user['cif_number']?.toString() ?? '',
        accounts: accountsList,
        totalBalance: accountsList.fold(
          0,
          (sum, account) => sum + account.availableBalance,
        ),
      );
    } catch (e) {
      // Return empty user data if parsing fails
      return UserData(
        id: 0,
        customerName: '',
        username: '',
        email: '',
        phone: '',
        cifNumber: '',
        accounts: [],
        totalBalance: 0,
      );
    }
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