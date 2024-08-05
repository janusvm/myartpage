import gleam/dynamic
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import wisp

pub const cookie_name = "session"

pub type Session {
  Session(id: Option(String), user_id: Option(String))
}

pub fn new() -> Session {
  Session(Some(wisp.random_string(32)), None)
}

type SessionJson {
  SessionJson(id: String, user_id: String)
}

pub fn decode(json: String) -> Result(Session, json.DecodeError) {
  let decoder =
    dynamic.decode2(
      SessionJson,
      dynamic.field("id", dynamic.string),
      dynamic.field("user_id", dynamic.string),
    )

  json.decode(json, decoder)
  |> result.map(get_or_create_session)
}

pub fn session_to_json(session: Session) -> String {
  let id = option.unwrap(session.id, "")
  let user_id = option.unwrap(session.user_id, "")

  json.object([#("id", json.string(id)), #("user_id", json.string(user_id))])
  |> json.to_string()
}

fn get_or_create_session(parsed_session: SessionJson) {
  let SessionJson(id, user_id) = parsed_session
  Session(string.to_option(id), string.to_option(user_id))
}
