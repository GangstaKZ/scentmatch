import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/action_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool register = false, obscure = true;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                          key: form,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.blur_on,
                                    size: 60,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 24),
                                Text(
                                    context.tr(
                                        register
                                            ? 'Начнём вашу историю'
                                            : 'С возвращением',
                                        register
                                            ? 'Start your story'
                                            : 'Welcome back'),
                                    style: const TextStyle(
                                        fontFamily: 'CormorantGaramond',
                                        fontSize: 36)),
                                const SizedBox(height: 12),
                                Text(context.tr(
                                    'Ваши открытия будут всегда с вами.',
                                    'Keep your discoveries with you.')),
                                const SizedBox(height: 32),
                                if (register) ...[
                                  TextFormField(
                                      controller: name,
                                      maxLength: 80,
                                      decoration: InputDecoration(
                                          labelText: context.tr('Имя', 'Name')),
                                      validator: (v) => v!.trim().isEmpty
                                          ? context.tr(
                                              'Введите имя', 'Enter your name')
                                          : null),
                                  const SizedBox(height: 12)
                                ],
                                TextFormField(
                                    controller: email,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: const InputDecoration(
                                        labelText: 'Email'),
                                    validator: (v) =>
                                        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                                .hasMatch(v!.trim())
                                            ? context.tr(
                                                'Введите корректный email',
                                                'Enter a valid email')
                                            : null),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: password,
                                    obscureText: obscure,
                                    autofillHints: [
                                      register
                                          ? AutofillHints.newPassword
                                          : AutofillHints.password
                                    ],
                                    decoration: InputDecoration(
                                        labelText:
                                            context.tr('Пароль', 'Password'),
                                        suffixIcon: IconButton(
                                            tooltip: context.tr(
                                                'Показать или скрыть пароль',
                                                'Show or hide password'),
                                            onPressed: () => setState(
                                                () => obscure = !obscure),
                                            icon: Icon(obscure
                                                ? Icons.visibility_outlined
                                                : Icons
                                                    .visibility_off_outlined))),
                                    validator: (v) => v == null || v.length < 8
                                        ? context.tr('Минимум 8 символов',
                                            'At least 8 characters')
                                        : null),
                                const SizedBox(height: 24),
                                ActionButton(
                                    label: context.tr(
                                        register ? 'Создать аккаунт' : 'Войти',
                                        register
                                            ? 'Create account'
                                            : 'Sign in'),
                                    action: () async {
                                      if (!form.currentState!.validate()) {
                                        return;
                                      }
                                      final repo =
                                          ref.read(authRepositoryProvider);
                                      if (register) {
                                        await repo.register(name.text,
                                            email.text, password.text);
                                      } else {
                                        await repo.signIn(
                                            email.text, password.text);
                                      }
                                    }),
                                const SizedBox(height: 12),
                                ActionButton(
                                    label: context.tr('Продолжить с Google',
                                        'Continue with Google'),
                                    icon: Icons.account_circle_outlined,
                                    tonal: true,
                                    action: () => ref
                                        .read(authRepositoryProvider)
                                        .google()),
                                const SizedBox(height: 16),
                                TextButton(
                                    onPressed: () =>
                                        setState(() => register = !register),
                                    child: Text(context.tr(
                                        register
                                            ? 'Уже есть аккаунт? Войти'
                                            : 'Нет аккаунта? Зарегистрироваться',
                                        register
                                            ? 'Have an account? Sign in'
                                            : 'New here? Create account'))),
                                if (!register)
                                  ActionButton(
                                      tonal: true,
                                      label: context.tr(
                                          'Сбросить пароль', 'Reset password'),
                                      icon: Icons.lock_reset,
                                      action: () async {
                                        if (!RegExp(
                                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                            .hasMatch(email.text.trim())) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(context.tr(
                                                      'Сначала введите email',
                                                      'Enter your email first'))));
                                          return;
                                        }
                                        await ref
                                            .read(authRepositoryProvider)
                                            .resetPassword(email.text);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(context.tr(
                                                      'Если аккаунт существует, письмо для сброса отправлено.',
                                                      'If the account exists, a reset email has been sent.'))));
                                        }
                                      }),
                              ])))))));
}
