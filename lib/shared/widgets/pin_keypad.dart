import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final String pin;
  final ValueChanged<String> onPinChanged;
  final int pinLength;
  final bool obscureText;

  const PinKeypad({
    super.key,
    required this.pin,
    required this.onPinChanged,
    this.pinLength = 6,
    this.obscureText = true,
  });

  void _onNumberPressed(String number) {
    if (pin.length < pinLength) {
      onPinChanged(pin + number);
    }
  }

  void _onDeletePressed() {
    if (pin.isNotEmpty) {
      onPinChanged(pin.substring(0, pin.length - 1));
    }
  }

  void _onClearPressed() {
    onPinChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pinLength,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: index < pin.length
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: index < pin.length
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surface,
              ),
              child: Center(
                child: obscureText && index < pin.length
                    ? Icon(
                        Icons.circle,
                        size: 12,
                        color: theme.colorScheme.primary,
                      )
                    : Text(
                        index < pin.length ? pin[index] : '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Keypad
        SizedBox(
          width: 300,
          child: Column(
            children: [
              // Row 1: 1, 2, 3
              _buildKeypadRow(['1', '2', '3'], theme),
              const SizedBox(height: 12),

              // Row 2: 4, 5, 6
              _buildKeypadRow(['4', '5', '6'], theme),
              const SizedBox(height: 12),

              // Row 3: 7, 8, 9
              _buildKeypadRow(['7', '8', '9'], theme),
              const SizedBox(height: 12),

              // Row 4: Clear, 0, Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.clear,
                    onPressed: _onClearPressed,
                    theme: theme,
                    label: 'C',
                  ),
                  _buildNumberButton('0', theme),
                  _buildActionButton(
                    icon: Icons.backspace_outlined,
                    onPressed: _onDeletePressed,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers
          .map((number) => _buildNumberButton(number, theme))
          .toList(),
    );
  }

  Widget _buildNumberButton(String number, ThemeData theme) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withOpacity(0.1),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    String? label,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                )
              : Icon(icon, size: 24, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
