// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                     CSE CHAT — Complete Flutter Source                      ║
// ║          Cybersecurity & Programming Team Real-time Chat App                ║
// ║                                                                              ║
// ║  STRUCTURE:                                                                  ║
// ║  1. lib/main.dart                                                            ║
// ║  2. lib/core/theme/app_theme.dart                                            ║
// ║  3. lib/core/constants/app_constants.dart                                    ║
// ║  4. lib/models/user_model.dart                                               ║
// ║  5. lib/models/message_model.dart                                            ║
// ║  6. lib/models/room_model.dart                                               ║
// ║  7. lib/services/auth_service.dart                                           ║
// ║  8. lib/services/chat_service.dart                                           ║
// ║  9. lib/screens/login_screen.dart                                            ║
// ║  10. lib/screens/register_screen.dart                                        ║
// ║  11. lib/screens/chat_list_screen.dart                                       ║
// ║  12. lib/screens/chat_screen.dart                                            ║
// ║  13. lib/screens/profile_screen.dart                                         ║
// ║  14. lib/widgets/message_bubble.dart                                         ║
// ║  15. lib/widgets/typing_indicator.dart                                       ║
// ║  16. lib/widgets/room_card.dart                                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/main.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تفعيل الوضع الكامل الشاشة مع ألوان الـ status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  runApp(const CSEChatApp());
}

class CSEChatApp extends StatelessWidget {
  const CSEChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSE Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

// Auth wrapper — يقرر أي شاشة تُعرض بناءً على حالة المصادقة
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const ChatListScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// Splash Screen بسيطة أثناء تحميل Firebase
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppConstants.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.accentCyan.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'CSE Chat',
              style: GoogleFonts.firaCode(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.accentCyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/core/constants/app_constants.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppConstants {
  AppConstants._();

  // ── Firestore Collection Names ──────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String messagesSubCollection = 'messages';

  // ── Color Palette ───────────────────────────────────────────────────────────
  static const Color bgPrimary = Color(0xFF0A0E1A);
  static const Color bgSecondary = Color(0xFF111827);
  static const Color bgCard = Color(0xFF1A2236);
  static const Color bgInput = Color(0xFF1E2D40);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentRed = Color(0xFFFF4444);
  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8B9EC8);
  static const Color textHint = Color(0xFF4A5568);
  static const Color divider = Color(0xFF1E2D40);
  static const Color senderBubble = Color(0xFF1A4A6B);
  static const Color receiverBubble = Color(0xFF1A2236);
  static const Color onlineIndicator = Color(0xFF00FF88);
  static const Color offlineIndicator = Color(0xFF4A5568);

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
  );

