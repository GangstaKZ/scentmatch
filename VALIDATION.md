# Проверки ScentMatch

## Подтверждённые CI-проверки — 14 октября 2026

Коммит `4045e9b4981c905210204265fbc85c5aedf4e59f` проверен в GitHub Actions. В обоих Flutter workflow используется 3.47.7; серверный job использует Node.js 22.

- [Validate ScentMatch](https://github.com/GangstaKZ/scentmatch/actions/runs/38473849698) — success: проверка форматирования, `flutter analyze --no-fatal-infos`, `flutter test`, web release build; отдельно — `npm ci` и `npm test` (TypeScript build и тест ранжирования).
- [Deploy ScentMatch to Pages](https://github.com/GangstaKZ/scentmatch/actions/runs/38473849706) — success: сборка с `--base-href="/scentmatch/"`, загрузка артефакта и deploy.
- [Опубликованное демо](https://gangstakz.github.io/scentmatch/) — ранее проверены HTTP 200 для страницы и `flutter_bootstrap.js`, корректный base href `/scentmatch/`.

Проверки относятся к деморежиму. Они не подтверждают живую авторизацию Firebase, работоспособность облачных правил, OpenAI, RevenueCat или мобильные release-сборки.

## Миграция темы — 14 октября 2026

`CardTheme` в `ThemeData` заменён на `CardThemeData`. SDK: Flutter 3.47.7 / Dart 3.13.5. Локальный `dart analyze lib` завершился с кодом 0: ошибок и предупреждений нет, есть 16 информационных замечаний (устаревшие API и стиль). Локальная release-сборка из Codex остановилась из-за запрета записи служебного файла `C:\src\flutter\bin\cache\lockfile`; позднее сборка на новой версии SDK подтверждена GitHub Actions, как указано выше.

## Исходная локальная проверка — 13 октября 2026

Среда: Windows, Flutter 3.24.5, Dart 3.5.4, Node.js 22. Проверяется исходный проект ScentMatch, а не статический макет.

- `flutter pub get`: зависимости разрешены; `pubspec.lock` сохранён.
- `dart format lib test`: исходники отформатированы.
- `flutter analyze`: без замечаний.
- `flutter test`: 7 тестов — seed/ссылки, составные фильтры, ранжирование, изоляция и сохранение коллекции, квиз/сохранение профиля, поиск/Wishlist/заметки/отзывы/локаль/тема, рендер основных экранов на 390×844.
- `flutter build web --release`: успешная компиляция приложения.
- `functions: npm test`: TypeScript build и тест соответствия ранжирования — успешно.
- `functions: npm audit`: 0 известных уязвимостей на момент проверки.
- PNG из работающих Flutter-виджетов в `preview/` визуально просмотрены: тёмная тема, русский текст, навигация, флаконы и карточки.

Не проверялись: Android APK/iOS archive, подпись магазинов, Firebase Emulator Suite, реальный облачный Firebase/Auth/Storage/App Check, живой OpenAI, RevenueCat purchases. У этих проверок есть внешние зависимости: Android SDK/JDK, macOS/Xcode, облачный проект и ключи. Они не заменены фиктивными успешными проверками.

Демо запускается без внешних ключей. Сканер и Pro намеренно представлены заглушками; OpenAI — опциональный серверный адаптер. Инструкция подключения находится в README.
