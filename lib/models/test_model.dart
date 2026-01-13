import 'package:json_annotation/json_annotation.dart';

part 'test_model.g.dart';

@JsonSerializable()
class TestModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? discountedPrice;
  final int tatHours;

  TestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.discountedPrice,
    required this.tatHours,
  });

  // Connect the generated _code
  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);
  Map<String, dynamic> toJson() => _$TestModelToJson(this);
}
