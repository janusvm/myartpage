import app/database
import app/model/config
import app/state/session
import app/web
import gleam/erlang/process
import gleam/otp/supervisor
import gleam/pgo
import logging
import wisp

const app_name = "myartpage"

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let assert Ok(priv_dir) = wisp.priv_directory(app_name)
  let app_config = config.get_env_config()
  let db_config = config.get_db_config()
  let db = pgo.connect(db_config)
  let assert Ok(_) = database.migrate_database(db, priv_dir)

  let session_manager =
    supervisor.worker(fn(_) { session.init_manager() })
    |> supervisor.returning(fn(_, session_manager) { session_manager })

  let web_server = supervisor.worker(web.init(_, db, priv_dir, app_config))

  let assert Ok(_) =
    supervisor.start(fn(children) {
      children
      |> supervisor.add(session_manager)
      |> supervisor.add(web_server)
    })

  process.sleep_forever()
  Ok(Nil)
}
