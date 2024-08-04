import app/views/home
import app/web.{type Context}
import wisp.{type Request}

pub fn handle_request(req: Request, ctx: Context) {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> [home.home()] |> web.response()

    _ -> wisp.not_found()
  }
}
