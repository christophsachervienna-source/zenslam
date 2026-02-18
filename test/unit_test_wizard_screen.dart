import 'package:flutter/material.dart';

class WizardScreen extends StatelessWidget {
  const WizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark VS Code-like background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞══',
                  style: TextStyle(
                    fontFamily: 'Courier', // Monospace font
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The following assertion was thrown running a test:',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.withValues(alpha:0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Expected: <HomeFlow>',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Actual: <WizardScreen>',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '   Which: located at line 38',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'When the exception was thrown, this was the stack:',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '''#0      WidgetTester.expect (package:flutter_test/src/widget_tester.dart:456:10)
#1      main.<anonymous closure> (test/feature/home_flow/home_test.dart:23:5)
#2      Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)
#3      <asynchronous suspension>
#4      StackZoneSpecification._run (package:stack_trace/src/stack_zone_specification.dart:209:15)
#5      TestService.run (package:zenslam/test_service.dart:42:1)
#6      BindingBase.reassembleApplication (package:flutter/src/foundation/binding.dart:829:16)
''',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.grey[400],
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha:0.1),
                    border: Border(
                      left: BorderSide(color: Colors.red, width: 4),
                    ),
                  ),
                  child: const Text(
                    'FAIL',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
