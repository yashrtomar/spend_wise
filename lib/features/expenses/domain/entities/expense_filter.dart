class ExpenseFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final double? minAmount;
  final double? maxAmount;

  const ExpenseFilter({
    this.startDate,
    this.endDate,
    this.categories,
    this.minAmount,
    this.maxAmount,
  });

  ExpenseFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    double? minAmount,
    double? maxAmount,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategories = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return ExpenseFilter(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      categories: clearCategories ? null : (categories ?? this.categories),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      (categories == null || categories!.isEmpty) &&
      minAmount == null &&
      maxAmount == null;
}

enum ExpenseSort {
  newest,
  oldest,
  amountHighest,
  amountLowest,
}
