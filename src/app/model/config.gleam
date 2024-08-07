pub const defaults = AppConfig(
  secret_key_base: "myartpage-secret-key-base",
  session_timeout: 10,
)

pub type AppConfig {
  AppConfig(secret_key_base: String, session_timeout: Int)
}
