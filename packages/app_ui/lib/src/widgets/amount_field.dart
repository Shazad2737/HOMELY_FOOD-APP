import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountField extends StatefulWidget {
  const AmountField({
    required this.onAmountChanged,
    super.key,
    this.initialAmount = 0,
    this.minAmount = 0,
    this.maxAmount = double.infinity,
    this.stepUpDelay = const Duration(seconds: 1),
    this.currency = 'AED',
    this.locale = 'en_US',
  });

  final void Function(double amount) onAmountChanged;
  final double initialAmount;
  final double minAmount;
  final double maxAmount;
  final Duration stepUpDelay;
  final String currency;
  final String locale;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller;
  Timer? _timer;
  Timer? _stepUpTimer;
  int _stepLevel = 0;
  late final NumberFormat _currencyFormat;

  final List<int> _steps = [1, 10, 100, 1000];

  @override
  void initState() {
    super.initState();
    _currencyFormat = NumberFormat.currency(
      locale: widget.locale,
      symbol: '',
      decimalDigits: 2,
    );
    _controller = TextEditingController(
      text: _formatAmount(widget.initialAmount),
    );
  }

  String _formatAmount(double amount) {
    return _currencyFormat.format(amount);
  }

  double _parseAmount(String text) {
    return _currencyFormat.parse(text).toDouble();
  }

  void _handleAmountChange(String operation) {
    final currentAmount = _parseAmount(_controller.text);
    var newAmount = currentAmount;

    final step = _steps[_stepLevel];

    if (operation == '+') {
      newAmount = currentAmount + step;
    } else if (operation == '-') {
      newAmount = currentAmount - step;
    }

    newAmount = newAmount.clamp(widget.minAmount, widget.maxAmount);

    setState(() {
      _controller.text = _formatAmount(newAmount);
    });
    widget.onAmountChanged(newAmount);
  }

  void _resetState() {
    _stepLevel = 0;
    _timer?.cancel();
    _stepUpTimer?.cancel();
  }

  void _startLongPress(String operation) {
    _resetState();
    _handleAmountChange(operation); // Immediate first change

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _handleAmountChange(operation);
    });

    _stepUpTimer = Timer.periodic(widget.stepUpDelay, (timer) {
      setState(() {
        if (_stepLevel < _steps.length - 1) {
          _stepLevel++;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIconButton('-', Icons.remove),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _controller,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                try {
                  final newAmount = _parseAmount(newValue.text);
                  if (newAmount >= widget.minAmount &&
                      newAmount <= widget.maxAmount) {
                    return newValue;
                  }
                } catch (_) {}
                return oldValue;
              }),
            ],
            onChanged: (value) {
              try {
                final newAmount = _parseAmount(value);
                widget.onAmountChanged(newAmount);
              } catch (_) {}
            },
            decoration: InputDecoration(
              hintText: _formatAmount(0),
              suffixText: NumberFormat.simpleCurrency(
                locale: widget.locale,
                name: widget.currency,
              ).currencySymbol,
              prefixText: '  ',
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton('+', Icons.add),
      ],
    );
  }

  Widget _buildIconButton(String operation, IconData icon) {
    return GestureDetector(
      onLongPressStart: (_) => _startLongPress(operation),
      onLongPressEnd: (_) => _resetState(),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () {
          _resetState();
          _handleAmountChange(operation);
        },
      ),
    );
  }

  @override
  void dispose() {
    _resetState();
    _controller.dispose();
    super.dispose();
  }
}
