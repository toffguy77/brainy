import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/parent_provider.dart';
import '../providers/pin_lockout.dart';

class ParentPinScreen extends ConsumerStatefulWidget {
  const ParentPinScreen({super.key});

  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  String _enteredPin = '';
  String? _firstPin; // for setup: store first entry to confirm
  late final PinLockout _lockout =
      PinLockout(Hive.box(AppConstants.userBox));
  Timer? _lockoutTicker;
  bool _showError = false;
  bool _settingNewPin = false; // change-mode: old PIN verified, entering new

  bool get _isChangeMode =>
      GoRouterState.of(context).uri.queryParameters['mode'] == 'change';

  bool get _inSetupPhase {
    if (_settingNewPin) return true;
    return !ref.read(parentProvider).hasPin;
  }

  bool get _isConfirming => _inSetupPhase && _firstPin != null;
  bool get _isLockedOut => _lockout.isLocked;

  @override
  void initState() {
    super.initState();
    // A lockout started earlier — even before an app restart — still holds.
    if (_lockout.isLocked) _startLockoutTicker();
  }

  @override
  void dispose() {
    _lockoutTicker?.cancel();
    super.dispose();
  }

  void _onDigit(int digit) {
    if (_isLockedOut) return;
    if (_enteredPin.length >= AppConstants.parentPinLength) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += digit.toString();
      _showError = false;
    });

    if (_enteredPin.length == AppConstants.parentPinLength) {
      Future.delayed(const Duration(milliseconds: 150), _onPinComplete);
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _showError = false;
    });
  }

  void _onPinComplete() {
    if (_inSetupPhase) {
      if (_firstPin == null) {
        // First entry — remember and ask to confirm
        setState(() {
          _firstPin = _enteredPin;
          _enteredPin = '';
        });
      } else {
        // Confirming
        if (_enteredPin == _firstPin) {
          ref.read(parentProvider.notifier).setPin(_enteredPin);
          parentPinVerifiedSession = true;
          if (_isChangeMode) {
            context.go('/parent/settings');
          } else {
            context.go('/parent/dashboard');
          }
        } else {
          // A mismatched confirmation is a typo, not a guess: no lockout.
          _showWrongPin();
          setState(() => _firstPin = null);
        }
      }
    } else {
      // Verification
      if (ref.read(parentProvider.notifier).verifyPin(_enteredPin)) {
        _lockout.recordSuccess();
        if (_isChangeMode) {
          // Old PIN verified — switch to setting new PIN
          setState(() {
            _settingNewPin = true;
            _enteredPin = '';
            _firstPin = null;
            _showError = false;
          });
        } else {
          parentPinVerifiedSession = true;
          context.go('/parent/dashboard');
        }
      } else {
        _handleWrongPin();
      }
    }
  }

  void _showWrongPin() {
    HapticFeedback.heavyImpact();
    setState(() {
      _enteredPin = '';
      _showError = true;
    });
  }

  Future<void> _handleWrongPin() async {
    _showWrongPin();
    await _lockout.recordFailure();
    if (_lockout.isLocked) _startLockoutTicker();
  }

  /// Repaint once a second so the countdown shown to the parent stays live.
  void _startLockoutTicker() {
    _lockoutTicker?.cancel();
    _lockoutTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() {});
      if (!_lockout.isLocked) timer.cancel();
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String title;
    String subtitle;
    if (_isChangeMode && !_settingNewPin && ref.read(parentProvider).hasPin) {
      title = l10n.parentEnterPin;
      subtitle = l10n.parentEnterPinSubtitle;
    } else if (_inSetupPhase) {
      title = l10n.parentSetPin;
      subtitle = _isConfirming
          ? l10n.parentEnterPinSubtitle
          : l10n.parentSetPinSubtitle;
    } else {
      title = l10n.parentEnterPin;
      subtitle = l10n.parentEnterPinSubtitle;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (_isChangeMode) {
              context.go('/parent/settings');
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildDots(),
            const SizedBox(height: 16),
            if (_showError)
              Text(
                l10n.parentWrongPin,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            if (_isLockedOut)
              Text(
                l10n.parentLockedOut(_lockout.remainingSeconds),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            const Spacer(flex: 1),
            _buildNumpad(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppConstants.parentPinLength, (index) {
        final filled = index < _enteredPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (_showError ? AppColors.error : AppColors.primary)
                : Colors.transparent,
            border: Border.all(
              color: _showError
                  ? AppColors.error
                  : filled
                      ? AppColors.primary
                      : AppColors.textSecondary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((digit) => _NumpadButton(
                          label: '$digit',
                          onTap: () => _onDigit(digit),
                          enabled: !_isLockedOut,
                        ))
                    .toList(),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _NumpadButton(
                label: '0',
                onTap: () => _onDigit(0),
                enabled: !_isLockedOut,
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(36),
                    onTap: _onBackspace,
                    child: const Center(
                      child: Icon(
                        Icons.backspace_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _NumpadButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36),
        child: InkWell(
          borderRadius: BorderRadius.circular(36),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
