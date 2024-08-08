import app/model/config.{type AppConfig}
import app/state/session.{type Session, type SessionManager}
import gleam/option.{type Option}
import sqlight.{type Connection}

pub type Context {
  Context(
    session: Option(Session),
    session_manager: SessionManager,
    db: Connection,
    priv_dir: String,
    config: AppConfig,
  )
}
