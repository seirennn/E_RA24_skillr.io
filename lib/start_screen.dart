import 'package:adaptive_theme/adaptive_theme.dart';
import 'question_screen.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {

  @override
  Widget build(BuildContext context) {
    final clrSchm = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: clrSchm.surface,
      body: Center(
        child: Column(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(175)),
            child: Builder(
              builder: (context) {
                return Stack(alignment: Alignment.center, children: []);
              }
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to', style: TextStyle(color: clrSchm.primary, fontSize: 24,fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text('skillr.io', style: TextStyle(color: clrSchm.primary, fontSize: 46, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('First, Let us get started by knowing you better.',style: TextStyle(color: clrSchm.primary, fontSize: 24,fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ]),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(vertical: 46, horizontal: 16),
        width: double.infinity,
        child: preoceedButton(context),
      ),
    );
  }

  Widget preoceedButton(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, 
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const QuestionScreen(),
            transitionDuration: const Duration (milliseconds: 1000),
            
            // reverseTransitionDuration: const Duration(milliseconds: 2000) ,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var screenSize = MediaQuery.of(context).size;
              return ClipPath(
                clipper: CircleRevealClipper(
                  radius: animation.drive(Tween(begin: 0.0, end: screenSize.height * 1.5)).value,
                  center: Offset(screenSize.width/2, screenSize.height-100),
                ),
                
                child: child,
              );
            }
          ),
        ),
        
        style: bottomLargeButton(context),
        child: const Text('Proceed', style: TextStyle(fontSize: 20)),
      ),
      
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  // ignore: prefer_typing_uninitialized_variables
  final center, radius;

  CircleRevealClipper({this.center, this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
        radius: radius, center: center
      )
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clrSchm = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Appearance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<AdaptiveThemeMode?>(
              valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
              builder: (_, mode, child) {
                return Text(
                  'App Theme',
                  style: TextStyle(
                    color: mode?.isLight ?? true ? clrSchm.onBackground : clrSchm.background,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<AdaptiveThemeMode?>(
              valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
              builder: (_, mode, child) {
                return GestureDetector(
                  onTap: () {
                    AdaptiveTheme.of(context).setLight();
                  },
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      color: clrSchm.primaryContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                        color: mode?.isLight ?? false ? clrSchm.primary : clrSchm.primaryContainer,
                        width: 7,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<AdaptiveThemeMode?>(
              valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
              builder: (_, mode, child) {
                return GestureDetector(
                  onTap: () {
                    AdaptiveTheme.of(context).setDark();
                  },
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      color: clrSchm.primaryContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                        color: mode?.isDark ?? false ? clrSchm.primary : clrSchm.primaryContainer,
                        width: 7,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}