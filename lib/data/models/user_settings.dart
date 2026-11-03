class UserSettings {
  bool dark;
  bool urdu; // interface language
  double arabicSize;
  double transSize;
  bool showUrdu;
  bool showEnglish;
  int displayMode; // 0 = Arabic + translation, 1 = Arabic only, 2 = translation only
  double speed;
  bool repeatSurah;
  bool reminderOn;
  int hour;
  int minute;

  UserSettings({
    this.dark = false,
    this.urdu = false,
    this.arabicSize = 30,
    this.transSize = 17,
    this.showUrdu = true,
    this.showEnglish = true,
    this.displayMode = 0,
    this.speed = 1.0,
    this.repeatSurah = false,
    this.reminderOn = false,
    this.hour = 20,
    this.minute = 0,
  });

  Map<String, dynamic> toJson() => {
        'dark': dark,
        'urdu': urdu,
        'arabicSize': arabicSize,
        'transSize': transSize,
        'showUrdu': showUrdu,
        'showEnglish': showEnglish,
        'displayMode': displayMode,
        'speed': speed,
        'repeatSurah': repeatSurah,
        'reminderOn': reminderOn,
        'hour': hour,
        'minute': minute,
      };

  factory UserSettings.fromJson(Map<String, dynamic> j) {
    final d = UserSettings();
    return UserSettings(
      dark: (j['dark'] as bool?) ?? d.dark,
      urdu: (j['urdu'] as bool?) ?? d.urdu,
      arabicSize: ((j['arabicSize'] as num?) ?? d.arabicSize).toDouble(),
      transSize: ((j['transSize'] as num?) ?? d.transSize).toDouble(),
      showUrdu: (j['showUrdu'] as bool?) ?? d.showUrdu,
      showEnglish: (j['showEnglish'] as bool?) ?? d.showEnglish,
      displayMode: (j['displayMode'] as int?) ?? d.displayMode,
      speed: ((j['speed'] as num?) ?? d.speed).toDouble(),
      repeatSurah: (j['repeatSurah'] as bool?) ?? d.repeatSurah,
      reminderOn: (j['reminderOn'] as bool?) ?? d.reminderOn,
      hour: (j['hour'] as int?) ?? d.hour,
      minute: (j['minute'] as int?) ?? d.minute,
    );
  }
}
