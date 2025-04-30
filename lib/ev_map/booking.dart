import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EVChargingBooking extends StatefulWidget {
  final String? stationName;
  final String? stationAddress;

  const EVChargingBooking({Key? key, this.stationName, this.stationAddress})
    : super(key: key);

  @override
  State<EVChargingBooking> createState() => _EVChargingBookingState();
}

class _EVChargingBookingState extends State<EVChargingBooking> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? selectedVehicle;
  String? selectedConnector;
  DateTime selectedDate = DateTime.now().add(Duration(hours: 1));
  TimeOfDay selectedTime = TimeOfDay.fromDateTime(
    DateTime.now().add(Duration(hours: 1)),
  );
  int durationMinutes = 30;
  String? name;
  String? phone;
  String? vehicleRegNumber;

  // Sample data
  final List<String> vehicles = [
    'Tata Nexon EV',
    'MG ZS EV',
    'Hyundai Kona Electric',
    'Mahindra XUV400',
    'Kia EV6',
    'Other',
  ];

  final List<String> connectorTypes = [
    'CCS Type 2 (DC Fast)',
    'Type 2 (AC)',
    'CHAdeMO (DC)',
    'Bharat AC 001',
    'Bharat DC 001',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Book a Charging Slot',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.green),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station details
              if (widget.stationName != null)
                _buildInfoCard(
                  'Charging Station',
                  widget.stationName!,
                  widget.stationAddress ?? 'Address not available',
                  Icons.ev_station,
                ),

              SizedBox(height: 20),

              // Vehicle selection
              _buildSectionTitle('Vehicle Information'),
              _buildDropdown(
                label: 'Select Your Vehicle',
                items: vehicles,
                value: selectedVehicle,
                onChanged: (value) {
                  setState(() {
                    selectedVehicle = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a vehicle';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Vehicle registration
              _buildTextField(
                label: 'Vehicle Registration Number',
                icon: Icons.car_rental,
                onChanged: (value) {
                  vehicleRegNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle registration number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Charging details
              _buildSectionTitle('Charging Details'),
              _buildDropdown(
                label: 'Connector Type',
                items: connectorTypes,
                value: selectedConnector,
                onChanged: (value) {
                  setState(() {
                    selectedConnector = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a connector type';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Date and time selection
              _buildSectionTitle('Date & Time'),
              Row(
                children: [
                  Expanded(child: _buildDatePicker(context)),
                  SizedBox(width: 10),
                  Expanded(child: _buildTimePicker(context)),
                ],
              ),

              SizedBox(height: 16),

              // Duration slider
              _buildDurationSelector(),

              SizedBox(height: 20),

              // Contact info
              _buildSectionTitle('Contact Information'),
              _buildTextField(
                label: 'Full Name',
                icon: Icons.person,
                onChanged: (value) {
                  name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              _buildTextField(
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  phone = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              // Summary and pricing
              _buildPricingSummary(),

              SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showBookingConfirmation();
                    }
                  },
                  child: Text(
                    'Book Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String name,
    String address,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  address,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.green,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green),
        ),
        filled: true,
        fillColor: Colors.grey.shade900,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(color: Colors.white),
      dropdownColor: Colors.grey.shade900,
      value: value,
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: Icon(Icons.arrow_drop_down, color: Colors.green),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.green.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green),
        ),
        filled: true,
        fillColor: Colors.grey.shade900,
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.green.shade300, size: 20),
            SizedBox(width: 10),
            Text(
              DateFormat('dd MMM yyyy').format(selectedDate),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.black,
              surface: Colors.grey.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey.shade900,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.green.shade300, size: 20),
            SizedBox(width: 10),
            Text(
              selectedTime.format(context),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.black,
              surface: Colors.grey.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey.shade900,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Charging Duration',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '$durationMinutes minutes',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Slider(
          value: durationMinutes.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          activeColor: Colors.green,
          inactiveColor: Colors.grey.shade800,
          thumbColor: Colors.green.shade300,
          label: '$durationMinutes min',
          onChanged: (value) {
            setState(() {
              durationMinutes = value.round();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15 min', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('2 hours', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSummary() {
    // Calculate estimated price based on duration
    final double basePrice = 100.0; // Base price in INR
    final double minuteRate = 2.5; // Rate per minute in INR
    final double estimatedPrice = basePrice + (durationMinutes * minuteRate);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Base charging fee', style: TextStyle(color: Colors.grey)),
              Text('₹$basePrice', style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration ($durationMinutes min)',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '₹${(durationMinutes * minuteRate).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade800, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${estimatedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Final price may vary based on actual charging time',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation() {
    // Format time for display
    final String formattedDate = DateFormat(
      'EEE, MMM d, yyyy',
    ).format(selectedDate);
    final String formattedTime = selectedTime.format(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'Booking Confirmed',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your charging slot booked successfully!',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                _buildConfirmationRow('Date', formattedDate),
                _buildConfirmationRow('Time', formattedTime),
                _buildConfirmationRow('Duration', '$durationMinutes minutes'),
                if (widget.stationName != null)
                  _buildConfirmationRow('Station', widget.stationName!),
                _buildConfirmationRow(
                  'Vehicle',
                  selectedVehicle ?? 'Not specified',
                ),
                _buildConfirmationRow(
                  'Connector',
                  selectedConnector ?? 'Not specified',
                ),
                SizedBox(height: 16),
                Text(
                  'A confirmation has been sent to your phone: ${phone ?? "Not provided"}',
                  style: TextStyle(color: Colors.green.shade300, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label + ':',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
