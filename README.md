# ScentMatch

Flutter MVP персонального парфюмерного ассистента. Русский интерфейс и тёмная тема по умолчанию; английский и светлая тема переключаются в профиле. Android, iOS и web-проект сгенерированы Flutter 3.24.5. Riverpod 2.6.1, go_router 14.6.2, Material 3. Зафиксированные зависимости находятся в `pubspec.lock`.

## Быстрый запуск

Установите Flutter 3.47.7 (версия CI) или совместимую более новую версию. После миграции на `CardThemeData` минимальная версия — Flutter 3.32; старый локальный SDK 3.24.5 для текущего кода не подходит. Для Android нужны Android SDK и JDK, для iOS — macOS и Xcode.

```sh
flutter pub get
flutter run
```

Для просмотра на компьютере:

```sh
flutter run -d chrome
```

В этой рабочей папке Windows можно также выполнить `./run-demo.ps1`: скрипт найдёт установленный Flutter или локальный SDK, использованный для проверки. Для другого устройства: `./run-demo.ps1 -Device <id>`.

Без дополнительных параметров приложение запускается в **локальном деморежиме**. Оно не требует Firebase, API-ключей или аккаунта. Квиз, коллекция, Wishlist, оценки, заметки, отзывы и настройки сохраняются на устройстве через SharedPreferences. Демо не имитирует успешный вход через Google/email. Для реальной авторизации включите Firebase.

## Реализованные сценарии

- Онбординг → квиз из 7 вопросов → сохранение профиля → 6 персональных рекомендаций.
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

Проект в облаке не создан и не развёрнут: для этого нужны ваш Firebase project ID и зарегистрированные приложения.

1. Создайте Firebase-проект, Firestore и Storage. В Authentication включите Email/Password и Google. Для web добавьте разрешённые домены.
2. Зарегистрируйте Android/iOS с идентификатором `com.scentmatch.scentmatch`; зарегистрируйте web отдельно. Добавьте Android SHA-1/SHA-256 для debug/release, OAuth consent screen и iOS URL scheme для Google.
3. Установите Firebase CLI и FlutterFire CLI. Выполните `firebase login`, `firebase use --add`, затем `flutterfire configure --platforms=android,ios,web`. Сохраните платформенные `google-services.json` и `GoogleService-Info.plist` в соответствующие native-проекты.
4. Выберите один способ Dart-конфигурации:
   - Скопируйте `config/firebase.example.json` в игнорируемый `config/production.json` и заполните **конфигурацией целевой платформы**. Android, iOS и web имеют разные APP_ID/API_KEY/OAuth client IDs.
   - Либо замените `lib/core/config/firebase_options.dart` файлом, сгенерированным FlutterFire (`flutterfire configure --out=lib/core/config/firebase_options.dart`), и передавайте `--dart-define=USE_FIREBASE=true`.
5. Gradle-плагин `com.google.gms.google-services` подключается автоматически, когда есть `android/app/google-services.json`. На iOS добавьте `REVERSED_CLIENT_ID` из plist в `CFBundleURLTypes`; `GOOGLE_IOS_CLIENT_ID` — iOS OAuth ID, `GOOGLE_CLIENT_ID` — web/server OAuth ID. Dart передаёт их отдельно.
6. Настройте App Check: Play Integrity / App Attest, зарегистрируйте debug token для разработки. Для web заполните `APP_CHECK_WEB_KEY`. Callable endpoint требует App Check вне эмулятора.

