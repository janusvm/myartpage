import app/utils/rng_utils as rng
import dot_env/env
import gleam/function
import gleam/int
import gleam/option
import gleam/pgo
import wisp

pub type AppConfig {
  AppConfig(
    port: Int,
    secret_key_base: String,
    session_timeout: Int,
    admin_otp: String,
  )
}

pub type DbConfig =
  pgo.Config

/// Retrieve the database configuration from environment variables or .env file.
///
/// The following options must be present, or the function panics:
///
/// - `DB_PORT`: the port on which the Postgres database is served
/// - `DB_HOST`: the database host address
/// - `DB_USER`: the username used for accessing the database
/// - `DB_PASS`: the password used for accessing the database
/// - `DB_NAME`: the name of the database to connect to
///
pub fn get_db_config() -> DbConfig {
  let config = {
    use db_port <- get_or_error("DB_PORT", env.get_int, int.to_string)
    use db_host <- get_or_error("DB_HOST", env.get_string, function.identity)
    use db_user <- get_or_error("DB_USER", env.get_string, function.identity)
    use db_pass <- get_or_error("DB_PASS", env.get_string, function.identity)
    use db_name <- get_or_error("DB_NAME", env.get_string, function.identity)

    Ok(
      pgo.Config(
        ..pgo.default_config(),
        host: db_host,
        port: db_port,
        database: db_name,
        user: db_user,
        password: option.Some(db_pass),
      ),
    )
  }

  case config {
    Ok(config) -> config
    Error(_) -> panic as "Unable to load database configuration, aborting"
  }
}

fn get_or_error(
  key: String,
  getter: fn(String) -> Result(a, String),
  serializer: fn(a) -> String,
  apply: fn(a) -> Result(b, Nil),
) -> Result(b, Nil) {
  let result = getter(key)
  case result {
    Ok(value) -> {
      wisp.log_info(
        "Read database config option " <> key <> "=" <> serializer(value),
      )
      apply(value)
    }
    Error(_) -> {
      wisp.log_error(
        "Required config option "
        <> key
        <> " is missing or invalid. Check your environment variable setup.",
      )
      Error(Nil)
    }
  }
}

/// Retrieve the app configuration from environment variables or .env file.
///
/// The following options (and their defaults if not set) are available:
///
/// - `PORT`: the port on which to serve the web app (default: 3000)
/// - `SECRET_KEY_BASE`: the key used to sign cookies (default: randomly generated at startup, which invalidates all cookies every restart)
/// - `SESSION_TIMEOUT`: the time in seconds that session cookies are valid for (default: a year)
/// - `ADMIN_OTP`: one-time password used for registering the admin account (default: generated and displayed in log)
///
pub fn get_env_config() -> AppConfig {
  // Hardcoded as Dockerfile depends on it
  let port = 3000

  let secret_key_base =
    get_or_default(
      "SECRET_KEY_BASE",
      rng.random_alphanumerics(64),
      env.get_string,
      function.identity,
    )

  let session_timeout =
    get_or_default(
      "SESSION_TIMEOUT",
      60 * 60 * 24 * 365,
      env.get_int,
      int.to_string,
    )

  let admin_otp =
    get_or_default(
      "ADMIN_OTP",
      rng.random_numerics(6),
      env.get_string,
      function.identity,
    )

  AppConfig(port:, secret_key_base:, session_timeout:, admin_otp:)
}

fn get_or_default(
  key: String,
  default: a,
  getter: fn(String) -> Result(a, String),
  serializer: fn(a) -> String,
) -> a {
  let result = getter(key)
  case result {
    Ok(value) -> {
      wisp.log_info(
        "Read environment variable " <> key <> "=" <> serializer(value),
      )
      value
    }
    Error(_) -> {
      wisp.log_warning(
        "Optional config option "
        <> key
        <> " is missing or invalid, using default value: "
        <> serializer(default),
      )
      default
    }
  }
}
