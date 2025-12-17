import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // ========================================
  // 🕌 AZAN & PRAYER TIMES (للـ Background Service)
  // ========================================
  
  static const String _azanPrayerTimesKey = 'prayer_times';
  static const String _azanSettingsKey = 'azan_settings';

  /// حفظ مواقيت الصلاة للـ Background Service
  /// المفاتيح يجب تكون lowercase: fajr, dhuhr, asr, maghrib, isha
  static Future<void> saveAzanPrayerTimes(Map<String, String> prayerTimes) async {
    await _preferences?.setString(_azanPrayerTimesKey, jsonEncode(prayerTimes));
  }

  static Map<String, String>? getAzanPrayerTimes() {
    final json = _preferences?.getString(_azanPrayerTimesKey);
    if (json == null) return null;
    
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveAzanSettings(Map<String, dynamic> settings) async {
    await _preferences?.setString(_azanSettingsKey, jsonEncode(settings));
  }

  static Map<String, dynamic>? getAzanSettings() {
    final json = _preferences?.getString(_azanSettingsKey);
    if (json == null) return null;
    
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // 📿 AZKAR COUNTER
  // ========================================
  
  static Future<void> saveZekrProgress(String zekrId, int count) async {
    await _preferences?.setInt('zekr_$zekrId', count);
  }

  static int getZekrProgress(String zekrId) {
    return _preferences?.getInt('zekr_$zekrId') ?? 0;
  }

  static Future<void> resetZekrProgress(String zekrId) async {
    await _preferences?.remove('zekr_$zekrId');
  }

  static Future<void> resetAllAzkarProgress() async {
    final keys = _preferences?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith('zekr_')) {
        await _preferences?.remove(key);
      }
    }
  }

  // ========================================
  // 📿 SEBHA (TASBIH)
  // ========================================
  
  static Future<void> saveSebhaCount(int count) async {
    await _preferences?.setInt('sebha_count', count);
  }

  static int getSebhaCount() {
    return _preferences?.getInt('sebha_count') ?? 0;
  }

  static Future<void> saveSebhaGoal(int goal) async {
    await _preferences?.setInt('sebha_goal', goal);
  }

  static int getSebhaGoal() {
    return _preferences?.getInt('sebha_goal') ?? 100;
  }

  static Future<void> resetSebhaCount() async {
    await _preferences?.setInt('sebha_count', 0);
  }

  // ========================================
  // 📅 DAILY RESET
  // ========================================
  
  static Future<void> saveLastResetDate() async {
    final now = DateTime.now();
    await _preferences?.setString('last_reset_date', now.toIso8601String());
  }

  static bool isNewDay() {
    final lastReset = _preferences?.getString('last_reset_date');
    if (lastReset == null) return true;

    final lastDate = DateTime.parse(lastReset);
    final now = DateTime.now();

    return now.day != lastDate.day ||
        now.month != lastDate.month ||
        now.year != lastDate.year;
  }

  static Future<void> checkAndResetDaily() async {
    if (isNewDay()) {
      await resetSebhaCount();
      await saveLastResetDate();
    }
  }

  // ========================================
  // 📖 QURAN - RECENTLY VIEWED
  // ========================================
  
  static const String _recentlyViewedKey = 'recently_viewed_surahs';
  static const int _maxRecentlyViewed = 10;

  static List<int> getRecentlyViewedSurahs() {
    final List<String>? recentList = _preferences?.getStringList(_recentlyViewedKey);
    if (recentList == null) return [];
    return recentList.map((e) => int.parse(e)).toList();
  }

  static void addRecentlyViewedSurah(int index) {
    List<int> recent = getRecentlyViewedSurahs();
    
    recent.remove(index);
    recent.insert(0, index);
    
    if (recent.length > _maxRecentlyViewed) {
      recent = recent.sublist(0, _maxRecentlyViewed);
    }
    
    _preferences?.setStringList(_recentlyViewedKey, recent.map((e) => e.toString()).toList());
  }

  // ========================================
  // 🔖 QURAN - BOOKMARKS
  // ========================================
  
  static const String _bookmarkPrefix = 'bookmark_surah_';

  static Future<void> saveBookmark(int surahNumber, int verseNumber) async {
    await _preferences?.setInt('$_bookmarkPrefix$surahNumber', verseNumber);
    await _preferences?.setInt('last_bookmark_surah', surahNumber);
  }

  static int? getBookmark(int surahNumber) {
    return _preferences?.getInt('$_bookmarkPrefix$surahNumber');
  }

  static int? getLastBookmarkedSurah() {
    return _preferences?.getInt('last_bookmark_surah');
  }

  static Future<void> removeBookmark(int surahNumber) async {
    await _preferences?.remove('$_bookmarkPrefix$surahNumber');
  }

  static Map<int, int> getAllBookmarks() {
    final Map<int, int> bookmarks = {};
    final keys = _preferences?.getKeys() ?? {};
    
    for (var key in keys) {
      if (key.startsWith(_bookmarkPrefix)) {
        final surahNumber = int.tryParse(key.replaceFirst(_bookmarkPrefix, ''));
        final verseNumber = _preferences?.getInt(key);
        if (surahNumber != null && verseNumber != null) {
          bookmarks[surahNumber] = verseNumber;
        }
      }
    }
    return bookmarks;
  }

  // ========================================
  // 🎯 ONBOARDING
  // ========================================
  
  static const String _onboardingKey = 'onboarding_seen';

  static Future<void> setOnboardingSeen(bool seen) async {
    await _preferences?.setBool(_onboardingKey, seen);
  }

  static bool isOnboardingSeen() {
    return _preferences?.getBool(_onboardingKey) ?? false;
  }

  // ========================================
  // 💾 CACHED PRAYER TIMES (للعرض في UI)
  // ========================================
  
  static const String _cachedPrayerTimesKey = 'cached_prayer_times';

  static Future<void> saveCachedPrayerTimes(String json) async {
    await _preferences?.setString(_cachedPrayerTimesKey, json);
  }

  static String? getCachedPrayerTimes() {
    return _preferences?.getString(_cachedPrayerTimesKey);
  }

  // ========================================
  // ✅ PRAYER COMPLETION TRACKING
  // ========================================
  
  static String _prayerKey(String prayer) => 'prayer_done_$prayer';

  static Future<void> savePrayerCompleted(String prayer, bool done) async {
    await _preferences?.setBool(_prayerKey(prayer), done);
  }

  static bool getPrayerCompleted(String prayer) {
    return _preferences?.getBool(_prayerKey(prayer)) ?? false;
  }

  static Future<void> resetAllPrayerCompletions() async {
    final keys = _preferences?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith('prayer_done_')) {
        await _preferences?.remove(key);
      }
    }
  }

  // ========================================
  // 📖 QURAN DAILY PROGRESS
  // ========================================
  
  static const String _quranProgressKey = 'daily_quran_progress';
  static const String _quranGoalKey = 'daily_quran_goal';

  static Future<void> saveQuranProgress(int pages) async {
    await _preferences?.setInt(_quranProgressKey, pages);
  }

  static int getQuranProgress() {
    return _preferences?.getInt(_quranProgressKey) ?? 0;
  }

  static Future<void> resetQuranProgress() async {
    await _preferences?.remove(_quranProgressKey);
  }

  static Future<void> saveQuranGoal(int pages) async {
    await _preferences?.setInt(_quranGoalKey, pages);
  }

  static int getQuranGoal() {
    return _preferences?.getInt(_quranGoalKey) ?? 20;
  }

  // Per-page read markers
  static String _quranReadKey(int surah, int page) => 'quran_read_${surah}_$page';

  static Future<void> markQuranPageRead(int surah, int page) async {
    await _preferences?.setBool(_quranReadKey(surah, page), true);
  }

  static bool isQuranPageRead(int surah, int page) {
    return _preferences?.getBool(_quranReadKey(surah, page)) ?? false;
  }

  static int getDailyQuranPagesRead() {
    final keys = _preferences?.getKeys() ?? {};
    int count = 0;
    for (var k in keys) {
      if (k.startsWith('quran_read_')) count++;
    }
    return count;
  }

  static Future<void> resetDailyQuranRead() async {
    final keys = _preferences?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith('quran_read_')) {
        await _preferences?.remove(key);
      }
    }
  }
}