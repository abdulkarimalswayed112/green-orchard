import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns any API / network error into a message we can show the user.
/// Mirrors the "Error Handling Reference Table" in the API guide.
String friendlyError(Object e) {
  if (isNetworkError(e)) {
    return 'No internet connection. Check your network and try again.';
  }

  if (e is AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return 'Wrong email or password.';
    if (m.contains('already registered')) return 'This email is already registered.';
    if (m.contains('email not confirmed')) return 'Please confirm your email first.';
    if (m.contains('password')) return e.message;
    return e.message;
  }

  if (e is PostgrestException) {
    final m = e.message;
    if (m.contains('CART_EMPTY')) {
      return 'Your cart is empty. Add items before placing an order.';
    }
    if (m.contains('PRODUCT_UNAVAILABLE')) {
      return 'One or more items in your cart is out of stock.';
    }
    if (m.contains('JWT')) return 'Your session expired. Please log in again.';
    if (e.code == '42501' || m.toLowerCase().contains('permission')) {
      return 'You do not have permission to perform this action.';
    }
    return m;
  }

  return 'Something went wrong. Please try again.';
}

bool isNetworkError(Object e) {
  final raw = e.toString();
  return e is SocketException ||
      e is TimeoutException ||
      raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('ClientException') ||
      raw.contains('Connection refused');
}

/// 401 / expired token → the UI should send the user back to Login.
bool isSessionExpired(Object e) =>
    (e is PostgrestException && e.message.contains('JWT')) ||
    (e is AuthException && e.statusCode == '401');
