// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'Beranda';

  @override
  String get exploreTab => 'Jelajahi';

  @override
  String get libraryTab => 'Pustaka';

  @override
  String get settingsTab => 'Pengaturan';

  @override
  String welcomeMessage(String brand) {
    return 'Selamat datang di Talevra - edisi $brand';
  }

  @override
  String currentLocale(String locale) {
    return 'Bahasa: $locale';
  }

  @override
  String get rewardsTab => 'Hadiah';

  @override
  String get rewardsUnavailable =>
      'Hadiah sementara tidak tersedia. Fitur lainnya tetap dapat digunakan.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get exclusivePremiere => 'PREMIER EKSKLUSIF';

  @override
  String get featuredTitle => 'Musim Dingin Tak Berakhir';

  @override
  String get featuredSubtitle =>
      'Ia kembali dengan satu janji: mengambil semuanya.';

  @override
  String get watchNow => 'Tonton sekarang';

  @override
  String get forYou => 'Untuk Anda';

  @override
  String get newLabel => 'Baru';

  @override
  String get romance => 'Romansa';

  @override
  String get revenge => 'Balas dendam';

  @override
  String get fantasy => 'Fantasi';

  @override
  String get more => 'Lainnya';

  @override
  String get trendingNow => 'Sedang populer';

  @override
  String get searchResults => 'Hasil pencarian';

  @override
  String get rankings => 'Peringkat';

  @override
  String get noStoriesFound => 'Cerita tidak ditemukan';

  @override
  String get searchStories => 'Cari cerita';

  @override
  String get titleOrGenre => 'Judul atau genre';

  @override
  String get cancel => 'Batal';

  @override
  String get search => 'Cari';

  @override
  String get history => 'Riwayat';

  @override
  String get favorites => 'Favorit';

  @override
  String get noWatchHistory => 'Belum ada riwayat tontonan';

  @override
  String get noFavorites => 'Belum ada favorit';

  @override
  String get exploreSeries => 'Jelajahi serial';

  @override
  String get guestViewer => 'Penonton tamu';

  @override
  String get signInSync => 'Masuk untuk menyinkronkan perangkat';

  @override
  String get language => 'Bahasa';

  @override
  String get playback => 'Pemutaran';

  @override
  String get videoQuality => 'Kualitas video';

  @override
  String get autoplayNext => 'Putar episode berikutnya otomatis';

  @override
  String get downloadWifiOnly => 'Unduh hanya melalui Wi-Fi';

  @override
  String get support => 'Dukungan';

  @override
  String get helpSupport => 'Bantuan & dukungan';

  @override
  String get aboutNova => 'Tentang Talevra';

  @override
  String get versionLabel => 'Versi 0.1.0';

  @override
  String get supportSoon => 'Pusat dukungan segera tersedia';

  @override
  String get availableBalance => 'Saldo tersedia';

  @override
  String get coins => 'koin';

  @override
  String get checkedInToday => 'Check-in hari ini selesai';

  @override
  String get dailyCheckIn => 'Check-in harian';

  @override
  String dayStreak(Object count) {
    return 'Streak $count hari';
  }

  @override
  String get checkIn => 'Check-in';

  @override
  String get tasks => 'Tugas';

  @override
  String get withdrawalLevels => 'Tingkat penarikan';

  @override
  String daysCoins(Object coins, Object days) {
    return '$days hari · $coins koin';
  }

  @override
  String episodesLabel(Object count, Object genre) {
    return '$genre · $count eps';
  }

  @override
  String episodesLong(Object count, Object genre) {
    return '$genre · $count episode';
  }

  @override
  String get winterNeverEnds => 'Musim Dingin Tak Berakhir';

  @override
  String get lastPromise => 'Janji Terakhir';

  @override
  String get dealWithFate => 'Kesepakatan dengan Takdir';

  @override
  String get empressReborn => 'Kaisar Wanita Terlahir Kembali';

  @override
  String get hiddenHeir => 'Pewaris Tersembunyi';

  @override
  String get ceo => 'CEO';

  @override
  String get historical => 'Sejarah';

  @override
  String get family => 'Keluarga';

  @override
  String get shortsTab => 'Video pendek';

  @override
  String get profileTab => 'Profil';

  @override
  String get privacyPolicy => 'Kebijakan privasi';

  @override
  String get privacyOpenFailed =>
      'Kebijakan privasi tidak dapat dibuka. Coba lagi.';

  @override
  String get clearCache => 'Bersihkan cache';

  @override
  String get cacheCleared => 'Cache dibersihkan';

  @override
  String get autoLabel => 'Otomatis';

  @override
  String get dataSaver => 'Hemat data';

  @override
  String get withdrawEarnings => 'Tarik penghasilan';

  @override
  String get withdraw => 'Tarik';

  @override
  String get onLabel => 'Aktif';

  @override
  String get offLabel => 'Nonaktif';

  @override
  String get playerLaunchFailed => 'Pemutar tidak dapat dibuka';

  @override
  String get videoLoadFailed => 'Video tidak dapat dimuat. Coba lagi nanti.';

  @override
  String get catalogLoadFailed =>
      'Serial tidak dapat dimuat. Periksa koneksi dan coba lagi.';

  @override
  String get maleCategory => 'Pria';

  @override
  String get femaleCategory => 'Wanita';

  @override
  String get suspense => 'Ketegangan';

  @override
  String get loadingSeries => 'Memuat serial...';

  @override
  String get save => 'Simpan';

  @override
  String get episodes => 'Episode';

  @override
  String speedLabel(String speed) {
    return 'Kecepatan $speed';
  }

  @override
  String get highDefinition => 'HD';

  @override
  String episodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String routeNotFound(String route) {
    return 'Halaman tidak ditemukan: $route';
  }
}
