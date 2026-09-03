import 'package:flutter/material.dart';

import 'background_screen.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  void reset() {
    setState(() {
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'View background',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BackgroundScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset',
            onPressed: reset,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
