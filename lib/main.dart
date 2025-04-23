import 'dart:math';
import 'package:flutter/material.dart';

// Constants for the oscillator visual
const double _kDotRadius = 6.0;
// Define duration components as const integers
const int _kControllerDurationSecondsInt = 10;
const double _kControllerDurationSecondsDouble = 10.0; // Match Int duration
const int _kInitialDotCount = 20; // Default dot count

void main() {
  // Standard Flutter app entry point
  runApp(const CircularOscillatorApp());
}

// Root widget for the application
class CircularOscillatorApp extends StatelessWidget {
  const CircularOscillatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Circular Oscillator',
      // Theme remains dark overall, but painter will override colors when needed
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        sliderTheme: SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.grey[800],
          thumbColor: Colors.white,
          overlayColor: Colors.grey.withOpacity(0.2),
          valueIndicatorColor: Colors.grey[700],
          valueIndicatorTextStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.black),
          fillColor: MaterialStateProperty.all(Colors.white),
          side: const BorderSide(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white70),
        ),
        primarySwatch: Colors.grey,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
        ).copyWith(),
        useMaterial3: true,
      ),
      home: const OscillatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Main screen widget - StatefulWidget because parameters change over time
class OscillatorScreen extends StatefulWidget {
  const OscillatorScreen({super.key});

  @override
  State<OscillatorScreen> createState() => _OscillatorScreenState();
}

