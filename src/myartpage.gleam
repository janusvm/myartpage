import app/router
import app/state/context
import gleam/erlang/process
import mist
import wisp

pub fn main() {
  wisp.configure_logger()

  // TODO: Get key from configuration
  let secret_key_base = wisp.random_string(64)
  let ctx = context.new(get_static_directory())
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp.mist_handler(handler, secret_key_base)
    |> mist.new()
    |> mist.port(8080)
    |> mist.start_http()

  process.sleep_forever()
}

fn get_static_directory() {
  let assert Ok(priv_dir) = wisp.priv_directory("myartpage")
  priv_dir <> "/static"
}
