/// Connection details from the instructor's Student API Guide.
class AppConfig {
  static const supabaseUrl = 'https://hbbrfjspweksdqpoplci.supabase.co';
  static const anonKey = 'sb_publishable_3QVoVl_xzWQf5hVkIy7_HQ_xXB_e7tH';

  /// Our group: GRP05 — Green Orchard Market. Sent on registration so new
  /// customers are attached to our vitrine.
  static const groupCode = 'GRP05';

  /// How often the order details screen re-checks the status.
  static const orderPollInterval = Duration(seconds: 15);
}
