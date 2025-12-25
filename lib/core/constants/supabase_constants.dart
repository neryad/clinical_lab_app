class SupabaseConstants {
  // TODO: Replace with your actual Supabase URL and Anon Key
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dzwvrgnxwcfwhinqzwlc.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6d3ZyZ254d2Nmd2hpbnF6d2xjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMDcyMTUsImV4cCI6MjA3OTY4MzIxNX0.bQlskVaTvHgIgPmk0he8_IeO41INJQ_-qpQOSrJjVPM',
  );
}
