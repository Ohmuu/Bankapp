import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color whitePurple = const Color(0xFF6F61C2);
Color darkPurple = const Color(0xFF533483);
Color successGreen = const Color(0xFF28A745);
Color errorRed = const Color(0xFFDC3545);

class PinSetupPage extends StatefulWidget {
  final bool isChangePin;
  const PinSetupPage({super.key, this.isChangePin = false});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  String _oldPin = '';
  bool _isConfirm = false;
  bool _isOldPin = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isOldPin = widget.isChangePin;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: darkPurple,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        buildHeader(),
                        SizedBox(height: 20),
                        buildPinDisplay(),
                        SizedBox(height: 20),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              textAlign: TextAlign.center,
                              _errorMessage,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildPinPad(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    String title;
    String subtitle;
    if (_isOldPin) {
      title = 'Enter Current PIN';
      subtitle = 'Enter your current PIN to continue';
    } else if (_isConfirm) {
      title = 'Confirm your PIN';
      subtitle = 'Confirm your new PIN';
    } else {
      title = widget.isChangePin ? 'Create New PIN' : 'Create your PIN';
      subtitle = 'Create a new 4-digit PIN';
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPinDisplay() {
    String currentPin = _isOldPin ? _oldPin : (_isConfirm ? _confirmPin : _pin);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < currentPin.length;
        return Container(
          width: 50,
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? darkPurple : Colors.grey[300],

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),

          child: Center(
            child: isFilled ? Icon(Icons.circle, color: Colors.white) : null,
          ),
        );
      }),
    );
  }

  Widget buildPinPad() {
    return Column(
      children: [
        buildNumPadRow(['1', '2', '3']),
        SizedBox(height: 20),
        buildNumPadRow(['4', '5', '6']),
        SizedBox(height: 20),
        buildNumPadRow(['7', '8', '9']),
        SizedBox(height: 20),
        buildNumPadRow(['', '0', 'delete']),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildNumPadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return SizedBox(width: 60, height: 60);
        }

        return GestureDetector(
          onTap: () => _onNumberTap(number),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: number == 'delete' ? Colors.transparent : Colors.white,
              border: number == 'delete'
                  ? null
                  : Border.all(color: Colors.black87.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: number == 'delete'
                  ? Icon(Icons.backspace, color: Colors.black87)
                  : Text(
                      number,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onNumberTap(String number) async {
    setState(() {
      _errorMessage = '';
    });

    if (number == 'delete') {
      setState(() {
        if (_isOldPin) {
          if (_oldPin.isNotEmpty)
            _oldPin = _oldPin.substring(0, _oldPin.length - 1);
        } else if (_isConfirm) {
          if (_confirmPin.isNotEmpty)
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
        }
      });
      return;
    }
    if (_isOldPin) {
      if (_oldPin.length < 4) {
        setState(() {
          _oldPin += number;
        });
      }

      if (_oldPin.length == 4) {
        //verify old pin
        final prefsPin = await SharedPreferences.getInstance();
        final savedPin = prefsPin.getString('user_pin');
        if (savedPin == _oldPin) {
          setState(() {
            _isOldPin = false;
            _oldPin = '';
          });
        } else {
          setState(() {
            _errorMessage = 'Incorrect PIN';
            _oldPin = '';
          });
        }
      }
    } else if (_isConfirm) {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += number;
        });
      }

      if (_confirmPin.length == 4) {
        if (_pin == _confirmPin) {
          //save pin
          final prefsPin = await SharedPreferences.getInstance();
          await prefsPin.setString('user_pin', _pin);
          await prefsPin.setBool('is_pin_set', true);

          if (context.mounted) {
            _showSuccessDialog();
          }
        } else {
          setState(() {
            _errorMessage = 'PIN does not match';
            _confirmPin = '';
            _isConfirm = false;
            _pin = '';
          });
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() {
          _pin += number;
        });
      }

      if (_pin.length == 4) {
        setState(() {
          _isConfirm = true;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: successGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: successGreen, size: 24),
            ),
            SizedBox(height: 10, width: 10),
            Text(
              textAlign: TextAlign.center,
              widget.isChangePin ? 'PIN Changed!' : 'PIN Created!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              textAlign: TextAlign.center,
              widget.isChangePin
                  ? 'Your PIN has been changed successfully'
                  : 'Your PIN has been created successfully',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [darkPurple, whitePurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () => {
                Navigator.pop(context), // ปิด dialog
                Navigator.pop(context, true), // กลับหน้า Security
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
