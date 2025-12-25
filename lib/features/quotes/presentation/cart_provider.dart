import 'package:clinical_lab_app/core/models/lab_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CartNotifier extends StateNotifier<List<LabTest>> {
  CartNotifier() : super([]);

  void addTest(LabTest test) {
    if (!state.any((element) => element.id == test.id)) {
      state = [...state, test];
    }
  }

  void removeTest(String testId) {
    state = state.where((element) => element.id != testId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount => state.fold(0.0, (sum, item) => sum + item.price);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<LabTest>>((ref) {
  return CartNotifier();
});
