# Firebase — подробная инструкция / Firebase guide

Всё, что связано с подключением Firebase, seed-данными, эмуляторами и облачными функциями ScentMatch. Краткий README — в [корне репозитория](../README.md).

---

## Подключение реального проекта

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

---

## Seed каталога

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

---

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

В примере выше `10.0.2.2` — адрес компьютера из Android Emulator (`EMULATOR_HOST`). Для web/iOS simulator замените его на `localhost`; для физического телефона — на локальный IP машины. Android debug manifest при необходимости должен разрешать HTTP-подключение к локальным эмуляторам. Google OAuth проверяйте с настоящим настроенным Firebase-проектом; эмулятор предназначен прежде всего для email/Auth, Firestore и Functions. Это инструкция настройки, а не подтверждение уже выполненного emulator smoke-теста. [Документация подключения](https://firebase.google.com/docs/emulator-suite/connect_firestore).

---

## Рекомендации и OpenAI (Cloud Functions)

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
