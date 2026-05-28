class StripePreferences {
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String merchantName = 'Delhi Nights Restaurant';

  static const String currency = 'AUD';

  static const String currencySymbol = 'A\$';
}
