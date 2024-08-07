import app/model/config.{type AppConfig}
import app/state/session.{type Session, type SessionManager}
import gleam/option.{type Option}

pub type Context {
  Context(
    session: Option(Session),
    session_manager: SessionManager,
    priv_dir: String,
    config: AppConfig,
  )
}
