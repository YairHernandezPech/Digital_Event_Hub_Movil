import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentFormScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar con STRIPE'),
      ),
      body: Container(
        color: Colors.white, // Fondo blanco
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Imagen de Stripe en la parte superior
            Center(
              child: Image.asset(
                'assets/stripe.png',
                height: 150, // Ajusta el tamaño según sea necesario
              ),
            ),
            SizedBox(height: 24), // Espacio entre la imagen y el formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Fila para Card Number, MM y YY
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          controller: cardNumberController,
                          labelText: 'Card Number',
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your card number';
                            } else if (value.length < 16) {
                              return 'Card number must be at least 16 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          controller: expiryMonthController,
                          labelText: 'MM',
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter month';
                            } else if (int.tryParse(value) == null ||
                                int.parse(value) < 1 ||
                                int.parse(value) > 12) {
                              return 'Enter a valid month (01-12)';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          controller: expiryYearController,
                          labelText: 'YY',
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter year';
                            } else if (int.tryParse(value) == null ||
                                int.parse(value) < 0 ||
                                int.parse(value) > 99) {
                              return 'Enter a valid year (00-99)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Fila para CVV y Card Holder Name
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          controller: cvvController,
                          labelText: 'CVV',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your card\'s CVV';
                            } else if (value.length < 3) {
                              return 'CVV must be at least 3 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: cardHolderNameController,
                          labelText: 'Card Holder Name',
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the card holder\'s name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Process the payment
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Payment')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(double.infinity, 50), // Tamaño mínimo del botón
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Submit Payment',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required bool obscureText,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Borde gris
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Borde gris al enfocar
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }
}
