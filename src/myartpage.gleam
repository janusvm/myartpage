import app/database
import app/model/config
import app/model/user
import app/state/session
import app/web
import feather
import gleam/erlang/process
import gleam/io
import gleam/otp/supervisor
import logging
import wisp

const app_name = "myartpage"

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  // TODO: fetch configuration from env or file
  let app_config = config.app_defaults()
  let db_config = config.db_defaults()
  let assert Ok(priv_dir) = wisp.priv_directory(app_name)
  let assert Ok(_) =
    database.migrate_database(db_config, priv_dir <> database.migrations_subdir)

  use db <- feather.with_connection(db_config)

  let _ =
    user.create_user(db, "admin", "admin")
    |> io.debug()

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
}
