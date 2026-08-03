import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Екран статистики PecoNote: витрати по днях, розбивка по категоріях і
/// топ мерчантів за обраний місяць. Поки що статичний макет на mock-даних.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: _StatsHeader(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 116),
                    children: const [
                      _SummaryRow(),
                      SizedBox(height: 14),
                      _SpendingByDayCard(),
                      SizedBox(height: 14),
                      _ByCategoryCard(),
                      SizedBox(height: 14),
                      _TopMerchantsCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(activeTab: AppNavTab.stats),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Stats',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Spacer(),
        Row(
          children: [
            Text(
              'June 2026',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentBlue,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.accentBlue,
            ),
          ],
        ),
      ],
    );
  }
}

/// Спільна скляна картка — використовують усі блоки статистики.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'INCOME',
            value: '₴ 46 000',
            color: AppColors.income,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'EXPENSES',
            value: '₴ 29 431',
            color: AppColors.iconFgOrangeAlt,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'NET',
            value: '+₴ 16 569',
            color: AppColors.expense,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingByDayCard extends StatelessWidget {
  const _SpendingByDayCard();

  // Нормалізовані (0..1) значення витрат по днях — лише для форми графіка.
  static const List<double> _values = [
    0.32,
    0.5,
    0.4,
    0.58,
    0.86,
    0.6,
    0.42,
    0.66,
    0.9,
    0.7,
  ];
  static const int _highlightIndex = 4;

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Spending by day',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 16,
                color: AppColors.income,
              ),
              Text(
                '12% vs May',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.income,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _SpendingChartPainter(
                values: _values,
                highlightIndex: _highlightIndex,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jun 1',
                style: TextStyle(fontSize: 11, color: AppColors.grayTextLight),
              ),
              Text(
                'Jun 10',
                style: TextStyle(fontSize: 11, color: AppColors.grayTextLight),
              ),
              Text(
                'Jun 20',
                style: TextStyle(fontSize: 11, color: AppColors.grayTextLight),
              ),
              Text(
                'Jun 30',
                style: TextStyle(fontSize: 11, color: AppColors.grayTextLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Малює згладжену лінію витрат по днях з градієнтною заливкою під нею та
/// маркером на найвищій за подобою до макета точці.
class _SpendingChartPainter extends CustomPainter {
  const _SpendingChartPainter({
    required this.values,
    required this.highlightIndex,
  });

  final List<double> values;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    const topPad = 8.0;
    const bottomPad = 6.0;
    final chartHeight = size.height - topPad - bottomPad;
    final stepX = size.width / (values.length - 1);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(i * stepX, topPad + (1 - values[i]) * chartHeight),
    ];

    final linePath = _smoothPathThrough(points);

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.22),
          AppColors.accentBlue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    final marker = points[highlightIndex.clamp(0, points.length - 1)];
    canvas.drawCircle(
      marker,
      6,
      Paint()..color = AppColors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(marker, 6, Paint()..color = AppColors.accentBlue);
    canvas.drawCircle(marker, 3, Paint()..color = AppColors.white);
  }

  /// Catmull-Rom -> кубічні Безьє сегменти для плавної кривої через усі точки.
  Path _smoothPathThrough(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i == 0 ? i : i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = points[i + 2 < points.length ? i + 2 : i + 1];

      final control1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final control2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _SpendingChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.highlightIndex != highlightIndex;
}

class _CategoryData {
  const _CategoryData({
    required this.emoji,
    required this.name,
    required this.amount,
    required this.percent,
    required this.iconBg,
    required this.iconFg,
    required this.barColor,
  });

  final String emoji;
  final String name;
  final String amount;
  final int percent;
  final Color iconBg;
  final Color iconFg;
  final Color barColor;
}

class _ByCategoryCard extends StatelessWidget {
  const _ByCategoryCard();

  // Кольори entertainment/transport поки немає в AppColors — це разові
  // акценти лише для макета статистики, як і design-кольори на HomeScreen.
  static const _entertainmentBg = Color(0xFFE7E0F7);
  static const _entertainmentFg = Color(0xFF7B5FBE);
  static const _transportBg = Color(0xFFFBE1EC);
  static const _transportFg = Color(0xFFB1467E);

  static const List<_CategoryData> _categories = [
    _CategoryData(
      emoji: '📦',
      name: 'Food',
      amount: '₴ 9 120',
      percent: 31,
      iconBg: AppColors.iconBgBrown,
      iconFg: AppColors.iconFgBrown,
      barColor: AppColors.accentBlue,
    ),
    _CategoryData(
      emoji: '🏠',
      name: 'Home & utilities',
      amount: '₴ 6 480',
      percent: 22,
      iconBg: AppColors.iconBgGreen,
      iconFg: AppColors.iconFgGreen,
      barColor: AppColors.income,
    ),
    _CategoryData(
      emoji: '🎮',
      name: 'Entertainment',
      amount: '₴ 4 415',
      percent: 15,
      iconBg: _entertainmentBg,
      iconFg: _entertainmentFg,
      barColor: AppColors.iconFgOrangeSoft,
    ),
    _CategoryData(
      emoji: '🚗',
      name: 'Transport',
      amount: '₴ 3 240',
      percent: 11,
      iconBg: _transportBg,
      iconFg: _transportFg,
      barColor: _transportFg,
    ),
    _CategoryData(
      emoji: '🏷️',
      name: 'Uncategorized',
      amount: '₴ 1 970',
      percent: 7,
      iconBg: AppColors.searchFieldBg,
      iconFg: AppColors.grayTextLight,
      barColor: AppColors.dotInactive,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _categories.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _CategoryRow(data: _categories[i]),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: data.iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(data.emoji, style: const TextStyle(fontSize: 17)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    data.amount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 5,
                          width: constraints.maxWidth,
                          color: AppColors.dotInactive.withValues(alpha: 0.4),
                        ),
                        Container(
                          height: 5,
                          width: constraints.maxWidth * (data.percent / 100),
                          color: data.barColor,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 30,
          child: Text(
            '${data.percent}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11.5, color: AppColors.grayText),
          ),
        ),
      ],
    );
  }
}

class _MerchantData {
  const _MerchantData({
    required this.emoji,
    required this.name,
    required this.count,
    required this.amount,
  });

  final String emoji;
  final String name;
  final int count;
  final String amount;
}

class _TopMerchantsCard extends StatelessWidget {
  const _TopMerchantsCard();

  static const List<_MerchantData> _merchants = [
    _MerchantData(
      emoji: '📦',
      name: 'SILPO',
      count: 12,
      amount: '₴ 5 830',
    ),
    _MerchantData(
      emoji: '🚕',
      name: 'Uklon',
      count: 9,
      amount: '₴ 1 640',
    ),
    _MerchantData(
      emoji: '☕️',
      name: 'Blur Coffee',
      count: 8,
      amount: '₴ 1 480',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top merchants',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _merchants.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _MerchantRow(data: _merchants[i]),
          ],
        ],
      ),
    );
  }
}

class _MerchantRow extends StatelessWidget {
  const _MerchantRow({required this.data});

  final _MerchantData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.iconBgBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(data.emoji, style: const TextStyle(fontSize: 17)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            '${data.count}×',
            style: const TextStyle(fontSize: 12.5, color: AppColors.grayText),
          ),
          const SizedBox(width: 14),
          Text(
            data.amount,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
