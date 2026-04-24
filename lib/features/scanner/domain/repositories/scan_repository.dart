import '../entities/scan.dart';

abstract class ScanRepository {
  Future<Scan> createScan(Scan scan);
  Future<List<Scan>> getScans();
  Future<void> deleteScan(String id);
}