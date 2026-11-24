import 'package:material_ui/material_ui.dart';

import 'package:go_router/go_router.dart';

import '../router.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
      // Si todo sale bien, el redirect de go_router lleva al feed solo.
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _run(() => AuthService.instance.signIn(_email.text, _password.text));
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (!AuthService.isValidEmail(email)) {
      setState(() => _error = 'Escribe tu correo arriba para recuperar la contraseña.');
      return;
    }
    await _run(() => AuthService.instance.resetPassword(email));
    if (mounted && _error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un correo para restablecer tu contraseña.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: LogoHeader()),
                    const SizedBox(height: 40),
                    AppField(
                      label: 'Correo electrónico',
                      hint: 'tu@correo.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Escribe tu correo';
                        if (!AuthService.isValidEmail(v)) return 'Ingresa un correo válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AppField(
                      label: 'Contraseña',
                      controller: _password,
                      obscure: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading ? null : _forgotPassword,
                        child: const Text('¿Olvidaste tu contraseña?',
                            style: TextStyle(color: kMuted, fontSize: 13)),
                      ),
                    ),
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 12),
                    ],
                    PrimaryButton(label: 'Entrar', loading: _loading, onPressed: _submit),
                    const SizedBox(height: 24),
                    const OrDivider(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SocialButton(
                            label: 'Google',
                            glyph: 'G',
                            onPressed: _loading
                                ? null
                                : () => _run(AuthService.instance.signInWithGoogle),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SocialButton(
                            label: 'Facebook',
                            glyph: 'f',
                            onPressed: _loading
                                ? null
                                : () => _run(AuthService.instance.signInWithFacebook),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?',
                            style: TextStyle(color: kMuted)),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => context.go(AppRoutes.register),
                          child: const Text('Regístrate',
                              style: TextStyle(
                                  color: kAccent, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
