import 'package:material_ui/material_ui.dart';

import '../theme.dart';

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: kMuted)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          autocorrect: false,
          enableSuggestions: !widget.obscure,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip:
                        _hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(
                        _hidden ? Icons.visibility_off : Icons.visibility,
                        color: kMuted),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: kGround,
          disabledBackgroundColor: kAccent.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(strokeWidth: 2.5, color: kGround),
              )
            : Text(label),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.glyph,
    required this.onPressed,
  });

  final String label;
  final String glyph;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: kSurface,
          foregroundColor: Colors.white,
          side: const BorderSide(color: kBorder),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(glyph,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.play_arrow_rounded, size: 52, color: kGround),
        ),
        const SizedBox(height: 14),
        const Text('Logo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1820),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message,
          style: const TextStyle(color: Color(0xFFFF9FB0), fontSize: 14)),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: kBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('o continúa con',
              style: TextStyle(fontSize: 13, color: Color(0xFF9A9AA3))),
        ),
        Expanded(child: Divider(color: kBorder)),
      ],
    );
  }
}
