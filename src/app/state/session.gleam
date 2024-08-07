import app/model/id.{type Id}
import app/model/user.{type User, Visitor}
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/option.{None, Some}
import gleam/otp/actor.{type Next}
import gleam/result

// FIXME: debug timeout value (seconds)
pub const timeout = 10

pub const cookie_name = "session"

pub opaque type Session {
  Session(id: Id(Session), user: User)
}

pub opaque type SessionManager {
  SessionManager(subject: Subject(Message))
}

type SessionStore =
  Dict(Id(Session), Session)

type Message {
  Get(session_id: Id(Session), reply_with: Subject(Result(Session, Nil)))
  Create(session: Session)
  Authenticate(session: Session, user: User)
  Drop(session_id: Id(Session))
  Reset
}

pub fn get_user(session: Session) -> User {
  session.user
}

pub fn serialize_session(session: Session) -> String {
  id.id_to_string(session.id)
}

pub fn get_or_create_session(
  session_cookie: Result(String, Nil),
  session_manager: SessionManager,
) -> Session {
  let session =
    session_cookie
    |> result.map(id.id_from_string)
    |> result.flatten()
    |> result.map(get_session(_, session_manager))
    |> result.flatten()

  case session {
    Ok(session) -> session
    Error(_) -> create_session(session_manager)
  }
}

pub fn init_manager() -> SessionManager {
  let assert Ok(subject) = actor.start(dict.new(), handle_message)
  SessionManager(subject)
}

pub fn get_session(
  session_id: Id(Session),
  session_manager: SessionManager,
) -> Result(Session, Nil) {
  actor.call(session_manager.subject, Get(session_id, _), 10)
}

pub fn create_session(session_manager: SessionManager) -> Session {
  let new_session = Session(id.new_id(), Visitor)
  actor.send(session_manager.subject, Create(new_session))
  new_session
}

pub fn authenticate_user(
  user: User,
  session: Session,
  session_manager: SessionManager,
) {
  actor.send(session_manager.subject, Authenticate(session, user))
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
    Authenticate(session, user) -> {
      let f = fn(x) {
        case x {
          Some(session) -> Session(..session, user: user)
          None -> Session(id.new_id(), user)
        }
      }
      dict.upsert(sessions, session.id, f)
    }
    Drop(session_id) -> dict.delete(sessions, session_id)
    Reset -> dict.new()
  }

  actor.continue(new_state)
}
