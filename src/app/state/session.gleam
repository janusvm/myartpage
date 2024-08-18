import app/model/id.{type Uid}
import app/model/user.{type User, Visitor}
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/option.{None, Some}
import gleam/otp/actor.{type Next, type StartError}
import gleam/result

pub type SessionId =
  Uid(Session)

pub type Session {
  Session(id: SessionId, user: User)
}

pub type SessionManager =
  Subject(SessionMsg)

pub type SessionMsg {
  Get(session_id: SessionId, reply_with: Subject(Result(Session, Nil)))
  Create(session: Session)
  Authenticate(session: Session, user: User)
  Drop(session_id: SessionId)
  Reset
}

type SessionStore =
  Dict(Uid(Session), Session)

pub fn serialize_session(session: Session) -> String {
  id.uid_to_string(session.id)
}

pub fn get_or_create_session(
  session_cookie: Result(String, Nil),
  session_manager: SessionManager,
) -> Session {
  let session =
    session_cookie
    |> result.then(id.parse_uid)
    |> result.then(get_session(_, session_manager))

  case session {
    Ok(session) -> session
    Error(_) -> create_session(session_manager)
  }
}

pub fn init_manager() -> Result(SessionManager, StartError) {
  actor.start(dict.new(), handle_message)
}

pub fn get_session(
  session_id: SessionId,
  session_manager: SessionManager,
) -> Result(Session, Nil) {
  actor.call(session_manager, Get(session_id, _), 10)
}

pub fn create_session(session_manager: SessionManager) -> Session {
  let new_session = Session(id.new_uid(), Visitor)
  actor.send(session_manager, Create(new_session))
  new_session
}

pub fn authenticate_user(
  user: User,
  session: Session,
  session_manager: SessionManager,
) {
  actor.send(session_manager, Authenticate(session, user))
}

fn handle_message(
  message: SessionMsg,
  sessions: SessionStore,
) -> Next(SessionMsg, SessionStore) {
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
          None -> Session(id.new_uid(), user)
        }
      }
      dict.upsert(sessions, session.id, f)
    }
    Drop(session_id) -> dict.delete(sessions, session_id)
    Reset -> dict.new()
  }

  actor.continue(new_state)
}
