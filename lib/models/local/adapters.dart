import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';

class PRFUserAdapter extends TypeAdapter<PRFUser> {
  @override
  final typeId = 0;

  @override
  PRFUser read(BinaryReader reader) {
    return PRFUser.fromJson(
      Map<String, dynamic>.of(
        json.decode(reader.read() as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  void write(BinaryWriter writer, PRFUser obj) {
    writer.write(json.encode(obj.toJson()));
  }
}

class PRFExpenseCategoryResponseAdapter
    extends TypeAdapter<PRFExpenseCategoryResponse> {
  @override
  final typeId = 3;

  @override
  PRFExpenseCategoryResponse read(BinaryReader reader) {
    return PRFExpenseCategoryResponse.fromJson(
      Map<String, dynamic>.of(
        json.decode(reader.read() as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  void write(BinaryWriter writer, PRFExpenseCategoryResponse obj) {
    writer.write(json.encode(obj.toJson()));
  }
}
