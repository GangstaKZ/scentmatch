# ScentMatch

Flutter MVP персонального парфюмерного ассистента. Русский интерфейс и тёмная тема по умолчанию; английский и светлая тема переключаются в профиле. Текущая проверенная версия — Flutter **3.47.7**, Dart **3.13.5**. Платформенные проекты первоначально сгенерированы Flutter 3.24.5, затем тема переведена на `CardThemeData`. Riverpod 2.6.1, go_router 14.6.2, Material 3; зависимости зафиксированы в `pubspec.lock`.

**[Открыть демо ScentMatch](https://gangstakz.github.io/scentmatch/)** · [Репозиторий](https://github.com/GangstaKZ/scentmatch) · [Сборки и проверки](https://github.com/GangstaKZ/scentmatch/actions)

Публикация на GitHub Pages — локальный деморежим приложения в браузере. Firebase, общие отзывы, OpenAI и платежи эта публикация автоматически не подключает. Данные демо хранятся в браузере пользователя и не синхронизируются между устройствами.

| Возможность | Состояние |
| --- | --- |
| Квиз, подборки по правилам, поиск, коллекция/Wishlist, оценки, заметки, RU/EN, темы | Работают в демо |
| Отзывы | Локальные в демо; общие через Firestore после настройки Firebase |
| Вход email/Google и облачное хранение | Код реализован; нужны Firebase/OAuth и проверка на реальном проекте |
| OpenAI | Опциональный серверный адаптер; без подключения используются правила |
| Сканирование флакона | Заглушка |
| Pro / RevenueCat | Экран предварительного обзора и адаптер; покупок и webhook пока нет |
| «Где купить» | Заглушка до настройки HTTPS-партнёрской ссылки |

## Быстрый запуск

Для воспроизводимого запуска используйте Flutter **3.47.7**, как в обоих workflow. В `pubspec.yaml` заявлен минимум Flutter 3.32, но другие версии отдельно не проверялись; старый локальный SDK 3.24.5 текущую тему не поддерживает. Dart входит в Flutter SDK, отдельно устанавливать его не нужно. Для web нужен Chrome, для Android — Android SDK/JDK и устройство или эмулятор, для iOS — macOS/Xcode.

Все команды ниже выполняются из корня проекта — папки с `pubspec.yaml`, `lib` и `android`. Каждый раздел — отдельный сценарий: перед его выполнением вернитесь в корень проекта.

```sh
flutter pub get
flutter run
```

Для просмотра на компьютере:

```sh
flutter run -d chrome
```

Проверить, какой SDK выбран: `flutter --version`. Если Flutter не найден, добавьте его папку `bin` и Git в `PATH`.

На Windows можно также выполнить `./run-demo.ps1`: он ищет Flutter в `PATH`, затем в `C:\src\flutter`. Для другого устройства: `./run-demo.ps1 -Device <id>`, где ID берётся из `flutter devices`. Если политика PowerShell запрещает скрипты, используйте обычные команды `flutter` выше.

`Start-ScentMatch.cmd` — дополнительный запуск для исходной рабочей папки Codex. Он использует SDK `C:\src\flutter`, Git `C:\Program Files\Git\cmd` и кеш `..\..\work\pub-cache`. Для копии проекта на другом компьютере эти пути могут не подходить; основной переносимый способ — установленный Flutter и `flutter run -d chrome`.

Без дополнительных параметров приложение запускается в **локальном деморежиме**. Оно не требует Firebase, API-ключей или аккаунта. Квиз, коллекция, Wishlist, оценки, заметки, отзывы и настройки сохраняются на устройстве через SharedPreferences. Демо не имитирует успешный вход через Google/email. Для реальной авторизации включите Firebase.

## Реализованные сценарии

- Онбординг → квиз из 7 вопросов → сохранение профиля → до 6 персональных рекомендаций (в комплектном демо-каталоге — 6).
- Главная: подборка по квизу, демонстрационная популярная подборка, быстрый поиск, заглушка сканера.
- Поиск по названию и бренду без учёта регистра; совместимые фильтры семьи, бренда, бюджета и пола.
- Карточка: флакон, ноты, стойкость, шлейф, сезон, похожие ароматы, сохранение и отзывы.
- Коллекция/Wishlist: перенос между полками, оценка 0–5, приватная заметка, удаление. Один аромат хранится на одной полке, как в заданной схеме данных.
- Один отзыв на пользователя и аромат; повторная публикация обновляет его. Оценка от 1 до 5, текст до 2000 символов.
- Firebase Auth: регистрация и вход email/password, Google, сброс пароля, выход, восстановление сессии и защита маршрутов.
- Профиль: все ответы квиза, повторное прохождение, язык и тема, экран предварительного обзора Pro.
- Ошибки, состояния загрузки, пустые состояния, повторная загрузка, блокировка повторного нажатия во время сохранения.
- Аналитические события: `quiz_completed`, `collection_saved`, `affiliate_opened`. Личные заметки, отзывы, email и демографические ответы не отправляются в Analytics.

## Архитектура

```text
lib/
  app.dart                    # темы, локали, router
  main.dart                   # bootstrap Firebase / demo
  core/
    config/                   # флаги среды и FirebaseOptions
    data/                     # LocalStore
    localization/             # RU/EN-копирайт и словарь доменных ключей
    router/                   # auth guards, StatefulShellRoute
    services/                 # Analytics, Storage
    theme/                    # Material 3, Manrope, Cormorant Garamond
    providers.dart            # composition root и действия пользователя
  features/
    auth/                     # data, presentation
    catalog/                  # domain, data, presentation
    collection/               # domain, data, presentation
    home/
    onboarding/
    profile/                  # domain, data, presentation
    recommendations/          # алгоритм + Cloud Functions adapter
    reviews/                  # domain, data, presentation
    subscription/             # RevenueCat adapter + Pro preview
  shared/widgets/             # карточки, иллюстрации, loading/error, async buttons
assets/
  data/perfumes.json          # 20 демонстрационных ароматов
  fonts/                     # локальные шрифты и лицензии OFL
functions/
  src/                       # callable endpoint, ranking, optional OpenAI adapter
  scripts/seed.cjs            # импорт каталога через Admin SDK
  test/
test/                        # domain и widget-сценарии
```

Доменные модели не зависят от Flutter/Firebase. Репозитории отделены интерфейсами, Riverpod выбирает реализацию. Интерфейсы работают с репозиториями через composition root; сервисы можно заменить в тестах.

## Firebase: подключение реального проекта

В репозитории есть пример конфигурации, но нет заполненного `config/production.json`. Настройка вашего облачного проекта, OAuth и App Check — отдельный этап. По умолчанию `USE_FIREBASE=false`; создание GitHub-репозитория и публикация Pages не меняют этот флаг.

1. Создайте Firebase-проект, Firestore и Storage. В Authentication включите Email/Password и Google. Для web добавьте разрешённые домены; для текущего Pages-сайта — `gangstakz.github.io` без пути `/scentmatch/`.
2. Зарегистрируйте Android/iOS с идентификатором `com.scentmatch.scentmatch`; зарегистрируйте web отдельно. Добавьте Android SHA-1/SHA-256 для debug/release, OAuth consent screen и iOS URL scheme для Google.
3. Установите Firebase CLI и FlutterFire CLI. Выполните `firebase login`, `firebase use --add`, затем `flutterfire configure --platforms=android,ios,web`. Сохраните платформенные `google-services.json` и `GoogleService-Info.plist` в соответствующие native-проекты.
4. Выберите один способ Dart-конфигурации:
   - Скопируйте `config/firebase.example.json` в игнорируемый `config/production.json` и заполните **конфигурацией целевой платформы**. Android, iOS и web имеют разные APP_ID/API_KEY/OAuth client IDs.
   - Либо замените `lib/core/config/firebase_options.dart` файлом, сгенерированным FlutterFire (`flutterfire configure --out=lib/core/config/firebase_options.dart`), и передавайте `--dart-define=USE_FIREBASE=true`. Остальные настройки `AppConfig` — OAuth client IDs, App Check, удалённые рекомендации и партнёрские ссылки — по-прежнему передаются через `--dart-define` или JSON-конфигурацию; генерация FirebaseOptions их не устанавливает.
5. Gradle-плагин `com.google.gms.google-services` подключается автоматически, когда есть `android/app/google-services.json`. На iOS добавьте `REVERSED_CLIENT_ID` из plist в `CFBundleURLTypes`; `GOOGLE_IOS_CLIENT_ID` — iOS OAuth ID, `GOOGLE_CLIENT_ID` — web/server OAuth ID. Dart передаёт их отдельно.
6. Настройте App Check: Play Integrity / App Attest, зарегистрируйте debug token для разработки. Для web заполните `APP_CHECK_WEB_KEY`. Callable endpoint требует App Check вне эмулятора.

```sh
flutter run --dart-define-from-file=config/production.json
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Инструкция FlutterFire: https://firebase.google.com/docs/flutter/setup
Google Auth: https://firebase.google.com/docs/auth/flutter/federated-auth

Правила Firestore разрешают читать профиль, коллекцию и личные заметки только владельцу. Каталог и отзывы доступны авторизованным пользователям; редактировать можно только свой отзыв. Запись каталога, `isPro` и счётчиков API выполняется сервером/Admin SDK. Клиент не может выдать себе Pro. Эти правила пока не проверялись в Emulator Suite.

Схема совпадает с заданными путями: `users/{uid}`, `perfumes/{id}`, `collections/{uid}/items/{id}`, `reviews/{perfumeId}/items/{uid}`. К каталогу добавлены `family`, `price`, `color`, `popularity`. Даты — ISO 8601 в строковом формате, записи коллекции/отзывов в UTC. Это явно выбранный сериализуемый формат для одинакового поведения local/Firestore; при переходе на `Timestamp` измените обе стороны и правила.

## Seed

```sh
cd functions
npm ci
```

PowerShell, для эмулятора:

```powershell
$env:GCLOUD_PROJECT = 'demo-scentmatch'
$env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
npm run seed
```

Для облака уберите `FIRESTORE_EMULATOR_HOST`, настройте Application Default Credentials, задайте `GCLOUD_PROJECT` и `ALLOW_PRODUCTION_SEED` равными ID целевого проекта. Вход `firebase login` сам по себе не настраивает Admin SDK credentials. Скрипт откажется писать в production без точного совпадения. Он полностью перезаписывает 20 документов `perfumes/{id}` из seed, включая их `imageUrl`; остальные документы каталога и коллекции пользователей не затрагиваются. Выполняйте команды seed из папки `functions` при уже запущенном Firestore Emulator или доступном облачном проекте.

Каталог включает Chanel, Dior, Tom Ford, Byredo, Maison Francis Kurkdjian, Le Labo, Diptyque, Jo Malone, YSL, Versace и Montblanc. Цены, популярность, стойкость и подбор похожих ароматов — демонстрационные, не актуальные данные магазинов. Ноты — иллюстративный набор, который следует проверить по конкретной концентрации перед коммерческим запуском. Фото заменены оригинальными Flutter-иллюстрациями флаконов; для лицензированных packshot задайте `imageUrl`.

## Эмуляторы

Нужны Firebase CLI, Java и Node 22. `.firebaserc` по умолчанию указывает безопасный демонстрационный проект `demo-scentmatch`.

```sh
cd functions
npm ci
npm run build
cd ..
firebase emulators:start --project demo-scentmatch
```

Подготовьте отдельный локальный `config/emulator.json` с той же структурой, что `config/firebase.example.json`: `USE_FIREBASE=true`, `FIREBASE_PROJECT_ID=demo-scentmatch`, обязательные публичные поля FirebaseOptions заполнены тестовыми значениями. Это файл, который нужно создать, он не входит в репозиторий. Не используйте без изменений production-конфигурацию: ID приложения, seed-скрипта и CLI должен совпадать. Передавайте этот локальный файл только с `USE_EMULATORS=true`.

```sh
flutter run --dart-define-from-file=config/emulator.json --dart-define=USE_EMULATORS=true --dart-define=EMULATOR_HOST=10.0.2.2
```

В примере выше `10.0.2.2` — адрес компьютера из Android Emulator. Для web/iOS simulator замените его на `localhost`; для физического телефона — на локальный IP машины. Android debug manifest при необходимости должен разрешать HTTP-подключение к локальным эмуляторам. Google OAuth проверяйте с настоящим настроенным Firebase-проектом; эмулятор предназначен прежде всего для email/Auth, Firestore и Functions. Это инструкция настройки, а не подтверждение уже выполненного emulator smoke-теста. [Документация подключения](https://firebase.google.com/docs/emulator-suite/connect_firestore).

## Рекомендации и OpenAI

По умолчанию используется прозрачная локальная заглушка: семья — 35 баллов, пол/унисекс — 15, бюджет — 20, сезон — 15, стойкость — 10, настроение — 5. Возраст сохраняется, но не используется для предсказания вкуса. Процент — совпадение с квизом, не вероятность и не уверенность ИИ.

Только комбинация **`USE_FIREBASE=true` и `USE_REMOTE_RECOMMENDATIONS=true`** переключает клиент на callable `recommendPerfumes` в `europe-west1`. Сервер читает профиль самостоятельно, не доверяет переданному клиентом userId и ограничивает запросы до 20 на пользователя в календарные сутки UTC. Запрос учитывается до вызова OpenAI, включая возврат fallback. Добавьте Firestore TTL для `recommendationUsage.expiresAt`, чтобы удалять старые счётчики.

```sh
cd functions
npm ci
npm test
cd ..
firebase deploy --only functions
```

Сервер тоже работает заглушкой без OpenAI. Для подключения OpenAI:

1. Задайте ключ: `firebase functions:secrets:set OPENAI_API_KEY`.
2. Создайте `functions/.env.<project-id>` с `AI_ENABLED=true`, `SCENTMATCH_BIND_OPENAI=true`, `OPENAI_MODEL=<доступная вам модель с Structured Outputs>`. Секрет не помещайте в `.env`.
3. Значение `SCENTMATCH_BIND_OPENAI=true` должно быть доступно и при обнаружении экспорта во время deploy, и в runtime. Для PowerShell перед deploy также задайте `$env:SCENTMATCH_BIND_OPENAI = 'true'`. Разверните функцию заново: `firebase deploy --only functions`. [Настройки и секреты Firebase](https://firebase.google.com/docs/functions/config-env).

Адаптер использует Responses API со строгой JSON Schema, timeout, проверкой ID, обработкой неполного ответа и fallback на локальное ранжирование. ИИ упорядочивает до шести кандидатов и может вернуть меньшую подборку; баллы остаются измерением совпадения с квизом. В OpenAI передаются семейство, бюджет, сезон, стойкость, настроение пользователя и данные ароматов-кандидатов. Имя, email, возраст и пол пользователя, отзывы и личные заметки в запрос не добавляются; поле `gender` самих ароматов входит в каталог. Живые API-вызовы пока не проверялись.

Официальная OpenAI Docs: https://developers.openai.com/api/docs/guides/structured-outputs

## RevenueCat и партнёрские ссылки

Экран Pro — честный предварительный обзор, платежей и искусственной активации Pro нет. `SubscriptionRepository` содержит `configure(userId)`, получение offerings, восстановление покупок и logout. Android/iOS public SDK keys задаются в config. При подключении реального paywall вызовите configure после входа, настройте products/offerings и entitlement `pro`. Добавьте авторизованный RevenueCat webhook с идемпотентностью, который сервером обновляет `users.isPro`; клиенту права на это не выдаются. Перед публикацией iOS с Google login предусмотрите Sign in with Apple по требованиям магазина.

Документация RevenueCat: https://www.revenuecat.com/docs/getting-started/installation/flutter

`AFFILIATE_BASE_URL` принимает только HTTPS URL вашего партнёрского поиска. К ссылке добавляются `perfume=<id>` и `q=<brand name>`. Перед переходом показывается раскрытие партнёрства, после перехода записывается аналитическое событие. Пустая настройка показывает «Магазины скоро появятся».

Сканер — заглушка. Следующее подключение: камера/image picker → распознавание в защищённой Cloud Function → поиск ID в каталоге. Сейчас приложение не запрашивает камеру и не отправляет фотографии.

## Проверки и выпуск

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
flutter build web --release
cd functions
npm ci
npm test
```

Команды выше соответствуют CI: форматирование проверяется без изменения файлов, информационные замечания анализатора (например, deprecated API) не делают job неуспешным. Для исправления форматирования отдельно выполните `dart format lib test`.

Widget-тесты используют детерминированный каталог с теми же seed-данными, чтобы filesystem/cache вне fake clock не влияли на UI-сценарии. Они проверяют деморежим, а не настоящий вход Firebase или покупки. Для экспорта PNG экранов задайте `EXPORT_PREVIEWS=1` при запуске тестов. Изображения сохраняются в `preview/`.

На 14 октября 2026 для коммита `4045e9b` оба workflow — Validate ScentMatch и Deploy ScentMatch to Pages — успешно завершились на Flutter 3.47.7. Подробности и ссылки на запуски находятся в [VALIDATION.md](VALIDATION.md).

## Публикация web на GitHub Pages

Workflow [`.github/workflows/pages.yml`](.github/workflows/pages.yml) запускается при push в `main` или вручную через Actions. В Settings → Pages источником публикации должен быть GitHub Actions. [Документация GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

Он выполняет сборку без Firebase-конфигурации:

```sh
flutter build web --release --base-href="/scentmatch/"
```

Затем загружает `build/web` как Pages artifact и публикует его отдельным job. Сайт: [https://gangstakz.github.io/scentmatch/](https://gangstakz.github.io/scentmatch/). При переименовании репозитория измените `--base-href` и URL. Публичная сборка содержит только деморежим, Cloud Functions и Firebase rules этот workflow не развёртывает.

Если будете подключать Firebase к опубликованной версии, измените команду сборки и передайте публичные FirebaseOptions/флаги, настройте authorized domain и App Check. Ключ OpenAI и Admin service-account credentials в Flutter-сборку передавать нельзя.

Для локального просмотра готовой web-сборки (при установленном Python), из корня проекта:

```sh
flutter build web --release
python -m http.server 8080 --directory build/web
```

Откройте `http://localhost:8080`. Папку `build/web` нужно обслуживать HTTP-сервером; простое открытие `index.html` двойным щелчком не является корректным способом запуска Flutter web.

## Подготовка мобильного выпуска

CI подтверждает только Flutter-анализ, тесты, web build и TypeScript-проверки. Android APK/AAB и iOS archive пока не собирались в этих workflow. Платформенные файлы существуют, но совместимость Android Gradle/SDK и iOS/CocoaPods с текущим Flutter ещё нужно проверить на соответствующих машинах. Для Android заполните `android/key.properties` по примеру: release-сборка без keystore явно остановится. Debug не требует release credentials. iOS требует команды подписи в Xcode.

Перед промышленным выпуском остаются: конфигурация вашего Firebase/OAuth/App Check, проверка правил на Emulator Suite, живые Auth/API smoke-тесты, store signing, лицензированный каталог и фото, модерация/репорты отзывов, удаление аккаунта и данных, privacy policy, реальный платёжный webhook. Поиск пока загружает до 500 ароматов и фильтрует их на клиенте; для большого каталога нужен серверный поиск и пагинация. SharedPreferences используется только как удобное локальное демохранилище, не как зашифрованное хранилище личных данных.
