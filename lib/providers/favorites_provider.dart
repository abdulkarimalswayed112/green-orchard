import 'package:flutter/foundation.dart';

import '../core/api_error.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final _service = FavoritesService();

  List<Product> items = [];
  final Set<String> _ids = {};
  bool loading = false;
  String? error;

  bool isFavorite(String productId) => _ids.contains(productId);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _service.getFavorites();
      _ids
        ..clear()
        ..addAll(items.map((p) => p.id));
    } catch (e) {
      error = friendlyError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Optimistic: the heart changes instantly, then rolls back if the
  /// request fails (and the error is rethrown for a SnackBar).
  Future<void> toggle(Product p) async {
    final wasFavorite = isFavorite(p.id);
    _apply(p, !wasFavorite);
    try {
      wasFavorite ? await _service.remove(p.id) : await _service.add(p.id);
    } catch (_) {
      _apply(p, wasFavorite);
      rethrow;
    }
  }

  void _apply(Product p, bool favorite) {
    if (favorite) {
      _ids.add(p.id);
      items.insert(0, p);
    } else {
      _ids.remove(p.id);
      items.removeWhere((x) => x.id == p.id);
    }
    notifyListeners();
  }

  void reset() {
    items = [];
    _ids.clear();
    error = null;
    notifyListeners();
  }
}
