import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart'; 
import 'settings_overlay.dart';

// =====================================================================
// БЛОК КООРДИНАТ, ЦВЕТОВ И РАЗМЕРОВ ШРИФТА
// =====================================================================
class LayoutConfig {
  static const Color colorBlack = Color(0xFF000000);
  static const Color colorNeonRed = Color(0xFFFF0045);
  
  // --- АВАТАР ---
  static const double avatarX = 188;
  static const double avatarY = 291;
  static const double avatarWidth = 291;  
  static const double avatarHeight = 294; 

  // --- ACCOUNT ---
  static const double accountX = 500;
  static const double accountY = 168;
  static const Color accountColor = colorNeonRed; 
  static const double accountFontSize = 17;

  // --- REGION ---
  static const double regionX = 2023;
  static const double regionY = 212;
  static const Color regionColor = colorBlack; 
  static const double regionFontSize = 15;

  // --- ПРОФИЛЬ ---
  static const double profileRightEdgeX = 1350; 
  static const double nicknameY = 285;
  static const Color nicknameColor = colorNeonRed; 
  static const double nicknameFontSize = 20;

  static const double friendsY = 330;
  static const Color friendsColor = colorNeonRed; 
  static const double friendsFontSize = 20;

  static const double gamesCountY = 380;
  static const Color gamesCountColor = colorNeonRed; 
  static const double gamesCountFontSize = 20;

  // --- СОЗДАН (Бывшие отзывы) ---
  static const double createdY = 430;
  static const Color createdColor = colorNeonRed; 
  static const double createdFontSize = 20;

  // --- БЕГУЩИЕ ТОЧКИ ---
  static const double dotsStartX = 730; 
  static const Color dotsProfileColor = colorNeonRed;
  static const double dotsProfileSize = 4.0; 
  
  static const double dotsRow1_OffsetX = 0;   
  static const double dotsRow2_OffsetX = -15; 
  static const double dotsRow3_OffsetX = -25; 
  static const double dotsRow4_OffsetX = -15; 

  // --- УРОВЕНЬ STEAM ---
  static const double steamLevelX = 67;
  static const double steamLevelY = 300;
  static const Color steamLevelColor = colorBlack; 
  static const double steamLevelFontSize = 42;

  // --- ЗАГОЛОВОК СПИСКА ИГР ---
  static const double gamesTitleX = 1500;
  static const double gamesTitleY = 335;
  static const Color gamesTitleColor = colorNeonRed; 
  static const double gamesTitleFontSize = 40;

  // --- ИГРЫ ---
  static const double game1X = 1435;
  static const double game1Y = 475;
  static const Color game1NameColor = colorNeonRed;
  static const double game1NameFontSize = 34;

  static const double game2X = 1435;
  static const double game2Y = 650;
  static const Color game2NameColor = colorNeonRed; 
  static const double game2NameFontSize = 34; 

  static const double game3X = 1435;
  static const double game3Y = 830;
  static const Color game3NameColor = colorNeonRed; 
  static const double game3NameFontSize = 34;
  
  static const double gameNameMaxWidth = 700; 

  // --- ВРЕМЯ ИГРЫ ---
  static const double gameTimeOffsetY = 20; 
  static const Color gameTimeColor = colorNeonRed; 
  static const double gameTimeFontSize = 20;

  // --- БЕГУЩАЯ СТРОКА ДРУЗЕЙ ---
  static const double friendsLabelX = 100;
  static const double friendsLabelY = 650;
  static const Color friendsLabelColor = colorNeonRed;
  static const double friendsLabelFontSize = 17;

  static const double tickerX = 100;
  static const double tickerY = 700;
  static const double tickerWidth = 1275;
  static const Color tickerColor = colorNeonRed;
  static const double tickerFontSize = 16;
  static const int friendsScrollSpeed = 2; // Скорость для друзей

