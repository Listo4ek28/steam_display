# <div align="center">

# 

# \# 📱 LST Steam Display

# 

# \*\*Кастомный виджет-дашборд для отображения профиля Steam в стиле киберпанк/ретро-футуризм.\*\*

# 

# \[!\[Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge\&logo=Flutter\&logoColor=white)](https://flutter.dev)

# \[!\[Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge\&logo=dart\&logoColor=white)](https://dart.dev)

# 

# </div>

# 

# \---

# 

# \## 📖 О проекте

# 

# \*\*LST Steam Display\*\* — это приложение на Flutter, созданное для отображения статистики Steam-аккаунта в виде стильного виджета. Оно идеально подходит для использования на планшетах, старых смартфонах или в качестве кастомной панели (Cyberdeck).

# 

# \### ✨ Особенности:

# \*   \*\*Кастомный дизайн:\*\* Неоновый стиль, собственный шрифт `CP\_Revenge` и фоновое изображение.

# \*   \*\*Глитч-эффект:\*\* Аватар профиля периодически "глючит" (можно отключить в настройках).

# \*   \*\*Актуальная статистика:\*\* Отображает уровень Steam, количество друзей, игр и дату создания аккаунта.

# \*   \*\*Топ игр:\*\* Показывает 3 последние или самые играемые игры с бегущей строкой для длинных названий.

# \*   \*\*История аккаунтов:\*\* Удобное сохранение последних введенных Steam ID.

# \*   \*\*Бегущие строки:\*\* Динамическое отображение списка друзей и всех игр.

# 

# \---

# 

# \## 🛠 Настройка перед запуском

# 

# Для работы приложения вам понадобится \*\*Steam Web API Key\*\*.

# 

# 1\. Получите ключ на сайте \[Steam Developer](https://steamcommunity.com/dev/apikey).

# 2\. В корне проекта создайте файл `lib/config.dart` (он специально исключен из Git).

# 3\. Добавьте в него следующий код:

# 

# ```dart

# class AppConfig {

# &#x20; // Вставьте ваш API ключ сюда

# &#x20; static const String steamApiKey = "ВАШ\_КЛЮЧ\_ЗДЕСЬ";

# &#x20; 

# &#x20; // Размеры фонового изображения (для позиционирования элементов)

# &#x20; static const double bgWidth = 1920; 

# &#x20; static const double bgHeight = 1080;

# &#x20; 

# &#x20; // Интервал автообновления данных (в минутах)

# &#x20; static const int refreshIntervalMinutes = 5;

# }

# 

# class SteamAPI {

# &#x20; static const String \_baseUrl = "https://api.steampowered.com";

# &#x20; static const String \_key = AppConfig.steamApiKey;

# 

# &#x20; static String getPlayerSummariesUrl(String ids) => "$\_baseUrl/ISteamUser/GetPlayerSummaries/v2/?key=$\_key\&steamids=$ids";

# &#x20; static String getFriendListUrl(String id) => "$\_baseUrl/ISteamUser/GetFriendList/v1/?key=$\_key\&steamid=$id\&relationship=friend";

# &#x20; static String getOwnedGamesUrl(String id) => "$\_baseUrl/IPlayerService/GetOwnedGames/v1/?key=$\_key\&steamid=$id\&include\_appinfo=true\&include\_played\_free\_games=true";

# &#x20; static String getSteamLevelUrl(String id) => "$\_baseUrl/IPlayerService/GetSteamLevel/v1/?key=$\_key\&steamid=$id";

# }

