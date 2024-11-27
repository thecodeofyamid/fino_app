import 'package:fino_app/models/buys_model.dart';
import 'package:fino_app/provider/buy_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BuysScreen extends StatefulWidget {
  const BuysScreen({super.key, required this.colors});
  final List<int> colors;

  @override
  _BuysScreenState createState() => _BuysScreenState();
}

class _BuysScreenState extends State<BuysScreen> {
  final _formKey = GlobalKey<FormState>();
  String _buyName = '';
  double _buyAmount = 0.0;

  void sendBuys() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Provider.of<BuyProvider>(context, listen: false).addBuy(
        Buy(name: _buyName, amount: _buyAmount),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Compra agregada exitosamente',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );

      // Limpiar los campos de entrada
      _formKey.currentState!.reset();
      setState(() {
        _buyName = '';
        _buyAmount = 0.0;
      });
    }
  }

  void viewBuys() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuysListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.colors[3]),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 300,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Agregar Compra',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese un nombre';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _buyName = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Monto',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Por favor, ingrese un monto válido';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _buyAmount = double.parse(value!);
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          onPressed: sendBuys,
                          child: const Text('Agregar Compra'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: viewBuys,
                          child: const Text('Ver Compras'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class BuysListScreen extends StatelessWidget {
  const BuysListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buys = Provider.of<BuyProvider>(context).buys;
    final numberFormat = NumberFormat('#,##0.00', 'es_CO');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
      ),
      body: ListView.builder(
        itemCount: buys.length,
        itemBuilder: (context, index) {
          final buy = buys[index];
          return Card(
            child: ListTile(
              title: Text(buy.name),
              subtitle: Text(
                'Monto: \$${numberFormat.format(buy.amount)}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}