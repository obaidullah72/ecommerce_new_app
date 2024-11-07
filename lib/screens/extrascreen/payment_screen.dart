import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedPaymentMethod; // Default to null for unselected state
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final _easypaisa = TextEditingController();

  String? _selectedCardType; // Default unselected card type

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Payment Methods",
            style: GoogleFonts.poppins(
              color: Colors.indigo,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose a payment method",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                // Credit/Debit Card
                _buildPaymentOption(
                  size,
                  icon: Icons.credit_card,
                  method: 'Credit/Debit Card',
                ),

                SizedBox(height: size.height * 0.02),

                // Easypaisa
                _buildPaymentOption(
                  size,
                  icon: Icons.account_balance_wallet,
                  method: 'Easypaisa',
                ),

                SizedBox(height: size.height * 0.02),

                // Cash on Delivery
                _buildPaymentOption(
                  size,
                  icon: Icons.local_shipping,
                  method: 'Cash on Delivery',
                ),

                SizedBox(height: size.height * 0.04),

                // Show form based on selected payment method
                if (_selectedPaymentMethod == 'Credit/Debit Card')
                  _buildCardForm(size)
                else if (_selectedPaymentMethod == 'Easypaisa')
                  _buildEasypaisaForm(size),

                SizedBox(height: size.height * 0.04),

                // Continue Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String selectedInfo = '';
                      if (_selectedPaymentMethod == 'Credit/Debit Card') {
                        selectedInfo = 'Card Type: $_selectedCardType, Card Number: ${_cardNumberController.text}';
                      } else if (_selectedPaymentMethod == 'Easypaisa') {
                        selectedInfo = 'Easypaisa Phone Number: ${_easypaisa.text}';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selected Payment Method: $_selectedPaymentMethod\n$selectedInfo',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.2,
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a payment option card
  Widget _buildPaymentOption(Size size, {required IconData icon, required String method}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedPaymentMethod == method ? Colors.indigo : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: size.width * 0.08, color: Colors.indigo),
            SizedBox(width: size.width * 0.05),
            Text(
              method,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_selectedPaymentMethod == method)
              Icon(Icons.check_circle, color: Colors.indigo, size: size.width * 0.07)
          ],
        ),
      ),
    );
  }

  // Form for Credit/Debit Card details
  Widget _buildCardForm(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Card Details",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.02),

        // Dropdown for Card Type
        DropdownButtonFormField<String>(
          value: _selectedCardType,
          decoration: InputDecoration(
            labelText: 'Card Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: <String>['Visa', 'MasterCard'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCardType = newValue;
            });
          },
        ),
        SizedBox(height: size.height * 0.02),

        // Card Number Input
        TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: size.height * 0.02),

        // Expiry Date and CVC
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Expanded(
              child: TextField(
                controller: _cvcController,
                decoration: InputDecoration(
                  labelText: 'CVC',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Form for Easypaisa phone number
  Widget _buildEasypaisaForm(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Easypaisa Phone Number",
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        TextField(
          controller: _easypaisa,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
