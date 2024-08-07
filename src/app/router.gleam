import app/routes/admin
import app/routes/login
import app/state/context.{type Context}
import app/views/home
import app/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req, ctx <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> [home.home(ctx)] |> web.response()
    ["login", ..rest] -> login.login_routes(rest, req, ctx)

    ["admin", ..rest] -> admin.admin_routes(rest, req, ctx)

    ["art", ..] -> wisp.not_found()
    ["blog", ..] -> wisp.not_found()
    ["comics", ..] -> wisp.not_found()
    ["links", ..] -> wisp.not_found()

    _ -> wisp.not_found()
  }
}
