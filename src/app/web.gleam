import app/model/config.{type AppConfig}
import app/model/context.{type Context, Context}
import app/router
import app/state/session.{type SessionManager}
import gleam/dynamic
import gleam/option.{None}
import gleam/otp/actor.{type StartError}
import gleam/result
import mist
import sqlight.{type Connection}
import wisp

pub fn init(
  session_manager: SessionManager,
  db: Connection,
  priv_dir: String,
  config: AppConfig,
) {
  let ctx = Context(None, session_manager, db, priv_dir, config)
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp.mist_handler(handler, config.secret_key_base)
    |> mist.new()
    |> mist.port(config.port)
    |> mist.start_http()
    |> result.map_error(to_starterror)
}

fn to_starterror(glisten_error) -> StartError {
  actor.InitCrashed(dynamic.from(glisten_error))
}