// State class for OscillatorScreen, managing animation and parameters
class _OscillatorScreenState extends State<OscillatorScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  // User-adjustable parameters with default values
  double _amplitude = 100.0;    // Default: 100.0
  double _pulseFrequency = 0.1; // Default: 0.1
  double _phaseFactor = 1.0;    // Default: 1.0
  int _dotCount = _kInitialDotCount; // Default: 20
  bool _showPaths = false;      // Controls visibility of path lines
  // ADDED: State for rainbow color mode
  bool _useRainbowColors = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: _kControllerDurationSecondsInt),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to build slider rows consistently
  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    bool isInt = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        SizedBox(
            width: 95,
            child: Text(label, style: theme.textTheme.labelMedium)
        ),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value,
            label: isInt ? value.toInt().toString() : value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
            width: 40,
            child: Text(
                isInt ? value.toInt().toString() : value.toStringAsFixed(1),
                textAlign: TextAlign.right,
                style: theme.textTheme.labelMedium
            )
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circular Oscillator'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return CustomPaint(
                    painter: _CirclePainter(
                      time: _controller.value * _kControllerDurationSecondsDouble,
                      amplitude: _amplitude,
                      pulseFrequency: _pulseFrequency,
                      phaseFactor: _phaseFactor,
                      dotCount: _dotCount,
                      dotRadius: _kDotRadius,
                      showPaths: _showPaths,
                      // Pass rainbow color state to painter
                      useRainbowColors: _useRainbowColors,
                    ),
                    size: Size.infinite,
                    child: Container(),
                  );
                },
              ),
            ),
          ),
          Padding(
            // Adjusted padding to accommodate extra checkbox
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSliderRow(
                  label: 'Max Radius',
                  value: _amplitude,
                  min: 0.0,
                  max: 150.0,
                  onChanged: (v) => setState(() => _amplitude = v),
                ),
                _buildSliderRow(
                  label: 'Pulse Speed',
                  value: _pulseFrequency,
                  min: 0.1,
                  max: 5.0,
                  divisions: 49,
                  onChanged: (v) => setState(() => _pulseFrequency = v),
                ),
                _buildSliderRow(
                  label: 'Phase Factor',
                  value: _phaseFactor,
                  min: 0.0,
                  max: 5.0,
                  divisions: 50,
                  onChanged: (v) => setState(() => _phaseFactor = v),
                ),
                _buildSliderRow(
                  label: 'Dot Count',
                  value: _dotCount.toDouble(),
                  min: 1.0,
                  max: 50.0,
                  divisions: (50 - 1),
                  onChanged: (v) => setState(() => _dotCount = v.toInt()),
                  isInt: true,
                ),
                // Row for the two checkboxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Space them out
                  children: [
                    Expanded( // Allow checkbox tiles to take space
                      child: CheckboxListTile(
                        title: Text("Show Paths", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)), // Slightly smaller text
                        value: _showPaths,
                        onChanged: (bool? value) {
                          setState(() {
                            _showPaths = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10), // Add spacing between checkboxes
                    Expanded( // Allow checkbox tiles to take space
                      child: CheckboxListTile(
                        // ADDED: Rainbow Colors Checkbox
                        title: Text("Rainbow Colors", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)), // Slightly smaller text
                        value: _useRainbowColors,
                        onChanged: (bool? value) {
                          setState(() {
                            _useRainbowColors = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter responsible for drawing the oscillating dots
class _CirclePainter extends CustomPainter {
  final double time;
  final double amplitude;
  final double pulseFrequency;
  final double phaseFactor;
  final int dotCount;
  final double dotRadius;
  final bool showPaths;
  // ADDED: Flag for rainbow colors
  final bool useRainbowColors;

  // Pre-defined paints for B&W mode
  final Paint _dotPaintBW;
  final Paint _linePaintBW;
  // Paint objects to be modified for rainbow mode
  final Paint _dotPaintRainbow;
  final Paint _linePaintRainbow;


  _CirclePainter({
    required this.time,
    required this.amplitude,
    required this.pulseFrequency,
    required this.phaseFactor,
    required this.dotCount,
    required this.dotRadius,
    required this.showPaths,
    // ADDED: Rainbow color parameter
    required this.useRainbowColors,
  }) : _dotPaintBW = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill,
        _linePaintBW = Paint()
          ..color = Colors.grey[700]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
  // Initialize rainbow paints (color will be set per-dot/line)
        _dotPaintRainbow = Paint()
          ..style = PaintingStyle.fill,
        _linePaintRainbow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;


  // Helper to get color based on hue
  Color _getRainbowColor(double hue) {
    // Use HSV color space for easy hue cycling
    // Keep saturation and value high for bright colors
    return HSVColor.fromAHSV(1.0, hue % 360, 1.0, 1.0).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dotCount <= 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double angleStep = (dotCount > 0) ? (pi / dotCount) : 0;
    final double baseOscillation = 2 * pi * pulseFrequency * time;

    // Determine which paints to use based on the mode
    final Paint linePaintToUse = useRainbowColors ? _linePaintRainbow : _linePaintBW;

    // FIRST PASS: Draw all path lines (if enabled)
    if (showPaths) {
      for (int i = 0; i < dotCount; i++) {
        final double angle = angleStep * i;
        final double cosAngle = cos(angle);
        final double sinAngle = sin(angle);

        // Set line color if in rainbow mode
        if (useRainbowColors) {
          // Base hue on angle and time for variation and cycling
          // Multiply time by a factor to speed up color cycling if desired
          final double hue = (angle * 180/pi * 1.5 + time * 36) % 360; // Example hue calculation
          linePaintToUse.color = _getRainbowColor(hue).withOpacity(0.6); // Rainbow lines slightly transparent
        }

        final double dx = amplitude * cosAngle;
        final double dy = amplitude * sinAngle;
        final Offset p1 = Offset(center.dx + dx, center.dy + dy);
        final Offset p2 = Offset(center.dx - dx, center.dy - dy);
        canvas.drawLine(p1, p2, linePaintToUse);
      }
    }

    // Determine which dot paint to potentially modify
    final Paint dotPaintToUse = useRainbowColors ? _dotPaintRainbow : _dotPaintBW;

    // SECOND PASS: Draw all dots
    for (int i = 0; i < dotCount; i++) {
      final double angle = angleStep * i;
      final double cosAngle = cos(angle);
      final double sinAngle = sin(angle);

      final double phaseOffset = angle * phaseFactor;
      final double oscillationArgument = baseOscillation + phaseOffset;
      final double displacement = amplitude * sin(oscillationArgument);

      // Set dot color if in rainbow mode
      if (useRainbowColors) {
        // Base hue on the oscillation argument to link color to movement phase
        // Add a small offset based on index `i` for further differentiation
        final double hue = (oscillationArgument * 180/pi + i * (360.0 / (dotCount+1))) % 360;
        dotPaintToUse.color = _getRainbowColor(hue);
      }

      final double x = center.dx + displacement * cosAngle;
      final double y = center.dy + displacement * sinAngle;
      final Offset dotPosition = Offset(x, y);

      canvas.drawCircle(dotPosition, dotRadius, dotPaintToUse);
    }
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    // Also check if the color mode changed
    return oldDelegate.time != time ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.pulseFrequency != pulseFrequency ||
        oldDelegate.phaseFactor != phaseFactor ||
        oldDelegate.dotCount != dotCount ||
        oldDelegate.dotRadius != dotRadius ||
        oldDelegate.showPaths != showPaths ||
        // ADDED: Check rainbow color mode
        oldDelegate.useRainbowColors != useRainbowColors;
  }
}
