import app/routes/admin
import app/state/context.{type Context}
import app/views/home
import app/web
import wisp.{type Request}

pub fn handle_request(req: Request, ctx: Context) {
  use req, ctx <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> [home.home()] |> web.response()

    ["admin", ..rest] -> admin.admin_routes(rest, req, ctx)
    ["login", ..] -> wisp.ok()

    ["art", ..] -> wisp.not_found()
    ["blog", ..] -> wisp.not_found()
    ["comics", ..] -> wisp.not_found()
    ["links", ..] -> wisp.not_found()

    _ -> wisp.not_found()
  }
}
