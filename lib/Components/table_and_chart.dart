import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TableAndChart extends StatefulWidget {
  final double tenure, loanAmount, intrestRate, monthlyEmi;
  const TableAndChart(
      {super.key,
      required this.tenure,
      required this.loanAmount,
      required this.intrestRate,
      required this.monthlyEmi});

  @override
  State<TableAndChart> createState() => _TableAndChartState();
}

class _TableAndChartState extends State<TableAndChart> {
  List<double> data = List.empty(growable: true);

  int date = DateTime.now().year;

  late double openingbalance,
      mothlyPayment,
      computedDue = 0,
      principleDue = 0,
      principleBalance,
      yearlyEmi;

  void calculateData() {
    if (openingbalance <= 0) {
      return;
    }
    for (var i = 0; i < 12; i++) {
      computedDue = (openingbalance * (widget.intrestRate / 100)) / 12;
      openingbalance -= (widget.monthlyEmi - computedDue);
      principleBalance = openingbalance;
      principleDue += widget.monthlyEmi - computedDue;
      date + 1;
    }
    data.add(principleDue);
    setState(() {});
  }

  void getProfiles() {
    openingbalance = widget.loanAmount;
    principleBalance = widget.loanAmount;
    yearlyEmi = widget.monthlyEmi * 12;
  }

  String indianFormatNumber(double amount) {
    String numberFormat =
        NumberFormat.currency(locale: 'HI', symbol: '', decimalDigits: 0)
            .format(amount.toInt())
            .toString();

    return numberFormat;
  }

  @override
  void initState() {
    getProfiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amortization schedule"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Table(
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      const TableRow(children: [
                        TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Center(child: Text("year"))),
                        TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: Text("Yearly EMI")),
                            )),
                        TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Intrest paid yearly"),
                            )),
                        TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child:
                                  Center(child: Text("principle paid Yearly")),
                            )),
                        TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: Text("closing balance")),
                            )),
                      ]),
                      TableRow(children: [
                        TableCell(child: Center(child: Text(date.toString()))),
                        const TableCell(child: Center(child: Text("-"))),
                        const TableCell(child: Center(child: Text("-"))),
                        const TableCell(child: Center(child: Text("-"))),
                        TableCell(
                            child: Center(
                                child:
                                    Text(principleBalance.toInt().toString()))),
                      ]),
                      ...List.generate(widget.tenure.toInt(), (index) {
                        calculateData();
                        return openingbalance > 0
                            ? TableRow(children: [
                                TableCell(
                                    child: Center(
                                        child: Text((date++).toString()))),
                                TableCell(
                                    child: Center(
                                        child: Text(
                                            indianFormatNumber(yearlyEmi)))),
                                TableCell(
                                    child: Center(
                                        child: Text(
                                            indianFormatNumber(computedDue)))),
                                TableCell(
                                    child: Center(
                                        child: Text(
                                            indianFormatNumber(principleDue)))),
                                TableCell(
                                    child: Center(
                                        child: Text(principleBalance
                                            .toInt()
                                            .toString()))),
                              ])
                            : const TableRow(children: [
                                TableCell(child: Text("year")),
                                TableCell(child: Text("")),
                                TableCell(child: Text("")),
                                TableCell(child: Text("")),
                                TableCell(child: Text("")),
                              ]);
                      }),
                    ]),
              ),
              data.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 350,
                      width: double.infinity,
                      child: BarChart(BarChartData(
                          maxY: widget.loanAmount,
                          minY: 0,
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false))),
                          barGroups: List.generate(
                            widget.tenure.toInt(),
                            (index) => BarChartGroupData(
                                x: ((DateTime.now().year + index) - 2000),
                                barRods: [
                                  BarChartRodData(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.zero,
                                      toY: data[index],
                                      width: 10,
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                              toY: widget.loanAmount,
                                              show: true,
                                              color: Colors.orange))
                                ]),
                          ))))
                  : Container(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(children: [
                    ColoredBox(
                      color: Colors.orange,
                      child: SizedBox(
                        height: 20,
                        width: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Intrest")
                  ]),
                  Row(
                    children: [
                      ColoredBox(
                        color: Colors.blue,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("principle")
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
