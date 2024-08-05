import app/state/session.{type Session, type SessionManager}
import gleam/option.{type Option, None}

pub type Context {
  Context(
    static_dir: String,
    session: Option(Session),
    session_manager: SessionManager,
  )
}

pub fn new(static_dir: String) {
  Context(static_dir, None, session.init_manager())
}
