# 📱 LST Steam Display

Кастомный виджет-дашборд для отображения профиля Steam в стиле киберпанк. Приложение создано на Flutter и идеально подходит для использования на планшетах или в качестве кастомной панели.

## ✨ Особенности

* **Кастомный дизайн:** Неоновый стиль, шрифт CP_Revenge и фоновые изображения.
* **Глитч-эффект:** Аватар профиля периодически "глючит" (эффект можно отключить в настройках).
* **Актуальная статистика:** Отображает уровень Steam, количество друзей, игр и дату создания аккаунта.
* **Топ игр:** Показывает 3 последние или самые играемые игры с бегущей строкой для длинных названий.
* **История аккаунтов:** Сохраняет последние введенные Steam ID для быстрого переключения.
* **Бегущие строки:** Динамическое отображение списка друзей и всех игр.

## 🛠 Настройка перед запуском

Для работы приложения вам понадобится **Steam Web API Key**.
1. Получите ключ на сайте [Steam Developer](https://steamcommunity.com/dev/apikey).
2. В корне проекта создайте файл `lib/config.dart` (он специально исключен из Git).
3. Добавьте в него следующий код:

```dart
class AppConfig {
  // Вставьте ваш API ключ сюда
  static const String steamApiKey = "ВАШ_КЛЮЧ_ЗДЕСЬ";
  
  // Размеры фонового изображения
  static const double bgWidth = 1920; 
  static const double bgHeight = 1080;
  
  // Интервал автообновления данных (в минутах)
  static const int refreshIntervalMinutes = 5;
}

class SteamAPI {
  static const String _baseUrl = "https://api.steampowered.com";
  static const String _key = AppConfig.steamApiKey;

  static String getPlayerSummariesUrl(String ids) => "$_baseUrl/ISteamUser/GetPlayerSummaries/v2/?key=$_key&steamids=$ids";
  static String getFriendListUrl(String id) => "$_baseUrl/ISteamUser/GetFriendList/v1/?key=$_key&steamid=$id&relationship=friend";
  static String getOwnedGamesUrl(String id) => "$_baseUrl/IPlayerService/GetOwnedGames/v1/?key=$_key&steamid=$id&include_appinfo=true&include_played_free_games=true";
  static String getSteamLevelUrl(String id) => "$_baseUrl/IPlayerService/GetSteamLevel/v1/?key=$_key&steamid=$id";
}