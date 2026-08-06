import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/simproposta_colors.dart';

class ChartSegment {
  final String label;
  final double value;
  final Color color;

  ChartSegment({required this.label, required this.value, required this.color});
}

class DonutChartWidget extends StatelessWidget {
  final String title;
  final List<ChartSegment> segments;
  final String centerValue;
  final String centerLabel;

  const DonutChartWidget({
    super.key,
    required this.title,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;
    final borderCard = isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;

    final totalValue = segments.fold(0.0, (sum, s) => sum + s.value);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCard),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : SimPropostaColors.navy).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMain),
              ),
              Icon(Icons.pie_chart_outline_rounded, color: isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Gráfico Donut Desenhado em CustomPainter
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(140, 140),
                      painter: _DonutPainter(segments: segments, totalValue: totalValue),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerValue,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textMain),
                        ),
                        Text(
                          centerLabel,
                          style: TextStyle(fontSize: 10, color: textSub, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Legendas Explicativas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments.map((seg) {
                    final percentage = totalValue > 0 ? (seg.value / totalValue) * 100 : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seg.label,
                              style: TextStyle(fontSize: 12, color: textSub, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${seg.value.toInt()} (${percentage.toStringAsFixed(0)}%)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMain),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double totalValue;

  _DonutPainter({required this.segments, required this.totalValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (totalValue <= 0) {
      final paint = Paint()
        color = Colors.grey.withOpacity(0.2)
        style = PaintingStyle.stroke
        strokeWidth = 22.0;
      canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 11, paint);
      return;
    }

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 11;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      if (seg.value <= 0) continue;

      final sweepAngle = (seg.value / totalValue) * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 22.0;

      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.05, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
