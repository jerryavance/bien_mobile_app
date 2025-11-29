// ==========================================
// FILE: lib/models/bill_models.dart
// Complete bill payment models
// ==========================================

/// Bill Category (Electricity, NWSC, Mobile Recharge, etc.)
class BillCategory {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryDescription;
  final List<Biller> billers;

  BillCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryDescription,
    required this.billers,
  });

  factory BillCategory.fromJson(Map<String, dynamic> json) {
    final billsData = json['bills'] as List? ?? [];
    final billers = billsData.map((b) => Biller.fromJson(b as Map<String, dynamic>)).toList();

    return BillCategory(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'] ?? '',
      categoryDescription: json['categoryDescription'] ?? '',
      billers: billers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryDescription': categoryDescription,
      'bills': billers.map((b) => b.toJson()).toList(),
    };
  }
}

/// Individual Biller (UEDCL, MTN, Airtel, etc.)
class Biller {
  final String billId;
  final String billName;
  final String billCode;
  final String billIcon;
  final String billDescription;
  final List<BillField> fields;

  Biller({
    required this.billId,
    required this.billName,
    required this.billCode,
    required this.billIcon,
    required this.billDescription,
    required this.fields,
  });

  factory Biller.fromJson(Map<String, dynamic> json) {
    final fieldsData = json['fields'] as List? ?? [];
    final fields = fieldsData.map((f) => BillField.fromJson(f as Map<String, dynamic>)).toList();

    return Biller(
      billId: json['billId'] ?? '',
      billName: json['billName'] ?? '',
      billCode: json['billCode'] ?? '',
      billIcon: json['billIcon'] ?? '',
      billDescription: json['billDescription'] ?? '',
      fields: fields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'billName': billName,
      'billCode': billCode,
      'billIcon': billIcon,
      'billDescription': billDescription,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }
}

/// Bill Field (inputs required for payment)
class BillField {
  final String fieldId;
  final String fieldName;
  final String fieldType; // DropDown, Number, Phone, Text
  final String fieldDescription;
  final int fieldPriority;
  final List<FieldValue> values; // For dropdown fields

  BillField({
    required this.fieldId,
    required this.fieldName,
    required this.fieldType,
    required this.fieldDescription,
    required this.fieldPriority,
    required this.values,
  });

  bool get isDropdown => fieldType == 'DropDown';
  bool get isNumber => fieldType == 'Number';
  bool get isPhone => fieldType == 'Phone';
  bool get isText => fieldType == 'Text';

  factory BillField.fromJson(Map<String, dynamic> json) {
    final valuesData = json['values'] as List? ?? [];
    final values = valuesData.map((v) => FieldValue.fromJson(v as Map<String, dynamic>)).toList();

    return BillField(
      fieldId: json['fieldId'] ?? '',
      fieldName: json['fieldName'] ?? '',
      fieldType: json['fieldType'] ?? 'Text',
      fieldDescription: json['fieldDescription'] ?? '',
      fieldPriority: int.tryParse(json['fieldPriority']?.toString() ?? '0') ?? 0,
      values: values,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldName': fieldName,
      'fieldType': fieldType,
      'fieldDescription': fieldDescription,
      'fieldPriority': fieldPriority,
      'values': values.map((v) => v.toJson()).toList(),
    };
  }
}

/// Dropdown Field Value
class FieldValue {
  final String valueId;
  final String value;
  final String valueName;
  final String valueDescription;
  final int valuePriority;

  FieldValue({
    required this.valueId,
    required this.value,
    required this.valueName,
    required this.valueDescription,
    required this.valuePriority,
  });

  factory FieldValue.fromJson(Map<String, dynamic> json) {
    return FieldValue(
      valueId: json['valueId'] ?? '',
      value: json['value'] ?? '',
      valueName: json['valueName'] ?? '',
      valueDescription: json['valueDescription'] ?? '',
      valuePriority: int.tryParse(json['valuePriority']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valueId': valueId,
      'value': value,
      'valueName': valueName,
      'valueDescription': valueDescription,
      'valuePriority': valuePriority,
    };
  }
}

/// Bill Validation Response
class BillValidationResponse {
  final String responseCode;
  final String responseMessage;
  final String requestReference;
  final String retrievalReference;
  final String transactionReference;
  final String biller;
  final String customerId;
  final String customerName;
  final String paymentItem;
  final double amount;
  final double totalAmount;
  final double surcharge;
  final double excise;
  final double balance;
  final String? balanceNarration;
  final Map<String, dynamic>? charges;

  BillValidationResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.requestReference,
    required this.retrievalReference,
    required this.transactionReference,
    required this.biller,
    required this.customerId,
    required this.customerName,
    required this.paymentItem,
    required this.amount,
    required this.totalAmount,
    required this.surcharge,
    required this.excise,
    required this.balance,
    this.balanceNarration,
    this.charges,
  });

  bool get isSuccessful => responseCode == '90000';

  factory BillValidationResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? {};
    final charges = json['charges'] as Map<String, dynamic>?;

    return BillValidationResponse(
      responseCode: json['responseCode'] ?? '',
      responseMessage: json['responseMessage'] ?? '',
      requestReference: json['requestReference'] ?? '',
      retrievalReference: response['retrievalReference'] ?? '',
      transactionReference: response['transactionReference'] ?? '',
      biller: response['biller'] ?? '',
      customerId: response['customerId'] ?? '',
      customerName: response['customerName'] ?? '',
      paymentItem: response['paymentItem'] ?? '',
      amount: (response['amount'] ?? 0).toDouble(),
      totalAmount: (response['totalAmount'] ?? 0).toDouble(),
      surcharge: (response['surcharge'] ?? 0).toDouble(),
      excise: (response['excise'] ?? 0).toDouble(),
      balance: (response['balance'] ?? 0).toDouble(),
      balanceNarration: response['balanceNarration'],
      charges: charges,
    );
  }
}

/// Bill Payment Response
class BillPaymentResponse {
  final String responseCode;
  final String responseMessage;
  final String requestReference;
  final String retrievalReference;
  final String transactionReference;
  final String paymentDate;
  final double amount;
  final double totalAmount;
  final double surcharge;
  final double excise;
  final String? token;
  final String? units;
  final String? receiptNumber;

  BillPaymentResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.requestReference,
    required this.retrievalReference,
    required this.transactionReference,
    required this.paymentDate,
    required this.amount,
    required this.totalAmount,
    required this.surcharge,
    required this.excise,
    this.token,
    this.units,
    this.receiptNumber,
  });

  bool get isSuccessful => responseCode == '90000';

  factory BillPaymentResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? {};

    return BillPaymentResponse(
      responseCode: json['responseCode'] ?? '',
      responseMessage: json['responseMessage'] ?? '',
      requestReference: json['requestReference'] ?? '',
      retrievalReference: response['retrievalReference'] ?? '',
      transactionReference: response['transactionReference'] ?? '',
      paymentDate: response['paymentDate'] ?? '',
      amount: (response['amount'] ?? 0).toDouble(),
      totalAmount: (response['totalAmount'] ?? 0).toDouble(),
      surcharge: (response['surcharge'] ?? 0).toDouble(),
      excise: (response['excise'] ?? 0).toDouble(),
      token: response['token'],
      units: response['units'],
      receiptNumber: response['receiptNumber'],
    );
  }
}