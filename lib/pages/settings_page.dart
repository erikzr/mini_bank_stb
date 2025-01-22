import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;
  String _selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Umum',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text('Aktifkan notifikasi transaksi'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          SwitchListTile(
            title: const Text('Biometrik'),
            subtitle: const Text('Gunakan sidik jari untuk login'),
            value: _biometricsEnabled,
            onChanged: (bool value) {
              setState(() => _biometricsEnabled = value);
            },
          ),
          ListTile(
            title: const Text('Bahasa'),
            subtitle: Text(_selectedLanguage == 'id' ? 'Indonesia' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pilih Bahasa'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Indonesia'),
                        leading: Radio(
                          value: 'id',
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            setState(() => _selectedLanguage = value.toString());
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('English'),
                        leading: Radio(
                          value: 'en',
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            setState(() => _selectedLanguage = value.toString());
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Keamanan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text('Ubah PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/change-pin');
            },
          ),
          ListTile(
            title: const Text('Ubah Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),
        ],
      ),
    );
  }
}