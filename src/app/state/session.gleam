import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/option.{type Option, None}
import gleam/otp/actor.{type Next}
import youid/uuid

pub const cookie_name = "session"

pub opaque type Session {
  Session(id: String, user_id: Option(String))
}

pub opaque type SessionManager {
  SessionManager(subject: Subject(Message))
}

type SessionStore =
  Dict(String, Session)

type Message {
  Get(session_id: String, reply_with: Subject(Result(Session, Nil)))
  Create(session: Session)
  Drop(session_id: String)
  Reset
}

pub fn get_or_new(json: String, session_manager: SessionManager) -> Session {
  let decoder =
    dynamic.decode2(
      Session,
      dynamic.field("id", dynamic.string),
      dynamic.optional_field("user_id", dynamic.string),
    )

  case json.decode(json, decoder) {
    Ok(parsed) -> get_or_create_session(parsed, session_manager)
    Error(_) -> create_session(session_manager)
  }
}

pub fn session_to_json(session: Session) -> String {
  case session {
    Session(id, user_id) -> {
      let user_id = option.unwrap(user_id, "")
      [#("id", json.string(id)), #("user_id", json.string(user_id))]
    }
  }
  |> json.object()
  |> json.to_string()
}

fn get_or_create_session(
  parsed_session: Session,
  session_manager: SessionManager,
) -> Session {
  case get_session(parsed_session.id, session_manager) {
    Ok(session) -> session
    Error(_) -> create_session(session_manager)
  }
}

pub fn init_manager() -> SessionManager {
  let assert Ok(subject) = actor.start(dict.new(), handle_message)
  SessionManager(subject)
}

pub fn get_session(
  session_id: String,
  session_manager: SessionManager,
) -> Result(Session, Nil) {
  actor.call(session_manager.subject, Get(session_id, _), 10)
}

pub fn create_session(session_manager: SessionManager) -> Session {
  let new_session = Session(uuid.v4_string(), None)
  actor.send(session_manager.subject, Create(new_session))
  new_session
}

fn handle_message(
  message: Message,
  sessions: SessionStore,
) -> Next(Message, SessionStore) {
  let new_state = case message {
    Get(session_id, subject) -> {
      let session = dict.get(sessions, session_id)
      actor.send(subject, session)
      sessions
    }
    Create(Session(id, _) as session) -> dict.insert(sessions, id, session)
    Drop(session_id) -> dict.delete(sessions, session_id)
    Reset -> dict.new()
  }

  actor.continue(new_state)
}
