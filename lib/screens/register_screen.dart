import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus  = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final appState = Provider.of<AppState>(context, listen: false);
      final success  = appState.register(username, password);
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surface,
            content: Row(
              children: [
                const Icon(Icons.person_add_alt_1_rounded,
                    color: AppTheme.success, size: 16),
                const SizedBox(width: 8),
                Text('Welcome to the studio, $username!',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      } else {
        _showError('Username is already taken');
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surface,
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppTheme.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Background Orbs ──────────────────────────────────────────────
          Positioned(
            top: -100, left: -80,
            child: Container(
              width: 380, height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.primary.withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -60, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.primaryDim.withValues(alpha: 0.09),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Scrollable Content ────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── Top bar ─────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.cardBorder, width: 0.8),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.textPrimary, size: 16),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: AppTheme.primary, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              '100 FREE CREDITS',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Logo ─────────────────────────────────────────────────
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF8C3A),
                          Color(0xFFE8701A),
                          Color(0xFFB84F10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.44),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.music_note_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 18),

                  // ── Page Heading ──────────────────────────────────────────
                  Text(
                    'Create Account',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.6,
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Step Indicators ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepDot(step: 1, label: 'Account',
                          isActive: true, isDone: false),
                      _StepLine(),
                      _StepDot(step: 2, label: 'Studio',
                          isActive: false, isDone: false),
                      _StepLine(),
                      _StepDot(step: 3, label: 'Create',
                          isActive: false, isDone: false),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Form Card ─────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: AppTheme.cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          blurRadius: 36,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.06),
                          blurRadius: 40,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card header row
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.person_add_rounded,
                                    color: AppTheme.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Details',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.4,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Divider
                          Container(
                            height: 0.6,
                            color: AppTheme.cardBorder,
                            margin: const EdgeInsets.symmetric(vertical: 18),
                          ),

                          // Username
                          _PremiumField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            label: 'USERNAME',
                            hint: 'Choose a unique username',
                            prefixIcon: Icons.person_outline_rounded,
                            isFocused: _usernameFocus.hasFocus,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _PremiumField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: 'PASSWORD',
                            hint: 'Minimum 8 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            isFocused: _passwordFocus.hasFocus,
                            obscure: _obscurePassword,
                            onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          _PremiumField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmFocus,
                            label: 'CONFIRM PASSWORD',
                            hint: 'Re-enter your password',
                            prefixIcon: Icons.lock_reset_rounded,
                            isFocused: _confirmFocus.hasFocus,
                            obscure: _obscureConfirm,
                            onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),

                          const SizedBox(height: 20),

                          // Perks info row
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.primary
                                    .withValues(alpha: 0.15),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    color: AppTheme.primary, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Get 100 free credits instantly upon joining',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Submit
                          _GradientButton(
                            label: 'Create My Account',
                            isLoading: _isLoading,
                            onTap: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms note
                  Text(
                    'By creating an account you agree to our\nTerms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      height: 1.65,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Route back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryGlow,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isDone;
  const _StepDot({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isDone
        ? AppTheme.success
        : isActive
            ? AppTheme.primary
            : AppTheme.textMuted;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppTheme.primary.withValues(alpha: 0.15)
                : AppTheme.surfaceHigh,
            border: Border.all(
              color: dotColor.withValues(alpha: 0.6),
              width: isActive ? 1.5 : 0.8,
            ),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, color: dotColor, size: 15)
                : Text(
                    '$step',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: dotColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: dotColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 1,
      margin: const EdgeInsets.only(bottom: 18),
      color: AppTheme.cardBorder,
    );
  }
}

class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isFocused;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  const _PremiumField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.isFocused,
    this.obscure = false,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isFocused ? AppTheme.primary : AppTheme.textSecondary,
            letterSpacing: 1.1,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.20),
                      blurRadius: 14,
                      spreadRadius: -2,
                    )
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
              prefixIcon: Icon(
                prefixIcon,
                size: 20,
                color: isFocused ? AppTheme.primary : AppTheme.textMuted,
              ),
              suffixIcon: onToggleObscure != null
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.cardBorder, width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.cardBorder, width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? null
                : const LinearGradient(
                    colors: [
                      Color(0xFFFF8C3A),
                      Color(0xFFE8701A),
                      Color(0xFFB84F10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: widget.isLoading ? AppTheme.cardBorder : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isLoading
                  ? AppTheme.cardBorder
                  : AppTheme.primary.withValues(alpha: 0.50),
              width: 1.0,
            ),
            boxShadow: widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.44),
                      blurRadius: 24,
                      offset: const Offset(0, 7),
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: AppTheme.primaryGlow.withValues(alpha: 0.18),
                      blurRadius: 40,
                    ),
                  ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
