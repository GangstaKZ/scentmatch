import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/action_button.dart';

class QuizQuestion {
  const QuizQuestion(this.key, this.ru, this.en, this.options, this.icon);
  final String key, ru, en;
  final List<String> options;
  final IconData icon;
}

const quizQuestions = [
  QuizQuestion(
      'gender',
      'Для кого выбираем аромат?',
      'Who are we choosing for?',
      ['female', 'male', 'unisex', 'any'],
      Icons.person_outline),
  QuizQuestion('age', 'Ваша возрастная группа', 'Your age group',
      ['18-24', '25-34', '35-44', '45+', 'any'], Icons.auto_awesome_outlined),
  QuizQuestion(
      'family',
      'Какие ароматы вам близки?',
      'Which scents do you enjoy?',
      ['woody', 'floral', 'fresh', 'amber', 'gourmand'],
      Icons.spa_outlined),
  QuizQuestion('budget', 'Комфортный бюджет', 'Your preferred budget',
      ['budget', 'mid', 'luxury'], Icons.account_balance_wallet_outlined),
  QuizQuestion('season', 'Для какого сезона?', 'Which season?',
      ['spring', 'summer', 'autumn', 'winter'], Icons.wb_sunny_outlined),
  QuizQuestion(
      'longevity',
      'Как долго звучит ваш аромат?',
      'How long should it last?',
      ['light', 'medium', 'long'],
      Icons.schedule_rounded),
  QuizQuestion(
      'mood',
      'Какое настроение создаём?',
      'What is your mood?',
      ['day', 'evening', 'calm', 'bold', 'romantic'],
      Icons.nights_stay_outlined),
];

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int step = 0;
  late Map<String, String> answers;
  @override
  void initState() {
    super.initState();
    answers = {...?ref.read(profileProvider).valueOrNull?.quizAnswers};
  }

  @override
  Widget build(BuildContext context) {
    final question = quizQuestions[step];
    return Scaffold(
        appBar: AppBar(
            title: Text(
                context.tr('Ваш парфюмерный портрет', 'Your scent portrait')),
            leading: step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => step--))
                : ref.read(profileProvider).valueOrNull?.quizComplete == true
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.go('/profile'))
                    : null),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                    context.tr('ШАГ ${step + 1} ИЗ 7',
                                        'STEP ${step + 1} OF 7'),
                                    style: const TextStyle(
                                        letterSpacing: 2, fontSize: 11)),
                                const Spacer(),
                                Text('${((step + 1) / 7 * 100).round()}%')
                              ]),
                              const SizedBox(height: 12),
                              TweenAnimationBuilder<double>(
                                  tween: Tween(end: (step + 1) / 7),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (_, value, __) =>
                                      LinearProgressIndicator(
                                          value: value,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          minHeight: 5)),
                              const SizedBox(height: 48),
                              Icon(question.icon,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 24),
                              AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Align(
                                      key: ValueKey(step),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          context.tr(question.ru, question.en),
                                          style: const TextStyle(
                                              fontFamily: 'CormorantGaramond',
                                              fontSize: 34)))),
                              const SizedBox(height: 12),
                              Text(context.tr(
                                  'Выберите один вариант. Вы сможете изменить ответы позже.',
                                  'Choose one option. You can change your answers later.')),
                              const SizedBox(height: 28),
                              ...question.options.map((option) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Material(
                                      color: answers[question.key] == option
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .surface,
                                      borderRadius: BorderRadius.circular(18),
                                      child: RadioListTile<String>(
                                          value: option,
                                          groupValue: answers[question.key],
                                          title: Text(context.label(option)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          onChanged: (value) => setState(() =>
                                              answers[question.key] =
                                                  value!))))),
                              const SizedBox(height: 24),
                              SizedBox(
                                  width: double.infinity,
                                  child: ActionButton(
                                      label: step == 6
                                          ? context.tr(
                                              'Показать мои рекомендации',
                                              'Show my recommendations')
                                          : context.tr(
                                              'Продолжить', 'Continue'),
                                      action: answers[question.key] == null
                                          ? null
                                          : () async {
                                              if (step < 6) {
                                                setState(() => step++);
                                                return;
                                              }
                                              await ref
                                                  .read(actionsProvider)
                                                  .saveQuiz(answers);
                                              if (context.mounted) {
                                                context.go('/home');
                                              }
                                            })),
                            ]))))));
  }
}
