/// Holds billing rate parameters used to estimate electricity bills.
class BillingRate {
  final double ratePerKwh;
  final double fixedCharge;
  final double additionalCharges;
  final double taxPercent;
  final bool isSlabBilling;

  const BillingRate({
    this.ratePerKwh = 8.00,
    this.fixedCharge = 100.00,
    this.additionalCharges = 0.00,
    this.taxPercent = 5.0,
    this.isSlabBilling = false,
  });

  BillingRate copyWith({
    double? ratePerKwh,
    double? fixedCharge,
    double? additionalCharges,
    double? taxPercent,
    bool? isSlabBilling,
  }) {
    return BillingRate(
      ratePerKwh: ratePerKwh ?? this.ratePerKwh,
      fixedCharge: fixedCharge ?? this.fixedCharge,
      additionalCharges: additionalCharges ?? this.additionalCharges,
      taxPercent: taxPercent ?? this.taxPercent,
      isSlabBilling: isSlabBilling ?? this.isSlabBilling,
    );
  }
}
