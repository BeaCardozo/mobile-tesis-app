import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate app icon PNG', (WidgetTester tester) async {
    // Load Material Icons font so the icon renders properly
    final fontFile = File(
      '/Users/beatrizcardozo/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    final fontBytes = fontFile.readAsBytesSync();
    final fontLoader = FontLoader('MaterialIcons');
    fontLoader.addFont(Future.value(ByteData.view(fontBytes.buffer)));
    await fontLoader.load();

    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox(
              width: 1024,
              height: 1024,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF77A14B), Color(0xFF2F655E)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.savings_rounded,
                    color: Colors.white,
                    size: 550,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final file = File('assets/icon/app_icon.png');
      await file.create(recursive: true);
      await file.writeAsBytes(pngBytes);

      // ignore: avoid_print
      print('Icon generated: ${file.path} (${pngBytes.length} bytes)');
    });
  });
}
