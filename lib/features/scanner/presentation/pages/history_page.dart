import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../../domain/entities/scan.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История'),
        centerTitle: true,
      ),
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          if (state is ScansLoaded) {
            if (state.scans.isEmpty) {
              return const Center(
                child: Text('Нет сохранённых сканирований'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.scans.length,
              itemBuilder: (context, index) {
                final scan = state.scans[index];
                return _ScanCard(scan: scan);
              },
            );
          }

          if (state is ScannerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScannerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScannerBloc>().add(LoadScans());
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Загрузка истории...'),
          );
        },
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final Scan scan;

  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scan.qrText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (scan.barcodeType != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(scan.barcodeType!),
                visualDensity: VisualDensity.compact,
              ),
            ],
            if (scan.comment != null && scan.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(scan.comment!),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(scan.scannedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}