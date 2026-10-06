/// Representation of a ticket recipient selected via contact picker, phone, or link
class TransferRecipient {
  const TransferRecipient({
    required this.name,
    required this.phoneNumber,
    this.email,
    this.isContact = true,
  });

  final String name;
  final String phoneNumber;
  final String? email;
  final bool isContact;

  String get avatarInitials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'TransferRecipient(name: $name, phone: $phoneNumber, isContact: $isContact)';
}

/// Pre-populated sample contacts for quick contact picker selection
const sampleContacts = <TransferRecipient>[
  TransferRecipient(
    name: 'Rahul Sharma',
    phoneNumber: '+91 98765 11111',
    email: 'rahul.sharma@example.com',
    isContact: true,
  ),
  TransferRecipient(
    name: 'Priya Verma',
    phoneNumber: '+91 98765 22222',
    email: 'priya.verma@example.com',
    isContact: true,
  ),
  TransferRecipient(
    name: 'Ananya Sen',
    phoneNumber: '+91 98765 33333',
    email: 'ananya.sen@example.com',
    isContact: true,
  ),
  TransferRecipient(
    name: 'Rohan Patel',
    phoneNumber: '+91 98765 44444',
    email: 'rohan.patel@example.com',
    isContact: true,
  ),
  TransferRecipient(
    name: 'Sneha Kapoor',
    phoneNumber: '+91 98765 55555',
    email: 'sneha.k@example.com',
    isContact: true,
  ),
];
