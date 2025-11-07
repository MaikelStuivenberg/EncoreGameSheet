import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static const String supabaseUrl = 'https://bjwyuuzqhdjiwcgpsshg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqd3l1dXpxaGRqaXdjZ3Bzc2hnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyOTI2ODEsImV4cCI6MjA2MTg2ODY4MX0.BGVRPN391bIS4F4GqjgOGSqjRdXq83rQPv8IVVurd3o';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
