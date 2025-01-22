import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();  // Pengirim
  final _recipientAccountController = TextEditingController();  // Penerima
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoading = false;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _accountController.dispose();
    _recipientAccountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_accountController.text.isEmpty || _recipientAccountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih nomor rekening pengirim dan penerima terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.parse(amountStr);

      await _apiService.transfer(
        fromAccountNumber: _accountController.text,
        recipientAccount: _recipientAccountController.text,
        amount: amount,
        note: _noteController.text.isNotEmpty ? _noteController.text : 'Transfer',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer berhasil')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening Pengirim',
                hintText: 'Masukkan nomor rekening pengirim',
              ),
              keyboardType: TextInputType.text,  // Mengizinkan huruf dan angka
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),  // Mengizinkan angka dan huruf
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor rekening pengirim harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientAccountController,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening Penerima',
                hintText: 'Masukkan nomor rekening penerima',
              ),
              keyboardType: TextInputType.text,  // Mengizinkan huruf dan angka
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),  // Mengizinkan angka dan huruf
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor rekening penerima harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Jumlah Transfer',
                hintText: 'Masukkan jumlah transfer',
                prefixText: '${_currencyFormatter.currencySymbol} ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah transfer harus diisi';
                }
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Jumlah transfer tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Tambahkan catatan (opsional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleTransfer,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
