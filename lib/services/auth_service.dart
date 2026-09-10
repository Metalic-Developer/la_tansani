import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'supabase_service.dart';

class AuthService {
  final _db = SupabaseService.instance.client;
  final _uuid = const Uuid();

  static String normalize(String username) =>
      username.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;

    final result = await _db.from('users').select().eq('id', id).maybeSingle();
    if (result == null) return null;
    return AppUser.fromMap(Map<String, dynamic>.from(result));
  }

  Future<AppUser> login({required String username, String? avatarUrl}) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) throw Exception('اكتب اسم المستخدم');

    final normalized = normalize(trimmed);

    final existing = await _db
        .from('users')
        .select()
        .eq('username_normalized', normalized)
        .maybeSingle();

    late AppUser user;

    if (existing != null) {
      user = AppUser.fromMap(Map<String, dynamic>.from(existing));
    } else {
      final id = _uuid.v4();
      final inserted = await _db
          .from('users')
          .insert({
            'id': id,
            'username': trimmed,
            'username_normalized': normalized,
            'avatar_url': avatarUrl,
            'role': 'student',
          })
          .select()
          .single();
      user = AppUser.fromMap(Map<String, dynamic>.from(inserted));
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