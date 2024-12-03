import 'package:fino_app/provider/buy_provider.dart';
import 'package:fino_app/provider/expenses_provider.dart';
import 'package:fino_app/provider/incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Color color; 
  final List<Color> colors;
  final Function(ThemeMode) cambiarTema;
  const HomeScreen({super.key, required this.color, required this.colors, required this.cambiarTema});

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
      backgroundColor: widget.color,
      body: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedTargetTotals(
                category: 'Ingresos',
                amount: totalIncomes,
                color: widget.colors[1],
              ),
              AnimatedTargetTotals(
                category: 'Egresos',
                amount: totalExpenses,
                color: widget.colors[2],
              ),
              AnimatedTargetTotals(
                category: 'Compras',
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
                        color: Color(0xFF0E0E0E),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  color: widget.color,
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
  const AnimatedTargetTotals ({
    super.key,
    required this.category,
    required this.color,
    required this.amount,
    
  });

  final String category;
  final Color color;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Card(
          color: Colors.white,
          elevation: 8.0,
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
                            color: color,
                          ),
                        );
                      }, 
                      color: color, 
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
    super.key,
    required this.value,
    required this.builder,
    required color,
  });

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
