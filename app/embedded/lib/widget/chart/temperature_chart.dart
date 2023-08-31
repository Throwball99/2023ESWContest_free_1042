import 'package:embedded/page/detailChart_page/temperatureChart_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TemperatureChart extends StatefulWidget {
  final List<Map<String, dynamic>> temperatureData;
  final String plantVarieties;

  const TemperatureChart({Key? key, required this.temperatureData, required this.plantVarieties}) : super(key: key);

  @override
  _TemperatureChartState createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  List<Color> gradientColors = [
    Colors.tealAccent,
    Colors.blue,
  ];

  bool showAvg = false;
  List<Map<String, dynamic>> temperatureLastTenData = [];
  double temperatureAverage = 0;

  @override
  void initState() {
    super.initState();
    var startIndex = widget.temperatureData.length > 10 ? widget.temperatureData.length - 10 : 0;
    temperatureLastTenData = widget.temperatureData.sublist(startIndex, widget.temperatureData.length);
    temperatureAverage = temperatureLastTenData.map((e) => (e['temperature']).toDouble()).reduce((a, b) => a + b) / temperatureLastTenData.length;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: double.maxFinite,
              height: 100,
              child: LineChart(
                mainData(),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedTemperaturePage(temperatureData: widget.temperatureData, plantVarieties: widget.plantVarieties,)));
              },
              child: SizedBox(
                height: 30,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('온도: ${temperatureAverage.toStringAsFixed(1)}'),
                      Text('더보기')
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  LineChartData mainData() {
    double maxY = temperatureLastTenData.map((e) => (e['temperature']).toDouble()).reduce((value, element) => value > element ? value : element);

    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: temperatureLastTenData.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: temperatureLastTenData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), (e.value['temperature']).toDouble());
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final dataIndex = flSpot.x.toInt();

              if (dataIndex < 0 || dataIndex >= temperatureLastTenData.length) {
                return null;
              }

              final date = temperatureLastTenData[dataIndex]['date'];
              return LineTooltipItem(date, const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}