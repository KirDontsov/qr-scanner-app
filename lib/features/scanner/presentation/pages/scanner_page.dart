import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  final _commentController = TextEditingController();
  String? _lastScannedCode;

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null && barcode!.rawValue != _lastScannedCode) {
      _lastScannedCode = barcode.rawValue;
      context.read<ScannerBloc>().add(ScanDetected(
            code: barcode.rawValue!,
            barcodeType: barcode.format.name,
          ));
    }
  }

  void _submitScan(String code, String? barcodeType) {
    context.read<ScannerBloc>().add(ScanSubmitted(
          code: code,
          barcodeType: barcodeType,
          comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        ));
    _commentController.clear();
    _lastScannedCode = null;
  }

  void _resetScanner() {
    context.read<ScannerBloc>().add(ResetScanner());
    _lastScannedCode = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканер'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.read<ScannerBloc>().add(LoadScans());
            },
          ),
        ],
      ),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Скан сохранён'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScannerDetected) {
            return _buildResultView(state.code, state.barcodeType);
          }
          if (state is ScannerSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScannerSuccess) {
            return _buildSuccessView();
          }
          if (state is ScansLoaded) {
            return _buildHistoryView(state.scans);
          }
          return _buildScannerView();
        },
      ),
    );
  }

  Widget _buildScannerView() {
    return MobileScanner(
      controller: _controller,
      onDetect: _onDetect,
    );
  }

  Widget _buildResultView(String code, String? barcodeType) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 20),
          Text(
            barcodeType ?? 'QR',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Комментарий (необязательно)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.comment),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _submitScan(code, barcodeType),
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Скан сохранён!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _resetScanner,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Сканировать ещё'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView(List scans) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Назад к сканеру'),
              ),
              const Spacer(),
              const Text(
                'История',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: scans.isEmpty
              ? const Center(child: Text('Нет сохранённых сканов'))
              : ListView.builder(
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];
                    return ListTile(
                      leading: const Icon(Icons.qr_code, color: Colors.green),
                      title: Text(scan.qrText),
                      subtitle: Text(
                        '${scan.barcodeType ?? 'QR'} • ${scan.comment ?? 'без комментария'}',
                      ),
                      trailing: Text(
                        '${scan.scannedAt.day}.${scan.scannedAt.month}.${scan.scannedAt.year}',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}