```sh
flutter run --dart-define-from-file=config/production.json
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Инструкция FlutterFire: https://firebase.google.com/docs/flutter/setup
Google Auth: https://firebase.google.com/docs/auth/flutter/federated-auth

Данные пользователя доступны только владельцу. Запись каталога, `isPro` и счётчиков API разрешена только серверу/Admin SDK. Отзывы доступны авторизованным пользователям, редактировать можно только собственный документ. Клиент не может выдать себе Pro.

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

Для облака уберите `FIRESTORE_EMULATOR_HOST`, настройте Application Default Credentials, задайте `GCLOUD_PROJECT` и `ALLOW_PRODUCTION_SEED` равными ID целевого проекта. Скрипт откажется писать в production без точного совпадения. Он обновляет только 20 документов каталога; коллекции пользователей не затрагиваются.

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

Передайте Firebase config эмуляторного проекта и флаги:

```sh
flutter run --dart-define-from-file=config/production.json --dart-define=USE_EMULATORS=true --dart-define=EMULATOR_HOST=10.0.2.2
```

Для web/iOS simulator — `localhost`; для физического телефона — локальный IP машины. Android debug manifest при необходимости должен разрешать HTTP-подключение к локальным эмуляторам. Google OAuth проверяйте с настоящим настроенным Firebase-проектом; эмулятор предназначен прежде всего для email/Auth, Firestore и Functions.

## Рекомендации и OpenAI

По умолчанию используется прозрачная локальная заглушка: семья — 35 баллов, пол/унисекс — 15, бюджет — 20, сезон — 15, стойкость — 10, настроение — 5. Возраст сохраняется, но не используется для предсказания вкуса. Процент — совпадение с квизом, не вероятность и не уверенность ИИ.

`USE_REMOTE_RECOMMENDATIONS=true` переключает клиент на callable `recommendPerfumes` в `europe-west1`. Сервер читает профиль самостоятельно, не доверяет переданному клиентом userId и ограничивает запросы до 20 в сутки. Добавьте Firestore TTL для `recommendationUsage.expiresAt`, чтобы удалять старые счётчики.

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
3. Разверните функцию заново. `SCENTMATCH_BIND_OPENAI` подключает Secret Manager binding при обнаружении экспорта и в runtime.

Адаптер использует Responses API со строгой JSON Schema, timeout, проверкой ID, обработкой неполного ответа и fallback на локальное ранжирование. ИИ меняет порядок шести кандидатов, а баллы остаются измерением совпадения с квизом. Не отправляются имя, email, возраст, пол, отзывы и заметки. Реальные API-вызовы не выполнялись без ключа.

Официальная OpenAI Docs: https://developers.openai.com/api/docs/guides/structured-outputs

## RevenueCat и партнёрские ссылки

Экран Pro — честный предварительный обзор, платежей и искусственной активации Pro нет. `SubscriptionRepository` содержит `configure(userId)`, получение offerings, восстановление покупок и logout. Android/iOS public SDK keys задаются в config. При подключении реального paywall вызовите configure после входа, настройте products/offerings и entitlement `pro`. Добавьте авторизованный RevenueCat webhook с идемпотентностью, который сервером обновляет `users.isPro`; клиенту права на это не выдаются. Перед публикацией iOS с Google login предусмотрите Sign in with Apple по требованиям магазина.

Документация RevenueCat: https://www.revenuecat.com/docs/getting-started/installation/flutter

`AFFILIATE_BASE_URL` принимает только HTTPS URL вашего партнёрского поиска. К ссылке добавляются `perfume=<id>` и `q=<brand name>`. Перед переходом показывается раскрытие партнёрства, после перехода записывается аналитическое событие. Пустая настройка показывает «Магазины скоро появятся».

Сканер — заглушка. Следующее подключение: камера/image picker → распознавание в защищённой Cloud Function → поиск ID в каталоге. Сейчас приложение не запрашивает камеру и не отправляет фотографии.

## Проверки и выпуск

```sh
dart format lib test
flutter analyze
flutter test
flutter build web --release
cd functions
npm ci
npm test
```

Widget-тесты используют детерминированный каталог с теми же seed-данными, чтобы filesystem/cache вне fake clock не влияли на UI-сценарии. Для экспорта PNG экранов задайте `EXPORT_PREVIEWS=1` при запуске тестов. Изображения сохраняются в `preview/`.

CI содержит анализатор, тесты, web build и TypeScript-проверки. Android/iOS release требует ваших signing credentials и проверок на устройствах. Для Android заполните `android/key.properties` по примеру: release-сборка без keystore явно остановится. Debug запускается без release credentials. iOS требует команды подписи в Xcode.

Перед промышленным выпуском остаются: конфигурация вашего Firebase/OAuth/App Check, проверка правил на Emulator Suite, живые Auth/API smoke-тесты, store signing, лицензированный каталог и фото, модерация/репорты отзывов, удаление аккаунта и данных, privacy policy, реальный платёжный webhook. Поиск пока загружает до 500 ароматов и фильтрует их на клиенте; для большого каталога нужен серверный поиск и пагинация. SharedPreferences используется только как удобное локальное демохранилище, не как зашифрованное хранилище личных данных.
