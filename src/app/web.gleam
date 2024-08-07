import app/model/config.{type AppConfig}
import app/model/context.{type Context, Context}
import app/router
import app/state/session.{type SessionManager}
import gleam/dynamic
import gleam/erlang
import gleam/option.{None}
import gleam/otp/actor.{type StartError}
import gleam/result
import mist
import wisp

pub fn init(session_manager: SessionManager, config: AppConfig) {
  let ctx = Context(None, session_manager, get_priv_dir(), config)
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp.mist_handler(handler, config.secret_key_base)
    |> mist.new()
    |> mist.port(8080)
    |> mist.start_http()
    |> result.map_error(to_starterror)
}

fn to_starterror(glisten_error) -> StartError {
  actor.InitCrashed(dynamic.from(glisten_error))
}

fn get_priv_dir() -> String {
  let assert Ok(priv_dir) = erlang.priv_directory("myartpage")
  priv_dir
}