  static const LinearGradient senderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF005B80), Color(0xFF1A4A6B)],
  );

  // ── Border Radius ───────────────────────────────────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;

  // ── Spacing ─────────────────────────────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // ── Default Rooms ───────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultRooms = [
    {
      'id': 'general',
      'name': 'General',
      'description': 'القناة العامة للنقاشات',
      'icon': '💬',
      'color': '00D4FF',
    },
    {
      'id': 'cybersecurity',
      'name': 'Cybersecurity',
      'description': 'نقاشات الأمن السيبراني والثغرات',
      'icon': '🔐',
      'color': '00FF88',
    },
    {
      'id': 'programming',
      'name': 'Programming',
      'description': 'البرمجة والخوارزميات والـ CTF',
      'icon': '💻',
      'color': '7C3AED',
    },
    {
      'id': 'tools',
      'name': 'Tools & Resources',
      'description': 'أدوات وموارد مفيدة للفريق',
      'icon': '🛠️',
      'color': 'FF6B35',
    },
    {
      'id': 'announcements',
      'name': 'Announcements',
      'description': 'إعلانات الفريق والأخبار المهمة',
      'icon': '📢',
      'color': 'FFD700',
    },
  ];
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/core/theme/app_theme.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.accentCyan,
        secondary: AppConstants.accentGreen,
        tertiary: AppConstants.accentPurple,
        surface: AppConstants.bgSecondary,
        onSurface: AppConstants.textPrimary,
        error: AppConstants.accentRed,
      ),
      textTheme: GoogleFonts.firaCodeTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: GoogleFonts.firaCode(
          fontSize: 14,
          color: AppConstants.textPrimary,
        ),
        bodyMedium: GoogleFonts.firaCode(
          fontSize: 13,
          color: AppConstants.textSecondary,
        ),
        bodySmall: GoogleFonts.firaCode(
          fontSize: 11,
          color: AppConstants.textHint,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.bgPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppConstants.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: AppConstants.divider,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: AppConstants.accentCyan,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: AppConstants.accentRed,
            width: 1,
          ),
        ),
        hintStyle: GoogleFonts.firaCode(
          color: AppConstants.textHint,
          fontSize: 13,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: AppConstants.textSecondary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.accentCyan,
          foregroundColor: AppConstants.bgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.accentCyan,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConstants.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.bgCard,
        contentTextStyle: GoogleFonts.firaCode(
          color: AppConstants.textPrimary,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/models/user_model.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'admin', 'member', 'guest'
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final String? bio;
  final List<String> badges; // ['pentester', 'developer', 'analyst', ...]

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'member',
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.bio,
    this.badges = const [],
  });

  // من Firestore Document إلى Model
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Unknown',
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? 'member',
      isOnline: map['isOnline'] as bool? ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      bio: map['bio'] as String?,
      badges: List<String>.from(map['badges'] as List? ?? []),
    );
  }

  // من Firestore DocumentSnapshot إلى Model
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    return UserModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  // من Model إلى Map لرفعه على Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'bio': bio,
      'badges': badges,
    };
  }

  // نسخ مع تعديل بعض الحقول
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? role,
    bool? isOnline,
    DateTime? lastSeen,
    String? bio,
    List<String>? badges,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      bio: bio ?? this.bio,
      badges: badges ?? this.badges,
    );
  }

  // حرف أول من الاسم للـ Avatar
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  // صيغة آخر ظهور
  String get lastSeenFormatted {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(lastSeen!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(lastSeen!);
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, displayName: $displayName, email: $email)';
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/models/message_model.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum MessageType { text, image, file, system, code }

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId; // ID الرسالة المُردّ عليها
  final String? replyToContent; // مضمون الرسالة المُردّ عليها
  final String? codeLanguage; // لغة البرمجة في حالة رسالة code
  final List<String> readBy; // قائمة IDs من قرأ الرسالة
  final bool isDeleted;
  final Map<String, List<String>> reactions; // emoji -> [uid1, uid2, ...]

  const MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
    this.replyToContent,
    this.codeLanguage,
    this.readBy = const [],
    this.isDeleted = false,
    this.reactions = const {},
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      roomId: map['roomId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Unknown',
      senderPhotoUrl: map['senderPhotoUrl'] as String?,
      content: map['content'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.name == (map['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      replyToId: map['replyToId'] as String?,
      replyToContent: map['replyToContent'] as String?,
      codeLanguage: map['codeLanguage'] as String?,
      readBy: List<String>.from(map['readBy'] as List? ?? []),
      isDeleted: map['isDeleted'] as bool? ?? false,
      reactions: (map['reactions'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      ),
    );
  }

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    return MessageModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'content': content,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'replyToId': replyToId,
      'replyToContent': replyToContent,
      'codeLanguage': codeLanguage,
      'readBy': readBy,
      'isDeleted': isDeleted,
      'reactions': reactions,
    };
  }

  // صيغة الوقت للعرض
  String get timeFormatted => DateFormat('HH:mm').format(timestamp);

  // صيغة التاريخ الكاملة للفاصل
  String get dateFormatted {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(timestamp);
  }

  @override
  String toString() =>
      'MessageModel(id: $id, sender: $senderName, content: $content)';
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/models/room_model.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RoomModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String colorHex;
  final String? lastMessage;
  final String? lastMessageSender;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final List<String> members;
  final bool isPinned;
  final bool isPrivate;

  const RoomModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '💬',
    this.colorHex = '00D4FF',
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.members = const [],
    this.isPinned = false,
    this.isPrivate = false,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed Room',
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? '💬',
      colorHex: map['color'] as String? ?? '00D4FF',
      lastMessage: map['lastMessage'] as String?,
      lastMessageSender: map['lastMessageSender'] as String?,
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      unreadCount: map['unreadCount'] as int? ?? 0,
      members: List<String>.from(map['members'] as List? ?? []),
      isPinned: map['isPinned'] as bool? ?? false,
      isPrivate: map['isPrivate'] as bool? ?? false,
    );
  }

  factory RoomModel.fromSnapshot(DocumentSnapshot doc) {
    return RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': colorHex,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCount': unreadCount,
      'members': members,
      'isPinned': isPinned,
      'isPrivate': isPrivate,
    };
  }

  // اللون من الـ hex string
  Color get color {
    try {
      return Color(int.parse('FF$colorHex', radix: 16));
    } catch (_) {
      return AppConstants.accentCyan;
    }
  }

  // صيغة وقت آخر رسالة
  String get lastMessageTimeFormatted {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(lastMessageTime!);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/services/auth_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // Stream لتغييرات حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── تسجيل مستخدم جديد ─────────────────────────────────────────────────────
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? bio,
  }) async {
    try {
      // إنشاء الحساب على Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User creation failed');

      // تحديث اسم العرض
      await user.updateDisplayName(displayName.trim());

      // إنشاء document في Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: 'member',
        isOnline: true,
        createdAt: DateTime.now(),
        bio: bio?.trim(),
        badges: ['new_member'],
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── تسجيل الدخول ──────────────────────────────────────────────────────────
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Sign in failed');

      // تحديث حالة الاتصال
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()});

      // جلب بيانات المستخدم
      return await getUserById(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── تسجيل الخروج ──────────────────────────────────────────────────────────
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      // تحديث حالة الاتصال إلى offline
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    await _auth.signOut();
  }

  // ── إعادة تعيين كلمة المرور ───────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── جلب بيانات مستخدم معين ────────────────────────────────────────────────
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  // ── Stream لبيانات المستخدم الحالي (يتحدث فورياً) ─────────────────────────
  Stream<UserModel?> currentUserStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromSnapshot(doc) : null);
  }

  // ── تحديث معلومات المستخدم ────────────────────────────────────────────────
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName.trim();
    if (bio != null) updates['bio'] = bio.trim();
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);

      // تحديث Firebase Auth إذا تغيّر الاسم
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName.trim());
      }
    }
  }

  // ── تحديث حالة الاتصال ────────────────────────────────────────────────────
  Future<void> setOnlineStatus(String uid, bool isOnline) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // ── تحويل أخطاء Firebase إلى رسائل مفهومة ────────────────────────────────
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/services/chat_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── تهيئة الغرف الافتراضية ────────────────────────────────────────────────
  Future<void> initializeDefaultRooms() async {
    final batch = _firestore.batch();

    for (final roomData in AppConstants.defaultRooms) {
      final docRef = _firestore
          .collection(AppConstants.roomsCollection)
          .doc(roomData['id'] as String);

      final doc = await docRef.get();
      if (!doc.exists) {
        final room = RoomModel(
          id: roomData['id'] as String,
          name: roomData['name'] as String,
          description: roomData['description'] as String,
          icon: roomData['icon'] as String,
          colorHex: roomData['color'] as String,
        );
        batch.set(docRef, room.toMap());
      }
    }

    await batch.commit();
  }

  // ── Stream لقائمة الغرف (Real-time) ───────────────────────────────────────
  Stream<List<RoomModel>> getRoomsStream() {
    return _firestore
        .collection(AppConstants.roomsCollection)
        .orderBy('isPinned', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromSnapshot(doc))
            .toList());
  }

  // ── Stream للرسائل داخل غرفة (Real-time) ─────────────────────────────────
  Stream<List<MessageModel>> getMessagesStream(String roomId) {
    return _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromSnapshot(doc))
            .toList());
  }

  // ── إرسال رسالة جديدة ─────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String roomId,
    required String content,
    required UserModel sender,
    MessageType type = MessageType.text,
    String? replyToId,
    String? replyToContent,
    String? codeLanguage,
  }) async {
    // إضافة الرسالة إلى الـ subcollection
    final messageRef = _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      roomId: roomId,
      senderId: sender.uid,
      senderName: sender.displayName,
      senderPhotoUrl: sender.photoUrl,
      content: content.trim(),
      type: type,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      replyToContent: replyToContent,
      codeLanguage: codeLanguage,
    );

    final batch = _firestore.batch();

    // حفظ الرسالة
    batch.set(messageRef, message.toMap());

    // تحديث آخر رسالة في الغرفة
    final roomRef = _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId);
    batch.update(roomRef, {
      'lastMessage': content.trim(),
      'lastMessageSender': sender.displayName,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── حذف رسالة (soft delete) ───────────────────────────────────────────────
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    await _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .update({'isDeleted': true, 'content': 'This message was deleted.'});
  }

  // ── إضافة رد فعل (Reaction) ───────────────────────────────────────────────
  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final messageRef = _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId);

    final doc = await messageRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final reactions =
        (data['reactions'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );

    final currentList = reactions[emoji] ?? [];
    if (currentList.contains(userId)) {
      currentList.remove(userId);
    } else {
      currentList.add(userId);
    }

    if (currentList.isEmpty) {
      reactions.remove(emoji);
    } else {
      reactions[emoji] = currentList;
    }

    await messageRef.update({'reactions': reactions});
  }

  // ── تمييز الرسائل كمقروءة ─────────────────────────────────────────────────
  Future<void> markMessagesAsRead({
    required String roomId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    await batch.commit();
  }

  // ── Stream للمستخدمين المتصلين ────────────────────────────────────────────
  Stream<List<UserModel>> getOnlineUsersStream() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList());
  }

  // ── البحث في المستخدمين ───────────────────────────────────────────────────
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('displayName')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/screens/login_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo & Header ──────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        // Logo with glow effect
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: AppConstants.accentGradient,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.accentCyan.withOpacity(0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color:
                                    AppConstants.accentPurple.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'CSE Chat',
                          style: GoogleFonts.firaCode(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '// Secure. Fast. Encrypted.',
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: AppConstants.accentCyan,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Terminal-style header ──────────────────────────────────
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '> ',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.accentGreen,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'authenticate',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.accentCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' --user',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to your CSE workspace',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Form ──────────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Error message
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              bottom: AppConstants.spacingM,
                            ),
                            padding: const EdgeInsets.all(AppConstants.spacingM),
                            decoration: BoxDecoration(
                              color: AppConstants.accentRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall,
                              ),
                              border: Border.all(
                                color: AppConstants.accentRed.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppConstants.accentRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.firaCode(
                                      color: AppConstants.accentRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'user@cse-team.com',
                            prefixIcon: const Icon(
                              Icons.alternate_email,
                              color: AppConstants.textSecondary,
                              size: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.spacingM),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppConstants.textSecondary,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppConstants.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),

                        const SizedBox(height: AppConstants.spacingS),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.firaCode(
                                color: AppConstants.accentCyan,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingM),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: _isLoading
                              ? Container(
                                  decoration: BoxDecoration(
                                    gradient: AppConstants.accentGradient,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium,
                                    ),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: AppConstants.accentGradient,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConstants.accentCyan
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      minimumSize:
                                          const Size(double.infinity, 52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.radiusMedium,
                                        ),
                                      ),
                                    ),
                                    onPressed: _handleLogin,
                                    icon: const Icon(
                                      Icons.login_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      'Sign In',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppConstants.divider),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppConstants.divider),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.accentCyan,
                        side: const BorderSide(
                          color: AppConstants.accentCyan,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined,
                          size: 20),
                      label: Text(
                        'Create New Account',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Text(
                      '🔐 Secured by Firebase Authentication',
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        color: AppConstants.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: const BorderSide(color: AppConstants.divider),
        ),
        title: Text(
          'Reset Password',
          style: GoogleFonts.spaceGrotesk(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a reset link.',
              style: GoogleFonts.firaCode(
                color: AppConstants.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.firaCode(
                color: AppConstants.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'user@cse-team.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isNotEmpty) {
                try {
                  await AuthService().sendPasswordResetEmail(
                    emailCtrl.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reset link sent to ${emailCtrl.text.trim()}',
                          style: GoogleFonts.firaCode(),
                        ),
                        backgroundColor: AppConstants.accentGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppConstants.accentRed,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/screens/register_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _authService = AuthService();
  final _chatService = ChatService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
      );

      // تهيئة الغرف الافتراضية إن لم تكن موجودة
      await _chatService.initializeDefaultRooms();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppConstants.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppConstants.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.spaceGrotesk(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Terminal header
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '> ',
                      style: GoogleFonts.firaCode(
                        color: AppConstants.accentGreen,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'adduser',
                      style: GoogleFonts.firaCode(
                        color: AppConstants.accentCyan,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' --group cse-team',
                      style: GoogleFonts.firaCode(
                        color: AppConstants.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join the CSE Team',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in your details to create a workspace account',
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  color: AppConstants.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.spacingM,
                        ),
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppConstants.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusSmall,
                          ),
                          border: Border.all(
                            color: AppConstants.accentRed.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.firaCode(
                            color: AppConstants.accentRed,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    // Display Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.firaCode(
                        color: AppConstants.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'John Doe',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Display name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingM),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: GoogleFonts.firaCode(
                        color: AppConstants.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'user@cse-team.com',
                        prefixIcon: Icon(
                          Icons.alternate_email,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingM),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.firaCode(
                        color: AppConstants.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppConstants.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingM),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      style: GoogleFonts.firaCode(
                        color: AppConstants.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppConstants.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingM),

                    // Bio (optional)
                    TextFormField(
                      controller: _bioController,
                      maxLines: 2,
                      style: GoogleFonts.firaCode(
                        color: AppConstants.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Bio (optional)',
                        hintText: 'e.g. Pentester | CTF Player | Python Dev',
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingL),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _isLoading
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: AppConstants.accentGradient,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: AppConstants.accentGradient,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppConstants.accentCyan.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize:
                                      const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium,
                                    ),
                                  ),
                                ),
                                onPressed: _handleRegister,
                                icon: const Icon(
                                  Icons.rocket_launch_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  'Create Account',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign In',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.accentCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/screens/chat_list_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with WidgetsBindingObserver {
  final _authService = AuthService();
  final _chatService = ChatService();
  UserModel? _currentUser;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // تحديث حالة الاتصال عند تغيير حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    if (state == AppLifecycleState.resumed) {
      _authService.setOnlineStatus(uid, true);
    } else if (state == AppLifecycleState.paused) {
      _authService.setOnlineStatus(uid, false);
    }
  }

  Future<void> _initialize() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _currentUser = await _authService.getUserById(uid);
      await _authService.setOnlineStatus(uid, true);
      await _chatService.initializeDefaultRooms();
    }
    if (mounted) setState(() => _isInitializing = false);
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: const BorderSide(color: AppConstants.divider),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.spaceGrotesk(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.firaCode(
            color: AppConstants.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const SplashScreen();
    }

    return Scaffold(
      backgroundColor: AppConstants.bgPrimary,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildOnlineUsersBar(),
          Expanded(child: _buildRoomsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.bgPrimary,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppConstants.accentGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.security_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CSE Chat',
                style: GoogleFonts.firaCode(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              Text(
                '// Cybersecurity Team',
                style: GoogleFonts.firaCode(
                  fontSize: 10,
                  color: AppConstants.accentCyan,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppConstants.textSecondary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search coming soon!')),
            );
          },
        ),
        Builder(
          builder: (ctx) => IconButton(
            icon: _currentUser != null
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: AppConstants.accentCyan.withOpacity(0.2),
                    child: Text(
                      _currentUser!.initials,
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        color: AppConstants.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Icon(Icons.person, color: AppConstants.textSecondary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // شريط المستخدمين المتصلين
  Widget _buildOnlineUsersBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppConstants.bgSecondary,
        border: const Border(
          bottom: BorderSide(color: AppConstants.divider),
        ),
      ),
      child: StreamBuilder<List<UserModel>>(
        stream: _chatService.getOnlineUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No members online',
                style: GoogleFonts.firaCode(
                  color: AppConstants.textHint,
                  fontSize: 12,
                ),
              ),
            );
          }

          final onlineUsers = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            itemCount: onlineUsers.length,
            itemBuilder: (context, index) {
              final user = onlineUsers[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppConstants.accentCyan.withOpacity(
                            0.15,
                          ),
                          child: Text(
                            user.initials,
                            style: GoogleFonts.firaCode(
                              fontSize: 13,
                              color: AppConstants.accentCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppConstants.onlineIndicator,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppConstants.bgSecondary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.displayName.split(' ').first,
                      style: GoogleFonts.firaCode(
                        fontSize: 9,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // قائمة الغرف
  Widget _buildRoomsList() {
    return StreamBuilder<List<RoomModel>>(
      stream: _chatService.getRoomsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accentCyan),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading rooms: ${snapshot.error}',
              style: GoogleFonts.firaCode(
                color: AppConstants.accentRed,
                fontSize: 12,
              ),
            ),
          );
        }

        final rooms = snapshot.data ?? [];

        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.forum_outlined,
                  color: AppConstants.textHint,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No rooms available yet',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppConstants.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
          itemCount: rooms.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: AppConstants.divider,
            indent: 72,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            return RoomCard(
              room: rooms[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      room: rooms[index],
                      currentUser: _currentUser!,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppConstants.bgSecondary,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppConstants.divider),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppConstants.accentCyan.withOpacity(0.15),
                    child: Text(
                      _currentUser?.initials ?? '?',
                      style: GoogleFonts.firaCode(
                        fontSize: 18,
                        color: AppConstants.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.displayName ?? 'User',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _currentUser?.email ?? '',
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.accentGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _currentUser?.role.toUpperCase() ?? 'MEMBER',
                            style: GoogleFonts.firaCode(
                              color: AppConstants.accentGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            ListTile(
              leading: const Icon(Icons.person_outline,
                  color: AppConstants.textSecondary),
              title: Text(
                'My Profile',
                style: GoogleFonts.spaceGrotesk(
                  color: AppConstants.textPrimary,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (_currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileScreen(currentUser: _currentUser!),
                    ),
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.shield_outlined,
                  color: AppConstants.textSecondary),
              title: Text(
                'Security Settings',
                style: GoogleFonts.spaceGrotesk(
                  color: AppConstants.textPrimary,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),

            const Spacer(),

            // Version info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'CSE Chat v1.0.0\n// Built with Flutter & Firebase',
                textAlign: TextAlign.center,
                style: GoogleFonts.firaCode(
                  color: AppConstants.textHint,
                  fontSize: 10,
                ),
              ),
            ),

            // Sign out button
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.accentRed,
                    side: BorderSide(
                      color: AppConstants.accentRed.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  onPressed: _handleSignOut,
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    'Sign Out',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/screens/chat_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ChatScreen extends StatefulWidget {
  final RoomModel room;
  final UserModel currentUser;

  const ChatScreen({
    super.key,
    required this.room,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  bool _isSending = false;
  bool _isCodeMode = false;
  String _codeLanguage = 'python';
  MessageModel? _replyingTo;
  bool _showScrollToBottom = false;

  static const List<String> _codeLanguages = [
    'python', 'dart', 'javascript', 'bash',
    'c', 'cpp', 'java', 'sql', 'html', 'css',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // تمييز الرسائل كمقروءة عند فتح الغرفة
    _chatService.markMessagesAsRead(
      roomId: widget.room.id,
      userId: widget.currentUser.uid,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isNearBottom = _scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200;
    if (isNearBottom != !_showScrollToBottom) {
      setState(() => _showScrollToBottom = !isNearBottom);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();
    final replyTo = _replyingTo;
    setState(() => _replyingTo = null);

    try {
      await _chatService.sendMessage(
        roomId: widget.room.id,
        content: content,
        sender: widget.currentUser,
        type: _isCodeMode ? MessageType.code : MessageType.text,
        replyToId: replyTo?.id,
        replyToContent: replyTo?.content,
        codeLanguage: _isCodeMode ? _codeLanguage : null,
      );

      // التمرير إلى آخر رسالة بعد الإرسال
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: AppConstants.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startReply(MessageModel message) {
    setState(() => _replyingTo = message);
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgPrimary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMessagesList(),
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      backgroundColor: AppConstants.bgCard,
                      onPressed: _scrollToBottom,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppConstants.accentCyan,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.bgSecondary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: AppConstants.textSecondary,
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Room icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: widget.room.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.room.color.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(widget.room.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '# ${widget.room.name}',
                style: GoogleFonts.spaceGrotesk(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                widget.room.description,
                style: GoogleFonts.firaCode(
                  color: AppConstants.textHint,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Code mode toggle
        Tooltip(
          message: 'Code Mode',
          child: IconButton(
            icon: Icon(
              Icons.code,
              color: _isCodeMode
                  ? AppConstants.accentCyan
                  : AppConstants.textSecondary,
            ),
            onPressed: () {
              setState(() => _isCodeMode = !_isCodeMode);
              if (_isCodeMode) {
                _showCodeLanguagePicker();
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppConstants.textSecondary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Room settings coming soon!')),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppConstants.divider),
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<MessageModel>>(
      stream: _chatService.getMessagesStream(widget.room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.accentCyan),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppConstants.accentRed, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Failed to load messages',
                  style: GoogleFonts.firaCode(
                    color: AppConstants.accentRed,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.room.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppConstants.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to say something!',
                  style: GoogleFonts.firaCode(
                    color: AppConstants.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        // تمرير تلقائي عند وصول رسائل جديدة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final isNearBottom = _scrollController.position.pixels >
                _scrollController.position.maxScrollExtent - 200;
            if (isNearBottom) {
              _scrollToBottom(animated: false);
            }
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final prevMessage = index > 0 ? messages[index - 1] : null;

            // إضافة فاصل التاريخ إذا تغيّر اليوم
            final showDateDivider = prevMessage == null ||
                !_isSameDay(message.timestamp, prevMessage.timestamp);

            final isMe = message.senderId == widget.currentUser.uid;
            final showAvatar = !isMe &&
                (index == messages.length - 1 ||
                    messages[index + 1].senderId != message.senderId);
            final showName = !isMe &&
                (prevMessage == null ||
                    prevMessage.senderId != message.senderId);

            return Column(
              children: [
                if (showDateDivider) _buildDateDivider(message.dateFormatted),
                MessageBubble(
                  message: message,
                  isMe: isMe,
                  showAvatar: showAvatar,
                  showName: showName,
                  currentUserId: widget.currentUser.uid,
                  onReply: () => _startReply(message),
                  onDelete: isMe
                      ? () => _chatService.deleteMessage(
                            roomId: widget.room.id,
                            messageId: message.id,
                          )
                      : null,
                  onReact: (emoji) => _chatService.toggleReaction(
                    roomId: widget.room.id,
                    messageId: message.id,
                    emoji: emoji,
                    userId: widget.currentUser.uid,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateDivider(String dateText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppConstants.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppConstants.divider),
              ),
              child: Text(
                dateText,
                style: GoogleFonts.firaCode(
                  fontSize: 11,
                  color: AppConstants.textSecondary,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppConstants.divider)),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.bgSecondary,
        border: Border(top: BorderSide(color: AppConstants.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Code mode indicator
            if (_isCodeMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingXS,
                ),
                color: AppConstants.accentPurple.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.code,
                        color: AppConstants.accentPurple, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'CODE MODE — $_codeLanguage',
                      style: GoogleFonts.firaCode(
                        color: AppConstants.accentPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showCodeLanguagePicker,
                      child: Text(
                        'Change language ›',
                        style: GoogleFonts.firaCode(
                          color: AppConstants.accentCyan,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Reply indicator
            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.accentCyan.withOpacity(0.08),
                  border: const Border(
                    left: BorderSide(
                      color: AppConstants.accentCyan,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply,
                        color: AppConstants.accentCyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${_replyingTo!.senderName}',
                            style: GoogleFonts.firaCode(
                              color: AppConstants.accentCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _replyingTo!.content,
                            style: GoogleFonts.firaCode(
                              color: AppConstants.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppConstants.textSecondary, size: 16),
                      onPressed: _cancelReply,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Input row
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppConstants.bgInput,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXL),
                        border: Border.all(color: AppConstants.divider),
                      ),
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        maxLines: null,
                        keyboardType: _isCodeMode
                            ? TextInputType.multiline
                            : TextInputType.text,
                        style: _isCodeMode
                            ? GoogleFonts.firaCode(
                                color: AppConstants.textPrimary,
                                fontSize: 13,
                              )
                            : GoogleFonts.spaceGrotesk(
                                color: AppConstants.textPrimary,
                                fontSize: 14,
                              ),
                        decoration: InputDecoration(
                          hintText: _isCodeMode
                              ? '// Write your code here...'
                              : 'Message #${widget.room.name}',
                          hintStyle: GoogleFonts.firaCode(
                            color: AppConstants.textHint,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _isCodeMode ? null : (_) => _sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppConstants.accentGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.accentCyan.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _isSending ? null : _sendMessage,
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCodeLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: GoogleFonts.spaceGrotesk(
                color: AppConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _codeLanguages.map((lang) {
                final isSelected = lang == _codeLanguage;
                return GestureDetector(
                  onTap: () {
                    setState(() => _codeLanguage = lang);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.accentPurple.withOpacity(0.2)
                          : AppConstants.bgInput,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(
                        color: isSelected
                            ? AppConstants.accentPurple
                            : AppConstants.divider,
                      ),
                    ),
                    child: Text(
                      lang,
                      style: GoogleFonts.firaCode(
                        color: isSelected
                            ? AppConstants.accentPurple
                            : AppConstants.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/screens/profile_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentUser.displayName);
    _bioController =
        TextEditingController(text: widget.currentUser.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(
        uid: widget.currentUser.uid,
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated!',
                style: GoogleFonts.firaCode()),
            backgroundColor: AppConstants.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e', style: GoogleFonts.firaCode()),
            backgroundColor: AppConstants.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppConstants.bgPrimary,
        title: Text(
          'Profile',
          style: GoogleFonts.spaceGrotesk(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppConstants.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text('Edit', style: GoogleFonts.spaceGrotesk()),
            )
          else
            TextButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 16),
              label: Text('Save', style: GoogleFonts.spaceGrotesk()),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            // Avatar large
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppConstants.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.accentCyan.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.currentUser.initials,
                        style: GoogleFonts.firaCode(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppConstants.bgCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConstants.accentCyan,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppConstants.accentCyan,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Online status
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.accentGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppConstants.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Online',
                    style: GoogleFonts.firaCode(
                      color: AppConstants.accentGreen,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Profile fields
            _buildInfoCard(
              children: [
                _buildField(
                  label: 'Display Name',
                  icon: Icons.badge_outlined,
                  child: _isEditing
                      ? TextFormField(
                          controller: _nameController,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppConstants.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : Text(
                          widget.currentUser.displayName,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppConstants.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const Divider(color: AppConstants.divider, height: 1),
                _buildField(
                  label: 'Email',
                  icon: Icons.alternate_email,
                  child: Text(
                    widget.currentUser.email,
                    style: GoogleFonts.firaCode(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Divider(color: AppConstants.divider, height: 1),
                _buildField(
                  label: 'Role',
                  icon: Icons.shield_outlined,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppConstants.accentCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.currentUser.role.toUpperCase(),
                      style: GoogleFonts.firaCode(
                        color: AppConstants.accentCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bio section
            _buildInfoCard(
              children: [
                _buildField(
                  label: 'Bio',
                  icon: Icons.info_outline,
                  child: _isEditing
                      ? TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Tell your team about yourself...',
                          ),
                        )
                      : Text(
                          widget.currentUser.bio?.isNotEmpty == true
                              ? widget.currentUser.bio!
                              : 'No bio yet.',
                          style: GoogleFonts.firaCode(
                            color: widget.currentUser.bio?.isNotEmpty == true
                                ? AppConstants.textPrimary
                                : AppConstants.textHint,
                            fontSize: 13,
                          ),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Badges
            if (widget.currentUser.badges.isNotEmpty)
              _buildInfoCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.military_tech_outlined,
                                color: AppConstants.textSecondary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Badges',
                              style: GoogleFonts.spaceGrotesk(
                                color: AppConstants.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.currentUser.badges.map((badge) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    AppConstants.accentPurple.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusSmall),
                                border: Border.all(
                                  color: AppConstants.accentPurple
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '🏅 $badge',
                                style: GoogleFonts.firaCode(
                                  color: AppConstants.accentPurple,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Member since
            Text(
              '// Member since ${DateFormat('MMMM yyyy').format(widget.currentUser.createdAt)}',
              style: GoogleFonts.firaCode(
                color: AppConstants.textHint,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppConstants.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppConstants.textHint, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppConstants.textHint,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/widgets/message_bubble.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final bool showName;
  final String currentUserId;
  final VoidCallback onReply;
  final Future<void> Function()? onDelete;
  final void Function(String emoji) onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.showName,
    required this.currentUserId,
    required this.onReply,
    required this.onReact,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return _buildDeletedBubble();
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Padding(
        padding: EdgeInsets.only(
          top: showName ? 8 : 2,
          bottom: 2,
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar للمستخدم الآخر
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 2),
                child: showAvatar
                    ? _buildAvatar()
                    : const SizedBox(width: 32),
              ),

            // Bubble content
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // اسم المرسل
                  if (showName && !isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        message.senderName,
                        style: GoogleFonts.firaCode(
                          fontSize: 11,
                          color: AppConstants.accentCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Reply preview
                  if (message.replyToContent != null)
                    _buildReplyPreview(),

                  // الفقاعة الرئيسية
                  _buildBubble(),

                  // Reactions
                  if (message.reactions.isNotEmpty) _buildReactions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = message.senderName.isNotEmpty
        ? message.senderName
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join()
        : '?';

    return CircleAvatar(
      radius: 16,
      backgroundColor: AppConstants.accentCyan.withOpacity(0.15),
      child: Text(
        initials,
        style: GoogleFonts.firaCode(
          fontSize: 10,
          color: AppConstants.accentCyan,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: const Border(
          left: BorderSide(color: AppConstants.accentCyan, width: 2),
        ),
      ),
      child: Text(
        message.replyToContent!,
        style: GoogleFonts.firaCode(
          fontSize: 11,
          color: AppConstants.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: message.type == MessageType.code ? 10 : 10,
      ),
      decoration: BoxDecoration(
        gradient: isMe ? AppConstants.senderGradient : null,
        color: isMe ? null : AppConstants.receiverBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppConstants.radiusLarge),
          topRight: const Radius.circular(AppConstants.radiusLarge),
          bottomLeft: Radius.circular(isMe ? AppConstants.radiusLarge : 4),
          bottomRight: Radius.circular(isMe ? 4 : AppConstants.radiusLarge),
        ),
        border: isMe
            ? null
            : Border.all(color: AppConstants.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // محتوى الرسالة
          if (message.type == MessageType.code)
            _buildCodeContent()
          else
            _buildTextContent(),

          const SizedBox(height: 4),

          // وقت الرسالة + علامة القراءة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.timeFormatted,
                style: GoogleFonts.firaCode(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white.withOpacity(0.6)
                      : AppConstants.textHint,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  message.isRead
                      ? Icons.done_all_rounded
                      : Icons.done_rounded,
                  size: 14,
                  color: message.isRead
                      ? AppConstants.accentCyan
                      : Colors.white.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // عرض نص عادي مع دعم URL
  Widget _buildTextContent() {
    return SelectableText(
      message.content,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: AppConstants.textPrimary,
        height: 1.4,
      ),
    );
  }

  // عرض الكود مع تنسيق terminal
  Widget _buildCodeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Code header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.code, size: 12, color: AppConstants.accentCyan),
              const SizedBox(width: 4),
              Text(
                message.codeLanguage ?? 'code',
                style: GoogleFonts.firaCode(
                  fontSize: 10,
                  color: AppConstants.accentCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Code content
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: SelectableText(
            message.content,
            style: GoogleFonts.firaCode(
              fontSize: 12,
              color: AppConstants.accentGreen,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReactions() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: message.reactions.entries.map((entry) {
          final hasReacted = entry.value.contains(currentUserId);
          return GestureDetector(
            onTap: () => onReact(entry.key),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: hasReacted
                    ? AppConstants.accentCyan.withOpacity(0.15)
                    : AppConstants.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasReacted
                      ? AppConstants.accentCyan.withOpacity(0.4)
                      : AppConstants.divider,
                ),
              ),
              child: Text(
                '${entry.key} ${entry.value.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeletedBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppConstants.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 12, color: AppConstants.textHint),
              const SizedBox(width: 6),
              Text(
                'Message deleted',
                style: GoogleFonts.firaCode(
                  fontSize: 11,
                  color: AppConstants.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    const emojis = ['👍', '❤️', '😂', '😮', '🔥', '👏'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick reactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    onReact(emoji);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppConstants.bgInput,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Divider(color: AppConstants.divider),

            // Reply action
            ListTile(
              leading: const Icon(Icons.reply, color: AppConstants.accentCyan),
              title: Text(
                'Reply',
                style: GoogleFonts.spaceGrotesk(
                  color: AppConstants.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onReply();
              },
            ),

            // Copy action
            ListTile(
              leading: const Icon(Icons.copy_outlined,
                  color: AppConstants.textSecondary),
              title: Text(
                'Copy Text',
                style: GoogleFonts.spaceGrotesk(
                  color: AppConstants.textPrimary,
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied!', style: GoogleFonts.firaCode()),
                    backgroundColor: AppConstants.accentGreen,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),

            // Delete action (only for own messages)
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppConstants.accentRed),
                title: Text(
                  'Delete Message',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppConstants.accentRed,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/widgets/room_card.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: room.color.withOpacity(0.05),
      highlightColor: room.color.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Room icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: room.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: room.color.withOpacity(0.25),
                ),
              ),
              child: Center(
                child: Text(
                  room.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Room info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '# ${room.name}',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.lastMessageTime != null)
                        Text(
                          room.lastMessageTimeFormatted,
                          style: GoogleFonts.firaCode(
                            color: room.unreadCount > 0
                                ? AppConstants.accentCyan
                                : AppConstants.textHint,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage != null
                              ? '${room.lastMessageSender ?? ''}: ${room.lastMessage!}'
                              : room.description,
                          style: GoogleFonts.firaCode(
                            color: AppConstants.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.accentCyan,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount > 99
                                ? '99+'
                                : room.unreadCount.toString(),
                            style: GoogleFonts.firaCode(
                              color: AppConstants.bgPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (room.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin,
                              size: 10, color: AppConstants.textHint),
                          const SizedBox(width: 3),
                          Text(
                            'Pinned',
                            style: GoogleFonts.firaCode(
                              color: AppConstants.textHint,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// lib/widgets/typing_indicator.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class TypingIndicator extends StatefulWidget {
  final String userName;

  const TypingIndicator({super.key, required this.userName});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _dotAnimations = _dotControllers.map((ctrl) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _dotControllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
        _dotControllers[i].reverse();
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (final ctrl in _dotControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppConstants.accentCyan.withOpacity(0.15),
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
              style: GoogleFonts.firaCode(
                fontSize: 9,
                color: AppConstants.accentCyan,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppConstants.bgCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: AppConstants.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dotAnimations[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _dotAnimations[i].value),
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: AppConstants.accentCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.userName} is typing...',
            style: GoogleFonts.firaCode(
              fontSize: 11,
              color: AppConstants.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                         END OF CSE CHAT SOURCE                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
