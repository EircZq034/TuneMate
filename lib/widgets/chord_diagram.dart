import 'package:flutter/material.dart';
import '../models/chord.dart';

class ChordDiagram extends StatelessWidget {
  final Chord chord;
  final double size;

  const ChordDiagram({
    super.key,
    required this.chord,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    const leftPad = 20.0;
    final gridWidth = size;
    final gridHeight = gridWidth / 1.1;
    final nameAreaHeight = size * 0.75;
    final totalHeight = nameAreaHeight + gridHeight;

    return CustomPaint(
      size: Size(gridWidth + leftPad, totalHeight),
      painter: _ChordDiagramPainter(
        chord: chord,
        primaryColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
      ),
    );
  }
}

class _ChordDiagramPainter extends CustomPainter {
  final Chord chord;
  final Color primaryColor;
  final Color textColor;

  _ChordDiagramPainter({
    required this.chord,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    const int numStrings = 6;
    const int numFrets = 4;
    const double leftPad = 20.0;

    final double gridWidth = size.width - leftPad;
    final double gridHeight = gridWidth / 1.1;
    final double startX = leftPad;
    final double startY = size.height - gridHeight;

    final double stringSpacing = gridWidth / (numStrings - 1);
    final double fretSpacing = gridHeight / numFrets;

    // 绘制弦（竖线）
    paint.color = Colors.grey.shade600;
    paint.strokeWidth = 1.5;
    for (int i = 0; i < numStrings; i++) {
      final x = startX + i * stringSpacing;
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + gridHeight),
        paint,
      );
    }

    // 绘制品（横线）— 顶部加粗为琴枕
    for (int i = 0; i <= numFrets; i++) {
      final y = startY + i * fretSpacing;
      paint.strokeWidth = i == 0 ? 3.0 : 1.5;
      paint.color = Colors.grey.shade600;
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + gridWidth, y),
        paint,
      );
    }

    // 绘制品位数字（左侧留白区域）
    if (chord.baseFret > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${chord.baseFret}fr',
          style: TextStyle(color: textColor, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPad - textPainter.width - 4, startY - 8));
    }

    // 绘制按弦点
    for (int i = 0; i < chord.frets.length; i++) {
      final fret = chord.frets[i];
      final finger = chord.fingers[i];
      final x = startX + i * stringSpacing;

      if (fret <= 0) continue;

      final fretIndex = fret - chord.baseFret + 1;
      if (fretIndex < 1 || fretIndex > numFrets) continue;
      final y = startY + (fretIndex - 0.5) * fretSpacing;

      fillPaint.color = primaryColor;
      canvas.drawCircle(Offset(x, y), stringSpacing * 0.35, fillPaint);

      if (finger > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$finger',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }

    // 绘制和弦名称（网格上方居中）
    final namePainter = TextPainter(
      text: TextSpan(
        text: chord.name,
        style: TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    final nameX = leftPad + (gridWidth - namePainter.width) / 2;
    final nameY = startY - namePainter.height - 8;
    namePainter.paint(canvas, Offset(nameX, nameY));
  }

  @override
  bool shouldRepaint(covariant _ChordDiagramPainter oldDelegate) =>
      oldDelegate.chord != chord ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.textColor != textColor;
}
