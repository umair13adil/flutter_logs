# WorkManager 2.8.x depends on Room 2.5.x, whose consumer rule (-keep class * extends RoomDatabase)
# no longer keeps the default constructor under AGP 9's R8 strict full mode
# (android.r8.strictFullModeForKeepRules), so WorkDatabase_Impl cannot be created at startup.
# Same rule Room 2.7.0 ships.
-keep class * extends androidx.room.RoomDatabase { void <init>(); }
