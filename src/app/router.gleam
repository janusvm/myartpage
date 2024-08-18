import app/middleware
import app/model/context.{type Context}
import app/routes/admin
import app/routes/login
import app/routes/signup
import app/utils/html_utils as html
import app/views/home
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req, ctx <- middleware.wrap_base(req, ctx)

  case wisp.path_segments(req) {
    [] -> [home.home(ctx)] |> html.render_page(200)
    ["login", ..rest] -> login.login_routes(rest, req, ctx)
    ["signup", ..rest] -> signup.signup_routes(rest, req, ctx)

    ["admin", ..rest] -> admin.admin_routes(rest, req, ctx)

    ["art", ..] -> wisp.not_found()
    ["blog", ..] -> wisp.not_found()
    ["comics", ..] -> wisp.not_found()
    ["links", ..] -> wisp.not_found()

    _ -> wisp.not_found()
  }
}
