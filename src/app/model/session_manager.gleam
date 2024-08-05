import app/model/session.{type Session}
import gleam/dict.{type Dict}

pub type SessionManager {
  SessionManager(session: Dict(String, Session))
}