  // --- БЕГУЩАЯ СТРОКА ИГР ---
  static const double gamesLabelX = 100;
  static const double gamesLabelY = 800;
  static const Color gamesLabelColor = colorNeonRed;
  static const double gamesLabelFontSize = 17;

  static const double gamesTickerX = 100;
  static const double gamesTickerY = 850;
  static const double gamesTickerWidth = 1275;
  static const Color gamesTickerColor = colorNeonRed;
  static const double gamesTickerFontSize = 16;
  static const int gamesScrollSpeed = 3; // Ускорено на 25% (было 2, стало 2.5, округлили до 3)

  // --- КНОПКА СОРТИРОВКИ ---
  static const double sortBtnX = 1365; 
  static const double sortBtnY = 310; 
  static const double sortBtnSize = 100;
  static const Color sortBtnColor = colorBlack;

  // --- КНОПКА НАСТРОЕК ---
  static const double settingsBtnX = 2103;
  static const double settingsBtnY = 240;
  static const double settingsBtnSize = 40;
  static const Color settingsBtnColor = colorBlack;

  // --- КОПИРАЙТ ---
  static const double copyrightX = 1200;
  static const double copyrightY = 1050;
  static const Color copyrightColor = colorNeonRed;
  static const double copyrightFontSize = 14;
}
// =====================================================================

// =====================================================================
// ВИДЖЕТ АВАТАРА С ГЛИТЧЕМ
// =====================================================================
class GlitchAvatar extends StatefulWidget {
  final String avatarUrl;
  final bool isGlitchEnabled;

  const GlitchAvatar({
    super.key, 
    required this.avatarUrl, 
    required this.isGlitchEnabled
  });

  @override
  State<GlitchAvatar> createState() => _GlitchAvatarState();
}

class _GlitchAvatarState extends State<GlitchAvatar> {
  Timer? _glitchTimer;
  Timer? _glitchAnimTimer;
  int _glitchFrame = -1;

  @override
  void initState() {
    super.initState();
    _glitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.isGlitchEnabled) {
        _triggerGlitch();
      }
    });
  }

  void _triggerGlitch() {
    int frameCount = 0;
    setState(() => _glitchFrame = 0);

    _glitchAnimTimer?.cancel();
    _glitchAnimTimer = Timer.periodic(const Duration(milliseconds: 111), (timer) {
      frameCount++;
      if (frameCount >= 3) {
        timer.cancel();
        setState(() => _glitchFrame = -1);
      } else {
        setState(() => _glitchFrame = frameCount);
      }
    });
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _glitchAnimTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.avatarUrl.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        Image.network(
          widget.avatarUrl, 
          fit: BoxFit.cover, 
          width: LayoutConfig.avatarWidth, 
          height: LayoutConfig.avatarHeight
        ),
        if (_glitchFrame >= 0 && widget.isGlitchEnabled)
          Positioned.fill(
            child: Image.asset(
              'assets/avatar_glitch/${_glitchFrame + 1}.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.8),
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}
// =====================================================================

// =====================================================================
// ВИДЖЕТ БЕГУЩЕЙ СТРОКИ ДЛЯ ОДНОЙ ЛИНИИ (ТОЧКИ)
// =====================================================================
class RunningDotsRow extends StatefulWidget {
  final double width;
  final Color color;
  final double dotSize;

  const RunningDotsRow({
    super.key,
    required this.width,
    required this.color,
    required this.dotSize,
  });

  @override
  State<RunningDotsRow> createState() => _RunningDotsRowState();
}

class _RunningDotsRowState extends State<RunningDotsRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double spacing = widget.dotSize * 3;
    int dotCount = (widget.width / spacing).floor();

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double offset = -(_controller.value * spacing);
          return Stack(
            children: List.generate(dotCount, (index) {
              return Positioned(
                left: (index * spacing) + offset,
                top: 0,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
// =====================================================================

// =====================================================================
// ВИДЖЕТ ПЛАВНОЙ БЕГУЩЕЙ СТРОКИ (ДЛЯ ИГР)
// =====================================================================
class TextMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double maxWidth;

  const TextMarquee({
    super.key,
    required this.text,
    required this.style,
    required this.maxWidth,
  });

  @override
  State<TextMarquee> createState() => _TextMarqueeState();
}

class _TextMarqueeState extends State<TextMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _textWidth = 0;
  bool _needsScrolling = false;
  bool _isInitialized = false;

  static const Duration _pauseDuration = Duration(seconds: 3);
  static const double _scrollSpeed = 60.0;
  static const double _gap = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _measureText();
  }

  void _measureText() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = textPainter.width;
    _needsScrolling = _textWidth > widget.maxWidth;

    if (_needsScrolling) {
      final double distance = _textWidth + _gap;
      final double durationSec = distance / _scrollSpeed;
      _controller.duration = Duration(milliseconds: (durationSec * 1000).toInt());
      _startLoopWithPause();
    } else {
      _controller.stop();
    }

    _isInitialized = true;
    setState(() {});
  }

  Future<void> _startLoopWithPause() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    while (mounted) {
      await Future.delayed(_pauseDuration);
      if (!mounted) return;

      _controller.reset();
      try {
        await _controller.forward().orCancel;
      } on TickerCanceled {
        return;
      }
      if (!mounted) return;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !_needsScrolling) {
      return SizedBox(
        width: widget.maxWidth,
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
        ),
      );
    }

    final double distance = _textWidth + _gap;
    final double offset = -(_controller.value * distance);

    return ClipRect(
      child: SizedBox(
        width: widget.maxWidth,
        height: widget.style.fontSize != null
            ? widget.style.fontSize! * 1.4
            : null,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: offset,
              top: 0,
              child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
            ),
            Positioned(
              left: offset + distance,
              top: 0,
              child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
            ),
          ],
        ),
      ),
    );
  }
}
// =====================================================================

