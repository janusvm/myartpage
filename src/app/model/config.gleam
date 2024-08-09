import feather

pub type AppConfig {
  AppConfig(secret_key_base: String, session_timeout: Int)
}

pub type DbConfig =
  feather.Config

pub fn app_defaults() -> AppConfig {
  AppConfig(secret_key_base: "myartpage-secret-key-base", session_timeout: 10)
}

pub fn db_defaults() -> DbConfig {
  // FIXME: dev config
  feather.Config(
    ..feather.default_config(),
    file: "./myartpage-database.db",
    journal_mode: feather.JournalOff,
    synchronous: feather.SyncOff,
    temp_store: feather.TempStoreMemory,
  )
}
