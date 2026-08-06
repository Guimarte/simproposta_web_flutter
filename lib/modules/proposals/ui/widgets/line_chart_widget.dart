import 'package:flutter/material.dart';
import '../../../../core/constants/simproposta_colors.dart';
import '../../domain/entities/proposal_entity.dart';

class LineChartWidget extends StatelessWidget {
  final String title;
  final List<ProposalEntity> proposals;

  const LineChartWidget({
    super.key,
    required this.title,
    required this.proposals,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;
    final borderCard = isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
    final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;

    // Agrupa valores acumulados por dia da semana / data
    final Map<String, double> dailyTotals = {};
    for (var p in proposals) {
      final key = '${p.createdAt.day}/${p.createdAt.month}';
      dailyTotals[key] = (dailyTotals[key] ?? 0.0) + p.totalValue;
    }

    final points = dailyTotals.entries.toList();

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMain),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Evolução do Faturamento Negociado (R\$)',
                    style: TextStyle(fontSize: 12, color: textSub),
                  ),
                ],
              ),
              Icon(Icons.show_chart_rounded, color: primaryColor, size: 22),
            ],
          ),
          const SizedBox(height: 24),

          if (points.isEmpty)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: isDark ? SimPropostaColors.darkSurfaceSubtle : SimPropostaColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('Insira propostas para gerar a curva de evolução.', style: TextStyle(color: textSub, fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 170,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(
                  points: points,
                  primaryColor: primaryColor,
                  textSubColor: textSub,
                  isDark: isDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> points;
  final Color primaryColor;
  final Color textSubColor;
  final bool isDark;

  _LineChartPainter({
    required this.points,
    required this.primaryColor,
    required this.textSubColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double maxVal = points.fold(1.0, (max, entry) => entry.value > max ? entry.value : max);
    final double paddingBottom = 26.0;
    final double paddingTop = 10.0;
    final double chartHeight = size.height - paddingBottom - paddingTop;
    final double stepX = points.length > 1 ? size.width / (points.length - 1) : size.width / 2;

    final List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final double x = points.length == 1 ? size.width / 2 : i * stepX;
      final double normalizedY = points[i].value / maxVal;
      final double y = size.height - paddingBottom - (normalizedY * chartHeight);
      offsets.add(Offset(x, y));
    }

    // Desenha o gradiente sombreado da área
    final Path areaPath = Path();
    areaPath.moveTo(offsets.first.dx, size.height - paddingBottom);
    for (final pt in offsets) {
      areaPath.lineTo(pt.dx, pt.dy);
    }
    areaPath.lineTo(offsets.last.dx, size.height - paddingBottom);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.35),
          primaryColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

    // Desenha a linha curva conectando os pontos
    final Paint linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path linePath = Path();
    linePath.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Desenha os pontos de dados e as legendas de data
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < offsets.length; i++) {
      final pt = offsets[i];

      // Ponto Círculo
      canvas.drawCircle(pt, 5, Paint()..color = primaryColor);
      canvas.drawCircle(pt, 2.5, Paint()..color = Colors.white);

      // Legenda de Data
      textPainter.text = TextSpan(
        text: points[i].key,
        style: TextStyle(color: textSubColor, fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pt.dx - textPainter.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