// =====================================================================
// ВИДЖЕТ БЕГУЩЕЙ СТРОКИ (УНИВЕРСАЛЬНЫЙ, ДЛЯ ДРУЗЕЙ И ИГР)
// =====================================================================
class FriendsTicker extends StatefulWidget {
  final List<String> items;
  final double width;
  final TextStyle style;
  final int scrollSpeed; // Новый параметр для скорости

  const FriendsTicker({
    super.key, 
    required this.items, 
    required this.width, 
    required this.style,
    this.scrollSpeed = 2, // По умолчанию скорость 2
  });

  @override
  State<FriendsTicker> createState() => _FriendsTickerState();
}

class _FriendsTickerState extends State<FriendsTicker> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer?.cancel();
    if (!_scrollController.hasClients) return;

    double maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          // Используем переданную скорость
          _scrollController.jumpTo(currentScroll + widget.scrollSpeed);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    List<String> repeatedItems = List.from(widget.items);
    while (repeatedItems.length < 30) {
      repeatedItems.addAll(widget.items);
    }

    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: repeatedItems.map((name) {
            return Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Center(
                child: Text(name, style: widget.style, maxLines: 1, softWrap: false),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
// =====================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const SteamDashboardApp());
  });
}

class SteamDashboardApp extends StatelessWidget {
  const SteamDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Steam Cyberdeck',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'CP_Revenge', 
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _steamId = "";
  String _nickname = "Loading...";
  String _region = "Unknown";
  String _avatarUrl = "";
  int _friendCount = 0;
  int _gameCount = 0; 
  int _steamLevel = 0;
  String _accountCreatedDate = "...";
  
  List<Map<String, dynamic>> _games = [];
  List<String> _friendNames = [];
  List<String> _recentIds = []; 
  Map<String, String> _historyNicknames = {};
  
  bool _sortByMostPlayed = false;
  bool _isLoading = false;
  bool _showSettings = false;

  bool _isGlitchEnabled = true; 

