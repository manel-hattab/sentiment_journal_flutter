import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/stats_provider.dart';
import '../../providers/journal_provider.dart';

// ConsumerStatefulWidget car on a besoin de AnimationController
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with TickerProviderStateMixin {
  // Un controller par graphique
  late AnimationController _barController;
  late AnimationController _lineController;
  late AnimationController _pieController;
  late AnimationController _cardController;

  late Animation<double> _barAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _pieAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    // Cartes résumé — apparition rapide
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack, // effet bounce
    );

    // BarChart — barres qui montent
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );

    // LineChart — courbe qui se trace
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _lineAnimation = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeInOut,
    );

    // PieChart — rotation d'apparition
    _pieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pieAnimation = CurvedAnimation(
      parent: _pieController,
      curve: Curves.easeOutCubic,
    );

    // Lancer les animations en cascade
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _barController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _lineController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _pieController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _barController.dispose();
    _lineController.dispose();
    _pieController.dispose();
    super.dispose();
  }

  // Helper sécurisé
  int _getInt(Map<String, dynamic> stats, String key) {
    return (stats[key] ?? 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final entriesAsync = ref.watch(entriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('📊 Mes Statistiques'),
        centerTitle: true,
      ),
      body: entriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (entries) {
          if (entries.isEmpty) return _buildEmptyState();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cartes avec animation bounce
                _buildSummaryCards(stats),
                const SizedBox(height: 24),

                _buildSectionTitle('Évolution sur 7 jours'),
                const SizedBox(height: 12),
                _buildLineChart(stats),
                const SizedBox(height: 24),

                _buildSectionTitle('Répartition des humeurs'),
                const SizedBox(height: 12),
                _buildBarChart(stats),
                const SizedBox(height: 24),

                _buildSectionTitle('Distribution'),
                const SizedBox(height: 12),
                _buildPieChart(stats),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== CARTES RÉSUMÉ avec animation bounce =====
  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Opacity(
            opacity: _cardAnimation.value.clamp(0.0, 1.0),
            child: Row(
              children: [
                _summaryCard('📝', '${_getInt(stats, 'total')}', 'Total', Colors.deepPurple),
                const SizedBox(width: 8),
                _summaryCard('😊', '${_getInt(stats, 'positif')}', 'Positif', Colors.green),
                const SizedBox(width: 8),
                _summaryCard('😢', '${_getInt(stats, 'negatif')}', 'Négatif', Colors.red),
                const SizedBox(width: 8),
                _summaryCard('😐', '${_getInt(stats, 'neutre')}', 'Neutre', Colors.orange),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
    );
  }

  // ===== LINE CHART animé — courbe qui se trace =====
  Widget _buildLineChart(Map<String, dynamic> stats) {
    final chartData = (stats['chartData'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    if (chartData.isEmpty) return const SizedBox();

    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        // Nombre de points à afficher selon l'animation
        final visibleCount = (chartData.length * _lineAnimation.value).ceil().clamp(1, chartData.length);
        final visibleData = chartData.sublist(0, visibleCount);

        return Opacity(
          opacity: _lineAnimation.value,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= chartData.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(chartData[index]['day'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: -1,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    // Points qui apparaissent progressivement
                    spots: visibleData.asMap().entries.map((e) {
                      final score = (e.value['score'] ?? 0.0) as double;
                      return FlSpot(e.key.toDouble(), score);
                    }).toList(),
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.deepPurple,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== BAR CHART animé — barres qui montent =====
  Widget _buildBarChart(Map<String, dynamic> stats) {
    final total = _getInt(stats, 'total');
    final positif = _getInt(stats, 'positif');
    final negatif = _getInt(stats, 'negatif');
    final neutre = _getInt(stats, 'neutre');

    return AnimatedBuilder(
      animation: _barAnimation,
      builder: (context, child) {
        // Multiplier les valeurs par l'animation → barres qui montent
        final animValue = _barAnimation.value;

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: total.toDouble() + 1,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      switch (value.toInt()) {
                        case 0: return const Text('😊', style: TextStyle(fontSize: 18));
                        case 1: return const Text('😢', style: TextStyle(fontSize: 18));
                        case 2: return const Text('😐', style: TextStyle(fontSize: 18));
                        default: return const SizedBox();
                      }
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                // toY multiplié par animValue → monte de 0 à la valeur réelle
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: positif * animValue, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(6)),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: negatif * animValue, color: Colors.red, width: 40, borderRadius: BorderRadius.circular(6)),
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(toY: neutre * animValue, color: Colors.orange, width: 40, borderRadius: BorderRadius.circular(6)),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== PIE CHART animé — apparition progressive =====
  Widget _buildPieChart(Map<String, dynamic> stats) {
    final total = _getInt(stats, 'total');
    final positif = _getInt(stats, 'positif');
    final negatif = _getInt(stats, 'negatif');
    final neutre = _getInt(stats, 'neutre');

    if (total == 0) return const SizedBox();

    return AnimatedBuilder(
      animation: _pieAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pieAnimation.value,
          child: Transform.scale(
            scale: _pieAnimation.value,
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        // Rayon animé — grandit de 0 à 60
                        sections: [
                          if (positif > 0)
                            PieChartSectionData(
                              value: positif.toDouble(),
                              color: Colors.green,
                              title: '${((positif / total) * 100).toStringAsFixed(0)}%',
                              radius: 60 * _pieAnimation.value,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          if (negatif > 0)
                            PieChartSectionData(
                              value: negatif.toDouble(),
                              color: Colors.red,
                              title: '${((negatif / total) * 100).toStringAsFixed(0)}%',
                              radius: 60 * _pieAnimation.value,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          if (neutre > 0)
                            PieChartSectionData(
                              value: neutre.toDouble(),
                              color: Colors.orange,
                              title: '${((neutre / total) * 100).toStringAsFixed(0)}%',
                              radius: 60 * _pieAnimation.value,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem(Colors.green, 'Positif', positif),
                      const SizedBox(height: 8),
                      _legendItem(Colors.red, 'Négatif', negatif),
                      const SizedBox(height: 8),
                      _legendItem(Colors.orange, 'Neutre', neutre),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📊', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('Pas encore de données', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          SizedBox(height: 8),
          Text('Écris quelques entrées pour\nvoir tes statistiques', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}