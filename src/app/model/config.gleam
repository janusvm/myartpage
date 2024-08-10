import dot_env as dot
import dot_env/env
import feather
import gleam/result
import wisp

pub type AppConfig {
  AppConfig(
    port: Int,
    secret_key_base: String,
    session_timeout: Int,
    sqlite_uri: String,
    admin_otp: String,
  )
}

pub type DbConfig =
  feather.Config

pub fn get_db_config(app_config: AppConfig) {
  feather.Config(
    ..feather.default_config(),
    file: app_config.sqlite_uri,
    // TODO: temporary dev options, remove
    journal_mode: feather.JournalOff,
    synchronous: feather.SyncOff,
    temp_store: feather.TempStoreMemory,
  )
}

/// Retrieve the app configuration from environment variables or .env file.
///
/// The following options (and their defaults if not set) are available:
///
/// - `PORT`: the port on which to serve the web app (default: 3000)
/// - `SECRET_KEY_BASE`: the key used to sign cookies (default: randomly generated at startup, which invalidates all cookies every restart)
/// - `SESSION_TIMEOUT`: the time in seconds that session cookies are valid for (default: a year)
/// - `SQLITE_URI`: filename with options for SQLite (default: "file:./myartpage-database.db?cache=shared")
///
pub fn get_env_config() -> AppConfig {
  dot.load_default()

  let port =
    env.get_int("PORT")
    |> result.unwrap(3000)

  let secret_key_base =
    env.get_string("SECRET_KEY_BASE")
    |> result.unwrap(wisp.random_string(64))

  let session_timeout =
    env.get_int("SESSION_TIMEOUT")
    |> result.unwrap(31_536_000)

  let sqlite_uri =
    env.get_string("SQLITE_URI")
    |> result.unwrap("file:./myartpage-database.db?cache=shared")

  let admin_otp = case env.get_string("ADMIN_OTP") {
    Ok(otp) -> otp
    Error(_) -> {
      let otp = wisp.random_string(8)
      wisp.log_warning(
        "No value found for ADMIN_OTP, using a generated one: " <> otp,
      )
      otp
    }
  }

  AppConfig(port:, secret_key_base:, session_timeout:, sqlite_uri:, admin_otp:)
}
