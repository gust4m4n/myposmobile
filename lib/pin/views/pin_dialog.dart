import 'package:flutter/material.dart';

import '../../shared/api_models.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/pin_keypad.dart';
import '../../translations/translation_extension.dart';
import '../services/pin_service.dart';

class PinDialog extends StatefulWidget {
  final String languageCode;
  final bool hasExistingPin;

  const PinDialog({
    super.key,
    required this.languageCode,
    this.hasExistingPin = false,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _formKey = GlobalKey<FormState>();
  String _oldPin = '';
  String _pin = '';
  String _confirmPin = '';
  int _step = 0; // 0: old pin (if exists), 1: new pin, 2: confirm pin
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getCurrentStepTitle() {
    if (widget.hasExistingPin && _step == 0) {
      return 'currentPin'.tr;
    } else if (_step == (_step == 0 ? 1 : 0)) {
      return widget.hasExistingPin ? 'newPin'.tr : 'pin'.tr;
    } else {
      return 'confirmPin'.tr;
    }
  }

  String _getCurrentStepInstruction() {
    if (widget.hasExistingPin && _step == 0) {
      return 'pleaseEnterCurrentPin'.tr;
    } else if (_step == (widget.hasExistingPin ? 1 : 0)) {
      return 'pleaseEnterPin'.tr;
    } else {
      return 'pleaseConfirmPin'.tr;
    }
  }

  String _getCurrentPin() {
    if (widget.hasExistingPin && _step == 0) {
      return _oldPin;
    } else if (_step == (widget.hasExistingPin ? 1 : 0)) {
      return _pin;
    } else {
      return _confirmPin;
    }
  }

  void _onPinChanged(String value) {
    setState(() {
      _errorMessage = null;
      if (widget.hasExistingPin && _step == 0) {
        _oldPin = value;
      } else if (_step == (widget.hasExistingPin ? 1 : 0)) {
        _pin = value;
      } else {
        _confirmPin = value;
      }

      // Auto proceed when PIN is complete
      if (value.length == 6) {
        _handleStepComplete();
      }
    });
  }

  void _handleStepComplete() {
    final maxSteps = widget.hasExistingPin ? 2 : 1;

    if (_step < maxSteps) {
      // Move to next step
      setState(() {
        _step++;
      });
    } else {
      // Final step - validate and submit
      if (_pin != _confirmPin) {
        setState(() {
          _errorMessage = 'pinsDoNotMatch'.tr;
          _confirmPin = '';
        });
      } else {
        _handleSubmit();
      }
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    ApiResponse<Map<String, dynamic>> response;

    if (widget.hasExistingPin) {
      response = await PinService.changePin(
        oldPin: _oldPin,
        newPin: _pin,
        confirmPin: _confirmPin,
      );
    } else {
      response = await PinService.createPin(pin: _pin, confirmPin: _confirmPin);
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.hasExistingPin
                ? 'pinChangedSuccess'.tr
                : 'pinCreatedSuccess'.tr,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage =
            response.message ??
            (widget.hasExistingPin
                ? 'pinChangeFailed'.tr
                : 'pinCreateFailed'.tr);
        // Reset to first step on error
        _step = 0;
        _oldPin = '';
        _pin = '';
        _confirmPin = '';
      });
    }
  }

  void _handleBack() {
    if (_step > 0) {
      setState(() {
        _step--;
        _errorMessage = null;
        // Clear current step data
        if (_step == (widget.hasExistingPin ? 1 : 0)) {
          _confirmPin = '';
        } else if (_step == 0 && !widget.hasExistingPin) {
          _pin = '';
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: widget.hasExistingPin ? 'changePin'.tr : 'createPin'.tr,
      width: 450,
      onClose: () => Navigator.of(context).pop(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Step instruction
            Text(
              _getCurrentStepTitle(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getCurrentStepInstruction(),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // PIN Keypad
            if (!_isSubmitting)
              PinKeypad(
                pin: _getCurrentPin(),
                onPinChanged: _onPinChanged,
                pinLength: 6,
                obscureText: true,
              )
            else
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        ButtonX(
          onPressed: _isSubmitting ? null : _handleBack,
          icon: _step > 0 ? Icons.arrow_back : Icons.close,
          label: _step > 0 ? 'Back' : 'cancel'.tr,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
