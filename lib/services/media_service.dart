import 'dart:io';

import 'supabase_service.dart';

class MediaService {
  final _supabase = SupabaseService.instance.client;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
    final fullPath = '${path.split('/').first}/$fileName';
    await _supabase.storage
        .from(bucket)
        .upload(fullPath, file);
    return _supabase.storage.from(bucket).getPublicUrl(fullPath);
  }
}