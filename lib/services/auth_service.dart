import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.instance.client;
  final _uuid = const Uuid();

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;

    final result = await _supabase
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (result == null) return null;
    return AppUser.fromMap(result);
  }

  Future<AppUser> login({
    required String username,
    String? avatarUrl,
  }) async {
    final normalized = username.trim();
    if (normalized.isEmpty) throw Exception('اكتب اسم المستخدم');

    final existing = await _supabase
        .from('users')
        .select()
        .eq('username', normalized)
        .maybeSingle();

    late AppUser user;

    if (existing != null) {
      user = AppUser.fromMap(existing);
    } else {
      final id = _uuid.v4();
      final inserted = await _supabase
          .from('users')
          .insert({
            'id': id,
            'username': normalized,
            'avatar_url': avatarUrl,
            'role': 'student',
          })
          .select()
          .single();
      user = AppUser.fromMap(inserted);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
