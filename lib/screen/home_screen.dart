import 'package:fino_app/provider/buy_provider.dart';
import 'package:fino_app/provider/expenses_provider.dart';
import 'package:fino_app/provider/incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.colors});
  final List<int> colors;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Inicializar el ScrollController
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Disponer el ScrollController
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final buyProvider = Provider.of<BuyProvider>(context);
    final numberFormat = NumberFormat('#,##0.00', 'es_CO');

    double totalExpenses = expenseProvider.expenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    double totalIncomes = incomeProvider.incomes.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    double totalBuys = buyProvider.buys.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    double generalTotal = totalIncomes - (totalExpenses + totalBuys);

    return Scaffold(
      backgroundColor: Color(widget.colors[1]),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedTargetTotals(
                category: 'Incomes',
                amount: totalIncomes,
                color: widget.colors[0],
              ),
              AnimatedTargetTotals(
                category: 'Expenses',
                amount: totalExpenses,
                color: widget.colors[2],
              ),
              AnimatedTargetTotals(
                category: 'Buys',
                amount: totalBuys,
                color: widget.colors[3],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedCounter(
                  value: generalTotal,
                  builder: (context, value) {
                    final generalTotalString = numberFormat.format(value);
                    return Text(
                      'Total general: COP $generalTotalString',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedTargetTotals extends StatelessWidget {
  const AnimatedTargetTotals({
    Key? key,
    required this.category,
    required this.color,
    required this.amount,
  }) : super(key: key);

  final String category;
  final int color;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    AnimatedCounter(
                      value: amount,
                      builder: (context, value) {
                        final numberFormat = NumberFormat('#,##0.00', 'es_CO');
                        final totalAmountString = numberFormat.format(value);
                        return Text(
                          'COP $totalAmountString',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(color),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    Key? key,
    required this.value,
    required this.builder,
  }) : super(key: key);

  final double value;
  final Widget Function(BuildContext, double) builder;

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ))..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _animation.value);
  }
}