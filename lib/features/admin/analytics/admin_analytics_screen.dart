import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/utils/responsive.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  int _selectedTimeframe = 0; // 0: 7 Days, 1: 30 Days, 2: 90 Days

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? AarogyaSpacing.md : 24,
          vertical: Responsive.isMobile(context) ? AarogyaSpacing.md : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Institutional Healthcare Analytics',
                      style: AarogyaTypography.headingLarge(primaryText),
                    ),
                    Text(
                      'Predictive patient volume trends, revenue distributions, and clinical utilization',
                      style: AarogyaTypography.bodyMedium(secondaryText),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTimeframeChip('7 Days', 0, isDark),
                    const SizedBox(width: 6),
                    _buildTimeframeChip('30 Days', 1, isDark),
                    const SizedBox(width: 6),
                    _buildTimeframeChip('90 Days', 2, isDark),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AarogyaSpacing.xl),

            // Line Chart: Patient Consultation Volume
            GlassCard(
              glowColor: AarogyaColors.primaryCyan,
              padding: AarogyaSpacing.paddingXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Patient Consultation Volume',
                              style: AarogyaTypography.headingMedium(
                                primaryText,
                              ),
                            ),
                            Text(
                              'Daily OPD admissions across all clinical departments',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AarogyaBadge(
                        label: '+18.4% WoW',
                        variant: AarogyaBadgeVariant.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AarogyaSpacing.xxl),
                  SizedBox(
                    height: 240,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark
                                ? AarogyaColors.darkGlassBorderSubtle
                                : AarogyaColors.lightGlassBorderSubtle,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun',
                                ];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      days[idx],
                                      style: AarogyaTypography.caption(
                                        secondaryText,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              interval: 20,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: AarogyaTypography.caption(
                                    secondaryText,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 32),
                              FlSpot(1, 48),
                              FlSpot(2, 42),
                              FlSpot(3, 76),
                              FlSpot(4, 68),
                              FlSpot(5, 84),
                              FlSpot(6, 60),
                            ],
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [
                                AarogyaColors.primaryCyan,
                                AarogyaColors.primaryBlue,
                              ],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AarogyaColors.primaryCyan.withValues(
                                    alpha: 0.3,
                                  ),
                                  AarogyaColors.primaryCyan.withValues(
                                    alpha: 0.0,
                                  ),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AarogyaSpacing.xl),

            // Bar Chart: Departmental Revenue Distribution
            GlassCard(
              glowColor: AarogyaColors.accentPurple,
              padding: AarogyaSpacing.paddingXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Departmental Revenue Distribution',
                              style: AarogyaTypography.headingMedium(
                                primaryText,
                              ),
                            ),
                            Text(
                              'Comparative OPD & procedural gross billing (₹K)',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AarogyaBadge(
                        label: '₹2.84M Total',
                        variant: AarogyaBadgeVariant.cyan,
                      ),
                    ],
                  ),
                  const SizedBox(height: AarogyaSpacing.xxl),
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark
                                ? AarogyaColors.darkGlassBorderSubtle
                                : AarogyaColors.lightGlassBorderSubtle,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                const depts = [
                                  'Cardio',
                                  'Neuro',
                                  'Pedia',
                                  'Ortho',
                                  'Derma',
                                ];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < depts.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      depts[idx],
                                      style: AarogyaTypography.caption(
                                        secondaryText,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}k',
                                  style: AarogyaTypography.caption(
                                    secondaryText,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 84, AarogyaColors.primaryCyan),
                          _buildBarGroup(1, 62, AarogyaColors.accentPurple),
                          _buildBarGroup(2, 45, AarogyaColors.success),
                          _buildBarGroup(3, 72, AarogyaColors.warning),
                          _buildBarGroup(4, 38, AarogyaColors.info),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildTimeframeChip(String label, int index, bool isDark) {
    final isSelected = _selectedTimeframe == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTimeframe = index),
      selectedColor: isDark
          ? AarogyaColors.primaryCyan.withValues(alpha: 0.25)
          : AarogyaColors.primaryBlue.withValues(alpha: 0.15),
      labelStyle: AarogyaTypography.caption(
        isSelected
            ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
            : (isDark
                  ? AarogyaColors.textDarkSecondary
                  : AarogyaColors.textLightSecondary),
      ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
    );
  }
}
