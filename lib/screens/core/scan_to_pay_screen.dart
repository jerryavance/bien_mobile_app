import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/design_system/app_theme.dart';

class ScanToPayScreen extends StatefulWidget {
  const ScanToPayScreen({super.key});

  @override
  State<ScanToPayScreen> createState() => _ScanToPayScreenState();
}

bool isTorchOn = false; // Add this at the top of _ScanToPayScreenState
class _ScanToPayScreenState extends State<ScanToPayScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  String? scannedData;
  bool isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _processScan(BarcodeCapture capture) {
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    if (barcode?.rawValue != null && !isProcessing) {
      setState(() {
        isProcessing = true;
        scannedData = barcode!.rawValue;
      });
      _processPayment(barcode!.rawValue!);
    }
  }

  void _processPayment(String qrData) {
    cameraController.stop();

    // Parse QR data (format: BIEN:user_id:merchant_name)
    final parts = qrData.split(':');
    if (parts.length >= 2 && parts[0] == 'BIEN') {
      _showPaymentDialog(parts[1], parts.length > 2 ? parts[2] : 'Merchant');
    } else {
      _showErrorDialog('Invalid Bien QR Code');
    }
  }

  void _showPaymentDialog(String merchantId, String merchantName) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text('Pay to $merchantName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                prefixText: 'UGX ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Merchant ID: $merchantId',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isProcessing = false);
              cameraController.start();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _confirmPayment(merchantName, amount);
              }
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _confirmPayment(String merchant, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
        title: const Text('Payment Successful'),
        content: Text(
          'You paid ${AppTheme.formatUGX(amount)} to $merchant',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.error, color: AppTheme.errorColor, size: 64),
        title: const Text('Scan Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isProcessing = false);
              cameraController.start();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cutOutSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Scanner View
          MobileScanner(
            controller: cameraController,
            onDetect: _processScan,
          ),

          // ✅ Overlay (custom scanner frame)
          Center(
            child: Container(
              width: cutOutSize,
              height: cutOutSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // ✅ Blue gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ✅ Top Bar and instructions
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        'Scan to Pay',
                        style: AppTheme.heading4.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      // IconButton(
                      //   onPressed: () async {
                      //     await cameraController.toggleTorch();
                      //     setState(() {});
                      //   },
                      //   icon: ValueListenableBuilder(
                      //     valueListenable: cameraController.torchState,
                      //     builder: (context, state, _) {
                      //       if (state == TorchState.on) {
                      //         return const Icon(Icons.flash_on, color: Colors.white);
                      //       } else {
                      //         return const Icon(Icons.flash_off, color: Colors.white);
                      //       }
                      //     },
                      //   ),
                      // ),

                      IconButton(
                        onPressed: () async {
                          await cameraController.toggleTorch();
                          setState(() => isTorchOn = !isTorchOn);
                        },
                        icon: Icon(
                          isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                ),
                const Spacer(),
                // Instructions
                Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner, size: 48, color: AppTheme.primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Position QR Code',
                        style: AppTheme.heading4.copyWith(color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Align the QR code within the frame to scan',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
