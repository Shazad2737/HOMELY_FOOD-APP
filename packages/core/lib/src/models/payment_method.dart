enum PaymentMethod {
  cash,
  cheque,
  card,
  onlineTransfer;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.onlineTransfer:
        return 'Online';
    }
  }

  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.cheque:
        return 'cheque';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.onlineTransfer:
        return 'online';
    }
  }
}
