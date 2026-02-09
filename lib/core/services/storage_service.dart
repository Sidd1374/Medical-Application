class StorageService {
  Future<String> uploadReport(dynamic file, String fileName) async {
    throw Exception(
      'Firebase Storage is not available. Please use a direct URL instead.',
    );
  }

  Future<void> deleteReport(String fileUrl) async {
    throw Exception('Firebase Storage is not available.');
  }
}
