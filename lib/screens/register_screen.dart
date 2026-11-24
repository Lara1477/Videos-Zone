import 'package:material_ui/material_ui.dart';

import 'package:go_router/go_router.dart';

import '../router.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
      // Al quedar la sesión iniciada, el redirect de go_router lleva al feed.
      if (mounted) context.go(AppRoutes.feed);
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _run(() => AuthService.instance.register(_name.text, _email.text, _password.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGround,
        elevation: 0,
        title: const Text('Crear cuenta'),
        leading: IconButton(
          tooltip: 'Volver al login',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppField(
                      label: 'Nombre',
                      hint: 'Tu nombre',
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Escribe tu nombre'
                          : null,
                    ),
                    const SizedBox(height: 18),
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
                      hint: 'Mínimo 8 caracteres',
                      controller: _password,
                      obscure: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Mínimo 8 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    AppField(
                      label: 'Confirmar contraseña',
                      controller: _confirm,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          v != _password.text ? 'Las contraseñas no coinciden' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Te enviaremos un correo para verificar tu dirección.',
                      style: TextStyle(color: kMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 12),
                    ],
                    PrimaryButton(
                        label: 'Crear cuenta', loading: _loading, onPressed: _submit),
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
