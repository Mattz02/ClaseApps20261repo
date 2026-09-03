import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF101311),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8E34F),
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans',
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _display = '0';
  String? _history;

  void _press(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _display = '0';
        _history = null;
      } else if (value == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
        }
      } else if (value == '=') {
        if (_expression.isEmpty) return;
        try {
          final result = _evaluate(_expression);
          _history = '$_expression =';
          _expression = _format(result);
          _display = _expression;
        } on DivideByZeroException {
          _display = 'You are stupid';
          _expression = '';
        } catch (_) {
          _display = 'Error';
          _expression = '';
        }
      } else if (value == '%') {
        final number = double.tryParse(_expression);
        if (number != null) {
          _expression = _format(number / 100);
          _display = _expression;
        }
      } else if (value == '+/-') {
        if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        } else if (_expression.isNotEmpty && _expression != '0') {
          _expression = '-$_expression';
        }
        _display = _expression.isEmpty ? '0' : _expression;
      } else {
        if (_display == 'Error') {
          _expression = '';
        }
        if (value == '.' && _expression.contains('.')) return;
        _expression += value;
        _display = _expression;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const buttons = [
      ['AC', 'DEL', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '='],
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CALC',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz),
                        tooltip: 'More options',
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_history != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _history!,
                        style: const TextStyle(
                          color: Color(0xFF758079),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFF2F5EE),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  for (final row in buttons)
                    Expanded(
                      child: Row(
                        children: [
                          for (final button in row)
                            Expanded(
                              child: _CalculatorButton(
                                label: button,
                                onPressed: () => _press(button),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _evaluate(String input) {
    final tokens = RegExp(r'\d+(?:\.\d+)?|[+\-*/×÷−]')
        .allMatches(input)
        .map((match) => match.group(0)!)
        .toList();
    if (tokens.isEmpty || tokens.join() != input || tokens.length.isEven) {
      throw const FormatException();
    }

    var result = double.parse(tokens.first);
    for (var index = 1; index < tokens.length; index += 2) {
      final operator = tokens[index];
      final value = double.parse(tokens[index + 1]);
      switch (operator) {
        case '+':
          result += value;
        case '−':
          result -= value;
        case '×':
          result *= value;
        case '÷':
          if (value == 0) throw const DivideByZeroException();
          result /= value;
      }
    }
    return result;
  }

  String _format(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value
              .toStringAsFixed(8)
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '');
  }
}

class DivideByZeroException implements Exception {
  const DivideByZeroException();
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isOperator = ['÷', '×', '−', '+', '='].contains(label);
    final isUtility = ['AC', 'DEL', '%', '+/-'].contains(label);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: label == '='
              ? const Color(0xFFB8E34F)
              : isOperator
              ? const Color(0xFF293128)
              : const Color(0xFF1B211D),
          foregroundColor: label == '='
              ? const Color(0xFF15200E)
              : isUtility
              ? const Color(0xFFB8E34F)
              : const Color(0xFFE8EEE5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: label == 'DEL' ? 16 : 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
