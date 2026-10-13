import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';

String friendlyError(BuildContext context, Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' =>
        context.tr('Неверный email или пароль.', 'Invalid email or password.'),
      'email-already-in-use' => context.tr('Этот email уже зарегистрирован.',
          'This email is already registered.'),
      'weak-password' => context.tr(
          'Выберите более надёжный пароль.', 'Choose a stronger password.'),
      'too-many-requests' => context.tr(
          'Слишком много попыток. Попробуйте позже.',
          'Too many attempts. Try later.'),
      _ => context.tr(
          'Не удалось войти. Проверьте подключение и настройки входа.',
          'Sign-in failed. Check your connection and sign-in configuration.'),
    };
  }
  return context.tr('Не удалось сохранить изменения. Попробуйте ещё раз.',
      'Unable to save changes. Please try again.');
}

class ActionButton extends StatefulWidget {
  const ActionButton(
      {super.key,
      required this.label,
      required this.action,
      this.icon,
      this.tonal = false});
  final String label;
  final Future<void> Function()? action;
  final IconData? icon;
  final bool tonal;
  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool busy = false;
  Future<void> run() async {
    if (busy || widget.action == null) return;
    setState(() => busy = true);
    try {
      await widget.action!();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(friendlyError(context, error))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2))
        : Icon(widget.icon ?? Icons.arrow_forward_rounded);
    return widget.tonal
        ? FilledButton.tonalIcon(
            onPressed: busy || widget.action == null ? null : run,
            icon: icon,
            label: Text(widget.label))
        : FilledButton.icon(
            onPressed: busy || widget.action == null ? null : run,
            icon: icon,
            label: Text(widget.label));
  }
}
