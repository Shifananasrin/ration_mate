// <<<<<<< HEAD
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const RationMateApp());
// }

// class RationMateApp extends StatelessWidget {
//   const RationMateApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'RationMate',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: const WelcomePage(),
//     );
//   }
// }

// class WelcomePage extends StatefulWidget {
//   const WelcomePage({super.key});

//   @override
//   State<WelcomePage> createState() => _WelcomePageState();
// }

// class _WelcomePageState extends State<WelcomePage>
//     with SingleTickerProviderStateMixin {
//   String _selectedLanguage = 'English';
//   late AnimationController _controller;

//   final Map<String, Map<String, String>> translations = {
//     'English': {
//       'title': 'RationMate',
//       'quote': '“Your ration, your right — stay informed.”',
//       'chooseLanguage': 'Choose Language',
//       'admin': 'RationGuard',
//       'user': 'RationKeeper',
//     },
//     'Malayalam': {
//       'title': 'റേഷൻമേറ്റ്',
//       'quote': '“നിങ്ങളുടെ റേഷൻ, നിങ്ങളുടെ അവകാശം — അറിയിപ്പുകൾ കൈയിൽ.”',
//       'chooseLanguage': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
//       'admin': 'അഡ്മിൻ',
//       'user': 'ഉപയോക്താവ്',
//     },
//   };

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _goToRole(String role) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//           content: Text(
//               role == 'Admin' ? 'Admin login page coming soon' : 'User phone screen coming soon')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = translations[_selectedLanguage]!;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background wave
//           Positioned.fill(child: CustomPaint(painter: WavePainter())),
//           SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Spacer(),
//                 // Logo
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.15),
//                   ),
//                   child: const Icon(
//                     Icons.shopping_bag_rounded,
//                     size: 80,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 // Title
//                 Text(
//                   t['title']!,
//                   style: const TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//                 const SizedBox(height: 8),
//                 // Quote
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 30),
//                   child: Text(
//                     t['quote']!,
//                     style: const TextStyle(
//                         fontSize: 16,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.white70),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 // Language selection
//                 Text(
//                   t['chooseLanguage']!,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 12),
//                 ToggleButtons(
//                   borderRadius: BorderRadius.circular(25),
//                   color: Colors.white,
//                   selectedColor: Colors.green[800],
//                   fillColor: Colors.white.withOpacity(0.2),
//                   isSelected: [
//                     _selectedLanguage == 'English',
//                     _selectedLanguage == 'Malayalam',
//                   ],
//                   onPressed: (index) {
//                     setState(() {
//                       _selectedLanguage =
//                           index == 0 ? 'English' : 'Malayalam';
//                     });
//                   },
//                   children: const [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Text('English'),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Text('മലയാളം'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//                 // Role cards
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 30),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildRoleCard(
//                           Icons.admin_panel_settings, t['admin']!, 'Admin'),
//                       _buildRoleCard(Icons.person, t['user']!, 'User'),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRoleCard(IconData icon, String label, String role) {
//     return ScaleTransition(
//       scale: Tween<double>(begin: 0.9, end: 1.05).animate(
//           CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
//       child: GestureDetector(
//         onTap: () => _goToRole(role),
//         child: Container(
//           width: 130,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Icon(icon, size: 40, color: Colors.green[800]),
//               const SizedBox(height: 10),
//               Text(
//                 label,
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.green[800],
//                     fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class WavePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color(0xFF4CAF50);
//     final path = Path()
//       ..lineTo(0, size.height * 0.75)
//       ..quadraticBezierTo(
//           size.width * 0.5, size.height * 0.9, size.width, size.height * 0.75)
//       ..lineTo(size.width, 0)
//       ..close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// =======
// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:ration_mate/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const RationMateApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// >>>>>>> fa294d2 (initial commit)
// }
