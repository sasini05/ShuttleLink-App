import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pass_available_rides.dart';

class PassengerRideConfigScreen extends StatefulWidget {
  final String routeName;

  // Clean, standard constructor!
  const PassengerRideConfigScreen({super.key, required this.routeName});

  @override
  State<PassengerRideConfigScreen> createState() => _PassengerRideConfigScreenState();
}

class _PassengerRideConfigScreenState extends State<PassengerRideConfigScreen> {
  bool _isMorning = true;
  String? _selectedCity;
  DateTime? _selectedDate;

  final Map<String, List<String>> _routeCities = {
    'Kandy': ['Kandy', 'Peradeniya', 'Pilimathalawa', 'Kadugannawa', 'Mawanella', 'Kegalle', 'Galigamuwa', 'Warakapola', 'Nittambuwa', 'Homagama'],
    'Gampaha': ['Gampaha', 'Miriswatta', 'Kirillawala', 'Kadawatha', 'Homagama'],
    'Galle': ['Galle', 'Kaluwella', 'Thalapitiya', 'Makuluwa', 'Katugoda', 'Walahanduwa'],
  };

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF43C59E),
              onPrimary: Colors.white,
              surface: Color(0xFF2C2C2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_selectedCity == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red));
      return;
    }

    String fromCity = _isMorning ? _selectedCity! : 'NSBM';
    String toCity = _isMorning ? 'NSBM' : _selectedCity!;
    String shift = _isMorning ? 'Morning' : 'Evening';
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Cleaned up navigation using standard lowercase 'context'
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerAvailableRidesScreen(
          routeName: widget.routeName,
          fromCity: fromCity,
          toCity: toCity,
          date: formattedDate,
          shift: shift,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentCities = _routeCities[widget.routeName] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF14453D),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF00897B), borderRadius: BorderRadius.circular(10)),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 20),
                  Text("NSBM-${widget.routeName.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: const BoxDecoration(
                  color: Color(0xFF202124),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 45,
                        width: 250,
                        // Updated to use the new Flutter transparency rule!
                        decoration: BoxDecoration(color: const Color(0xFF43C59E).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(25)),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() { _isMorning = true; _selectedCity = null; }),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isMorning ? const Color(0xFF43C59E) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text("Morning", style: TextStyle(color: _isMorning ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() { _isMorning = false; _selectedCity = null; }),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isMorning ? const Color(0xFF43C59E) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text("Evening", style: TextStyle(color: !_isMorning ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text("From :", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _isMorning
                        ? _buildCityDropdown(currentCities, "Select the nearest city to your stop")
                        : _buildDisabledBox("NSBM"),

                    const SizedBox(height: 20),
                    const Text("To :", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    !_isMorning
                        ? _buildCityDropdown(currentCities, "Select the nearest city to your stop")
                        : _buildDisabledBox("NSBM"),

                    const SizedBox(height: 20),
                    const Text("Date :", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(color: const Color(0xFF9F9F9F), borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null ? "Select Date" : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43C59E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown(List<String> cities, String hint) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFF9F9F9F), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: const Color(0xFF2C2C2C),
          hint: Text(hint, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          value: _selectedCity,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: cities.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedCity = newValue),
        ),
      ),
    );
  }

  Widget _buildDisabledBox(String text) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      // Updated transparency rule here too!
      decoration: BoxDecoration(color: const Color(0xFF9F9F9F).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}