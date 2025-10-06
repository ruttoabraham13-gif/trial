import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(const NumberConverterApp());
}

class NumberConverterApp extends StatelessWidget {
  const NumberConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number System Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const NumberConverterHomePage(),
    );
  }
}

class NumberConverterHomePage extends StatefulWidget {
  const NumberConverterHomePage({super.key});

  @override
  State<NumberConverterHomePage> createState() => _NumberConverterHomePageState();                               
}

class _NumberConverterHomePageState extends State<NumberConverterHomePage> {
  final TextEditingController _inputController = TextEditingController();
  String _selectedFromBase = 'Decimal';
  String _binaryResult = '';
  String _octalResult = '';
  String _decimalResult = '';
  String _hexResult = '';
  String _errorMessage = '';

  final List<String> _numberSystems = ['Binary', 'Octal', 'Decimal', 'Hexadecimal'];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_convertNumber);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convertNumber() {
    String input = _inputController.text.trim();
    
    if (input.isEmpty) {
      _clearResults();
      return;
    }

    try {
      int decimalValue = _parseToDecimal(input, _selectedFromBase);
      
      setState(() { 
        _binaryResult = decimalValue.toRadixString(2);
        _octalResult = decimalValue.toRadixString(8);
        _decimalResult = decimalValue.toString();
        _hexResult = decimalValue.toRadixString(16).toUpperCase();
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid input for $_selectedFromBase';
        _clearResultsOnly();
      });
    }
  }

  int _parseToDecimal(String input, String fromBase) {
    switch (fromBase) {
      case 'Binary':
        if (!RegExp(r'^[01]+$').hasMatch(input)) {
          throw FormatException('Invalid binary number');
        }
        return int.parse(input, radix: 2);
      case 'Octal':
        if (!RegExp(r'^[0-7]+$').hasMatch(input)) {
          throw FormatException('Invalid octal number');
        }
        return int.parse(input, radix: 8);
      case 'Decimal':
        if (!RegExp(r'^[0-9]+$').hasMatch(input)) {
          throw FormatException('Invalid decimal number');
        }
        return int.parse(input, radix: 10);
      case 'Hexadecimal':
        if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(input)) {
          throw FormatException('Invalid hexadecimal number');
        }
        return int.parse(input, radix: 16);
      default:
        throw FormatException('Unknown number system');
    }
  }

  void _clearResults() {
    setState(() {
      _binaryResult = '';
      _octalResult = '';
      _decimalResult = '';
      _hexResult = '';
      _errorMessage = '';
    });
  }

  void _clearResultsOnly() {
    setState(() {
      _binaryResult = '';
      _octalResult = '';
      _decimalResult = '';
      _hexResult = '';
    });
  }

  void _clearInput() {
    _inputController.clear();
    _clearResults();
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    value.isEmpty ? 'Enter a number to convert' : value,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                      color: value.isEmpty ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (value.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title value copied to clipboard'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copy to clipboard',
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number System Converter'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Section
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Input Number',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Number System Selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFromBase,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: _numberSystems.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFromBase = newValue!;
                                _convertNumber();
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Input Field
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          labelText: 'Enter $_selectedFromBase number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.indigo, width: 2),
                          ),
                          suffixIcon: _inputController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearInput,
                                )
                              : null,
                          errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Results Section
              const Text(
                'Conversion Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Binary Result
              _buildResultCard(
                'Binary (Base 2)',
                _binaryResult,
                Icons.code,
                Colors.green,
              ),
              
              // Octal Result
              _buildResultCard(
                'Octal (Base 8)',
                _octalResult,
                Icons.filter_8,
                Colors.orange,
              ),
              
              // Decimal Result
              _buildResultCard(
                'Decimal (Base 10)',
                _decimalResult,
                Icons.pin,
                Colors.blue,
              ),
              
              // Hexadecimal Result
              _buildResultCard(
                'Hexadecimal (Base 16)',
                _hexResult,
                Icons.hexagon_outlined,
                Colors.purple,
              ),
              
              const SizedBox(height: 32),
              
              // Information Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'How to use',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Select the number system of your input\n'
                        '2. Enter the number you want to convert\n'
                        '3. View results in all number systems\n'
                        '4. Tap copy icon to copy any result',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}