import app/utils/rng_utils as rng
import dot_env as dot
import dot_env/env
import gleam/option
import gleam/pgo
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
  pgo.Config

fn get_or_panic(key: String, getter: fn(String) -> Result(a, String)) -> a {
  let result = getter(key)
  case result {
    Ok(value) -> {
      wisp.log_info(
        "Succesfully read config variable `" <> key <> "` from environment",
      )
      value
    }
    Error(_) -> {
      panic as {
        "Environment variable "
        <> key
        <> " is missing or invalid, cannot start app"
      }
    }
  }
}

pub fn get_db_config() -> DbConfig {
  dot.load_default()

  let db_port = get_or_panic("DB_PORT", env.get_int)
  let db_host = get_or_panic("DB_HOST", env.get_string)
  let db_user = get_or_panic("DB_USER", env.get_string)
  let db_pass = get_or_panic("DB_PASS", env.get_string)
  let db_name = get_or_panic("DB_NAME", env.get_string)

  pgo.Config(
    ..pgo.default_config(),
    host: db_host,
    port: db_port,
    database: db_name,
    user: db_user,
    password: option.Some(db_pass),
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
/// - `ADMIN_OTP`: one-time password used for registering the admin account (default: generated and displayed in log)
///
pub fn get_env_config() -> AppConfig {
  dot.load_default()

  let port =
    env.get_int("PORT")
    |> result.unwrap(3000)

  let secret_key_base = case env.get_string("SECRET_KEY_BASE") {
    Ok(key) -> key
    Error(_) -> {
      wisp.log_warning(
        "No value found for SECRET_KEY_BASE, using a generated one. All sessions will be invalidated if the server is restarted.",
      )
      rng.random_alphanumerics(64)
    }
  }

  let session_timeout =
    env.get_int("SESSION_TIMEOUT")
    |> result.unwrap(31_536_000)

  let sqlite_uri =
    env.get_string("SQLITE_URI")
    |> result.unwrap("file:./myartpage-database.db?cache=shared")

  let admin_otp = case env.get_string("ADMIN_OTP") {
    Ok(otp) -> otp
    Error(_) -> {
      let otp = rng.random_numerics(6)
      wisp.log_warning(
        "No value found for ADMIN_OTP, using a generated one: " <> otp,
      )
      otp
    }
  }

  AppConfig(port:, secret_key_base:, session_timeout:, sqlite_uri:, admin_otp:)
}