  Timer? _refreshTimer;
  final TextStyle _baseStyle = const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0);

  @override
  void initState() {
    super.initState();
    _loadSavedSteamId();
    _loadGlitchSetting();

    _refreshTimer = Timer.periodic(Duration(minutes: AppConfig.refreshIntervalMinutes), (timer) {
      if (!_isLoading && !_showSettings && _steamId.isNotEmpty) {
        _fetchSteamData(_steamId);
      }
    });
  }

  Future<void> _loadGlitchSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGlitchEnabled = prefs.getBool('avatar_glitch') ?? true;
    });
  }

  Future<void> _toggleGlitch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('avatar_glitch', value);
    setState(() {
      _isGlitchEnabled = value;
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedSteamId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('steam_id');
    final historyJson = prefs.getString('recent_ids');

    if (historyJson != null) {
      setState(() {
        _recentIds = List<String>.from(jsonDecode(historyJson));
      });
      _fetchHistoryNicknames();
    }

    if (savedId != null && savedId.isNotEmpty) {
      setState(() => _steamId = savedId);
      _fetchSteamData(savedId);
    } else {
      setState(() => _showSettings = true);
    }
  }

  Future<void> _saveSteamId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('steam_id', id);

    setState(() {
      _recentIds.remove(id);
      _recentIds.insert(0, id);
      if (_recentIds.length > 3) {
        _recentIds = _recentIds.sublist(0, 3);
      }
    });
    
    await prefs.setString('recent_ids', jsonEncode(_recentIds));
    _fetchHistoryNicknames();
  }

  Future<void> _fetchHistoryNicknames() async {
    if (_recentIds.isEmpty) return;
    String ids = _recentIds.join(',');
    try {
      final res = await http.get(Uri.parse(SteamAPI.getPlayerSummariesUrl(ids)));
      if (res.statusCode == 200) {
        final players = jsonDecode(res.body)['response']['players'];
        Map<String, String> newNicknames = {};
        for (var p in players) {
          newNicknames[p['steamid'].toString()] = p['personaname'] ?? "Unknown";
        }
        setState(() {
          _historyNicknames.addAll(newNicknames);
        });
      }
    } catch (e) {
      print("Ошибка загрузки ников для истории: $e");
    }
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return "Unknown";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  Future<void> _fetchSteamData(String steamId) async {
    if (AppConfig.steamApiKey == "ВАШ_КЛЮЧ_ЗДЕСЬ" || AppConfig.steamApiKey.isEmpty) {
      _showError("Укажите Steam API Key в файле config.dart!");
      return;
    }

    setState(() {
      _isLoading = true;
      _friendNames.clear();
      _games.clear();
      _nickname = "Loading...";
      _avatarUrl = "";
      _accountCreatedDate = "...";
    });

    try {
      // 1. Профиль
      String profileUrlStr = SteamAPI.getPlayerSummariesUrl(steamId);
      final profileRes = await http.get(Uri.parse(profileUrlStr));
      
      if (profileRes.statusCode == 200) {
        final body = jsonDecode(profileRes.body);
        final players = body['response']['players'];
        if (players != null && players.isNotEmpty) {
          _nickname = players[0]['personaname'] ?? "Unknown";
          _region = players[0]['loccountrycode'] ?? "Unknown";
          _avatarUrl = players[0]['avatarfull'] ?? "";
          int timeCreated = players[0]['timecreated'] ?? 0;
          _accountCreatedDate = _formatDate(timeCreated);
        }
      }

      // 1.5. Уровень Steam
      try {
        final levelRes = await http.get(Uri.parse(SteamAPI.getSteamLevelUrl(steamId)));
        if (levelRes.statusCode == 200) {
          final levelData = jsonDecode(levelRes.body);
          _steamLevel = levelData['response']['player_level'] ?? 0;
        }
      } catch (e) {}

      // 2. Друзья
      try {
        String friendsUrlStr = SteamAPI.getFriendListUrl(steamId);
        final friendsRes = await http.get(Uri.parse(friendsUrlStr));
        
        if (friendsRes.statusCode == 200) {
          final body = jsonDecode(friendsRes.body);
          final friendsData = body['friendslist']?['friends'];
          
          if (friendsData != null) {
            List<String> friendIds = (friendsData as List).map((f) => f['steamid'].toString()).toList();
            _friendCount = friendIds.length;

            for (var i = 0; i < friendIds.length; i += 100) {
              final chunk = friendIds.skip(i).take(100).join(',');
              final namesRes = await http.get(Uri.parse(SteamAPI.getPlayerSummariesUrl(chunk)));
              
              if (namesRes.statusCode == 200) {
                final namesData = jsonDecode(namesRes.body)['response']['players'];
                for (var p in namesData) {
                  _friendNames.add(p['personaname'] ?? "Unknown");
                }
              }
            }
          }
        }
      } catch (e) {
        _friendCount = 0;
      }

      // 3. Игры
      try {
        String gamesUrlStr = SteamAPI.getOwnedGamesUrl(steamId);
        final gamesRes = await http.get(Uri.parse(gamesUrlStr));
        
        if (gamesRes.statusCode == 200) {
          final gamesData = jsonDecode(gamesRes.body)['response'];
          if (gamesData != null && gamesData['games'] != null) {
            _gameCount = gamesData['game_count'] ?? 0;
            List<dynamic> rawGames = gamesData['games'];
            
            rawGames.sort((a, b) => (b['rtime_last_played'] ?? 0).compareTo(a['rtime_last_played'] ?? 0));
            
            _games = rawGames.map((g) {
              return {
                'name': g['name'] ?? "Unknown",
                'playtime': g['playtime_forever'] ?? 0,
                'last_played': g['rtime_last_played'] ?? 0,
              };
            }).toList();
          }
        }
      } catch (e) {
        _gameCount = 0;
      }
      
      setState(() {
        _isLoading = false;
        _showSettings = false;
      });
      
    } catch (e, stacktrace) {
      _showError("Ошибка сети: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatPlaytime(int minutes) {
    if (minutes == 0) return "0.0h";
    return "${(minutes / 60).toStringAsFixed(1)}h";
  }

  List<Map<String, dynamic>> get _sortedGames {
    List<Map<String, dynamic>> sorted = List.from(_games);
    if (_sortByMostPlayed) {
      sorted.sort((a, b) => b['playtime'].compareTo(a['playtime']));
    } else {
      sorted.sort((a, b) => b['last_played'].compareTo(a['last_played']));
    }
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: AppConfig.bgWidth,
          height: AppConfig.bgHeight,
          child: Stack(
            children: [
              // 1. АВАТАР + ГЛИТЧ
              if (_avatarUrl.isNotEmpty)
                Positioned(
                  left: LayoutConfig.avatarX,
                  top: LayoutConfig.avatarY,
                  width: LayoutConfig.avatarWidth,
                  height: LayoutConfig.avatarHeight,
                  child: GlitchAvatar(
                    avatarUrl: _avatarUrl,
                    isGlitchEnabled: _isGlitchEnabled,
                  ),
                ),

              // 2. ФОН
              Positioned.fill(
                child: Image.asset('assets/bg.png', fit: BoxFit.fill),
              ),
              
              // БЕГУЩИЕ ТОЧКИ
              Positioned(
                left: LayoutConfig.dotsStartX + LayoutConfig.dotsRow1_OffsetX,
                top: LayoutConfig.nicknameY + 20, 
                width: 500 + (-LayoutConfig.dotsRow1_OffsetX), 
                height: 10,
                child: RunningDotsRow(
                  width: 500 + (-LayoutConfig.dotsRow1_OffsetX), 
                  color: LayoutConfig.dotsProfileColor,
                  dotSize: LayoutConfig.dotsProfileSize,
                ),
              ),
              Positioned(
                left: LayoutConfig.dotsStartX + LayoutConfig.dotsRow2_OffsetX,
                top: LayoutConfig.friendsY + 20, 
                width: 580 + (-LayoutConfig.dotsRow2_OffsetX), 
                height: 10,
                child: RunningDotsRow(
                  width: 580 + (-LayoutConfig.dotsRow2_OffsetX),
                  color: LayoutConfig.dotsProfileColor,
                  dotSize: LayoutConfig.dotsProfileSize,
                ),
              ),
              Positioned(
                left: LayoutConfig.dotsStartX + LayoutConfig.dotsRow3_OffsetX,
                top: LayoutConfig.gamesCountY + 20, 
                width: 580 + (-LayoutConfig.dotsRow3_OffsetX),
                height: 10,
                child: RunningDotsRow(
                  width: 580 + (-LayoutConfig.dotsRow3_OffsetX),
                  color: LayoutConfig.dotsProfileColor,
                  dotSize: LayoutConfig.dotsProfileSize,
                ),
              ),
              // 4-я строка (Создан)
              Positioned(
                left: LayoutConfig.dotsStartX + LayoutConfig.dotsRow4_OffsetX,
                top: LayoutConfig.createdY + 20, 
                width: (580 + (-LayoutConfig.dotsRow4_OffsetX)) - 130,
                height: 10,
                child: RunningDotsRow(
                  width: (580 + (-LayoutConfig.dotsRow4_OffsetX)) - 130,
                  color: LayoutConfig.dotsProfileColor,
                  dotSize: LayoutConfig.dotsProfileSize,
                ),
              ),
              
              // ACCOUNT
              Positioned(
                left: LayoutConfig.accountX,
                top: LayoutConfig.accountY,
                child: Text("$_steamId // $_nickname", style: _baseStyle.copyWith(color: LayoutConfig.accountColor, fontSize: LayoutConfig.accountFontSize)),
              ),
              
              // REGION
              Positioned(
                left: LayoutConfig.regionX,
                top: LayoutConfig.regionY,
                child: Text(_region, style: _baseStyle.copyWith(color: LayoutConfig.regionColor, fontSize: LayoutConfig.regionFontSize)),
              ),
              
              // ПРОФИЛЬ
              Positioned(
                top: LayoutConfig.nicknameY,
                right: AppConfig.bgWidth - LayoutConfig.profileRightEdgeX, 
                child: Text(_nickname, style: _baseStyle.copyWith(color: LayoutConfig.nicknameColor, fontSize: LayoutConfig.nicknameFontSize)),
              ),
              Positioned(
                top: LayoutConfig.friendsY,
                right: AppConfig.bgWidth - LayoutConfig.profileRightEdgeX,
                child: Text("($_friendCount)", style: _baseStyle.copyWith(color: LayoutConfig.friendsColor, fontSize: LayoutConfig.friendsFontSize)),
              ),
              Positioned(
                top: LayoutConfig.gamesCountY,
                right: AppConfig.bgWidth - LayoutConfig.profileRightEdgeX,
                child: Text("($_gameCount)", style: _baseStyle.copyWith(color: LayoutConfig.gamesCountColor, fontSize: LayoutConfig.gamesCountFontSize)),
              ),
              Positioned(
                top: LayoutConfig.createdY,
                right: AppConfig.bgWidth - LayoutConfig.profileRightEdgeX,
                child: Text(_accountCreatedDate, style: _baseStyle.copyWith(color: LayoutConfig.createdColor, fontSize: LayoutConfig.createdFontSize)),
              ),

              // УРОВЕНЬ STEAM
              Positioned(
                left: _steamLevel >= 10 
                    ? LayoutConfig.steamLevelX - 20 
                    : LayoutConfig.steamLevelX,
                top: LayoutConfig.steamLevelY,
                child: Text("$_steamLevel", style: _baseStyle.copyWith(color: LayoutConfig.steamLevelColor, fontSize: LayoutConfig.steamLevelFontSize)),
              ),
              
              // БЕГУЩАЯ СТРОКА ДРУЗЕЙ
              Positioned(
                left: LayoutConfig.friendsLabelX,
                top: LayoutConfig.friendsLabelY,
                child: Text("Friends:", style: _baseStyle.copyWith(color: LayoutConfig.friendsLabelColor, fontSize: LayoutConfig.friendsLabelFontSize)),
              ),
              Positioned(
                left: LayoutConfig.tickerX,
                top: LayoutConfig.tickerY,
                width: LayoutConfig.tickerWidth,
                height: 30, 
                child: FriendsTicker(
                  key: UniqueKey(),
                  items: _friendNames,
                  width: LayoutConfig.tickerWidth,
                  style: _baseStyle.copyWith(color: LayoutConfig.tickerColor, fontSize: LayoutConfig.tickerFontSize),
                  scrollSpeed: LayoutConfig.friendsScrollSpeed,
                ),
              ),

              // КНОПКА СОРТИРОВКИ
              Positioned(
                left: LayoutConfig.sortBtnX, 
                top: LayoutConfig.sortBtnY, 
                child: GestureDetector(
                  onTap: () => setState(() => _sortByMostPlayed = !_sortByMostPlayed),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.transparent,
                    child: Icon(
                      _sortByMostPlayed ? Icons.arrow_drop_up : Icons.arrow_drop_down, 
                      color: LayoutConfig.sortBtnColor,
                      size: LayoutConfig.sortBtnSize,
                    ),
                  ),
                ),
              ),

              // ЗАГОЛОВОК СПИСКА
              Positioned(
                left: LayoutConfig.gamesTitleX,
                top: LayoutConfig.gamesTitleY,
                child: Text(
                  _sortByMostPlayed ? "MOST PLAYED:" : "LAST GAMES:",
                  style: _baseStyle.copyWith(color: LayoutConfig.gamesTitleColor, fontSize: LayoutConfig.gamesTitleFontSize, letterSpacing: 1.5),
                ),
              ),
              
              // ИГРЫ
              if (_sortedGames.isNotEmpty)
                Positioned(
                  left: LayoutConfig.game1X, 
                  top: LayoutConfig.game1Y,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: LayoutConfig.gameNameMaxWidth,
                        height: 40, 
                        child: TextMarquee(
                          key: ValueKey('game1_${_sortedGames[0]['name']}'),
                          text: _sortedGames[0]['name'].toString(),
                          style: _baseStyle.copyWith(color: LayoutConfig.game1NameColor, fontSize: LayoutConfig.game1NameFontSize),
                          maxWidth: LayoutConfig.gameNameMaxWidth,
                        ),
                      ),
                      SizedBox(height: LayoutConfig.gameTimeOffsetY),
                      Text("(${_formatPlaytime(_sortedGames[0]['playtime'])})", style: _baseStyle.copyWith(color: LayoutConfig.gameTimeColor, fontSize: LayoutConfig.gameTimeFontSize)),
                    ],
                  ),
                ),
              if (_sortedGames.length > 1)
                Positioned(
                  left: LayoutConfig.game2X, 
                  top: LayoutConfig.game2Y,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: LayoutConfig.gameNameMaxWidth,
                        height: 40,
                        child: TextMarquee(
                          key: ValueKey('game2_${_sortedGames[1]['name']}'),
                          text: _sortedGames[1]['name'].toString(),
                          style: _baseStyle.copyWith(color: LayoutConfig.game2NameColor, fontSize: LayoutConfig.game2NameFontSize),
                          maxWidth: LayoutConfig.gameNameMaxWidth,
                        ),
                      ),
                      SizedBox(height: LayoutConfig.gameTimeOffsetY),
                      Text("(${_formatPlaytime(_sortedGames[1]['playtime'])})", style: _baseStyle.copyWith(color: LayoutConfig.gameTimeColor, fontSize: LayoutConfig.gameTimeFontSize)),
                    ],
                  ),
                ),
              if (_sortedGames.length > 2)
                Positioned(
                  left: LayoutConfig.game3X, 
                  top: LayoutConfig.game3Y,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: LayoutConfig.gameNameMaxWidth,
                        height: 40,
                        child: TextMarquee(
                          key: ValueKey('game3_${_sortedGames[2]['name']}'),
                          text: _sortedGames[2]['name'].toString(),
                          style: _baseStyle.copyWith(color: LayoutConfig.game3NameColor, fontSize: LayoutConfig.game3NameFontSize),
                          maxWidth: LayoutConfig.gameNameMaxWidth,
                        ),
                      ),
                      SizedBox(height: LayoutConfig.gameTimeOffsetY),
                      Text("(${_formatPlaytime(_sortedGames[2]['playtime'])})", style: _baseStyle.copyWith(color: LayoutConfig.gameTimeColor, fontSize: LayoutConfig.gameTimeFontSize)),
                    ],
                  ),
                ),

              // НОВАЯ БЕГУЩАЯ СТРОКА ИГР (Скорость 3)
              Positioned(
                left: LayoutConfig.gamesLabelX,
                top: LayoutConfig.gamesLabelY,
                child: Text("Games:", style: _baseStyle.copyWith(color: LayoutConfig.gamesLabelColor, fontSize: LayoutConfig.gamesLabelFontSize)),
              ),
              Positioned(
                left: LayoutConfig.gamesTickerX,
                top: LayoutConfig.gamesTickerY,
                width: LayoutConfig.gamesTickerWidth,
                height: 30, 
                child: FriendsTicker(
                  key: UniqueKey(),
                  items: _games.map((g) => g['name'].toString()).toList(),
                  width: LayoutConfig.gamesTickerWidth,
                  style: _baseStyle.copyWith(color: LayoutConfig.gamesTickerColor, fontSize: LayoutConfig.gamesTickerFontSize),
                  scrollSpeed: LayoutConfig.gamesScrollSpeed, // Ускоренная скорость
                ),
              ),

              // КНОПКА НАСТРОЕК
              Positioned(
                left: LayoutConfig.settingsBtnX,
                top: LayoutConfig.settingsBtnY,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showSettings = !_showSettings);
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.settings, color: LayoutConfig.settingsBtnColor, size: LayoutConfig.settingsBtnSize),
                  ),
                ),
              ),

              // КОПИРАЙТ
              Positioned(
                left: LayoutConfig.copyrightX,
                top: LayoutConfig.copyrightY,
                child: GestureDetector(
                  onTap: () async {
                    final url = Uri.parse('https://listo4ek.tech/');
                    // Пытаемся открыть ссылку во внешнем браузере
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      // Если не удалось, пробуем стандартный режим
                      await launchUrl(url);
                    }
                  },
                  child: Text(
                    "LST inc., 2026", 
                    style: _baseStyle.copyWith(color: LayoutConfig.copyrightColor, fontSize: LayoutConfig.copyrightFontSize)
                  ),
                ),
              ),

              // ОВЕРЛЕЙ НАСТРОЕК
              if (_showSettings)
                Positioned.fill(
                  child: SettingsOverlay(
                    currentId: _steamId,
                    recentIds: _recentIds,
                    historyNicknames: _historyNicknames,
                    isGlitchEnabled: _isGlitchEnabled,
                    onGlitchChanged: _toggleGlitch,
                    onIdSelected: (newId) {
                      setState(() => _steamId = newId); 
                      _saveSteamId(newId);
                      _fetchSteamData(newId);
                    },
                    onClose: () => setState(() => _showSettings = false),
                  ),
                ),
                
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(child: CircularProgressIndicator(color: LayoutConfig.colorNeonRed)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}