import app/model/config
import app/state/session
import app/web
import gleam/erlang/process
import gleam/otp/supervisor
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  // TODO: fetch configuration from env or file
  let config = config.defaults

  let session_manager =
    supervisor.worker(fn(_) { session.init_manager() })
    |> supervisor.returning(fn(_, session_manager) { session_manager })

  let web_server =
    supervisor.worker(fn(session_manager) { web.init(session_manager, config) })

  let assert Ok(_) =
    supervisor.start(fn(children) {
      children
      |> supervisor.add(session_manager)
      |> supervisor.add(web_server)
    })

  process.sleep_forever()
}
