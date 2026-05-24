class BookingRequest {
  const BookingRequest({
    required this.trackingNumber,
    required this.serviceName,
    required this.customerName,
    required this.customerWhatsapp,
    required this.manualAddress,
    required this.requiredDateTime,
    required this.jobDescription,
    this.latitude,
    this.longitude,
  });

  final String trackingNumber;
  final String serviceName;
  final String customerName;
  final String customerWhatsapp;
  final String manualAddress;
  final DateTime requiredDateTime;
  final String jobDescription;
  final double? latitude;
  final double? longitude;

  String get gpsText {
    if (latitude == null || longitude == null) {
      return 'Not fetched / customer will use manual address';
    }
    return '$latitude, $longitude';
  }

  String toWhatsappMessage() {
    return '''
Hello Online Thekedaar, I want to book a service.

Tracking Number: $trackingNumber
Service: $serviceName
Customer Name: $customerName
Customer WhatsApp: $customerWhatsapp
GPS Coordinates: $gpsText
Manual Address: $manualAddress
Required Date/Time: ${_formatDateTime(requiredDateTime)}

Job Description:
$jobDescription
''';
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute';
  }
}
