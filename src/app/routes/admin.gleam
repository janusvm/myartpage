import app/model/user.{Login, Visitor}
import app/state/context.{type Context, Context}
import app/state/session
import gleam/option
import gleam/string_builder
import wisp.{type Request, type Response}

pub fn admin_routes(
  path_segments: List(String),
  req: Request,
  ctx: Context,
) -> Response {
  use _req, _ctx <- require_login(req, ctx)

  case path_segments {
    [] -> wisp.html_response(string_builder.from_string("Admin"), 200)
    ["dashboard"] ->
      wisp.html_response(string_builder.from_string("Dashboard"), 200)
    _ -> wisp.not_found()
  }
}

fn require_login(
  req: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) {
  let user =
    ctx.session
    |> option.map(session.get_user)
    |> option.unwrap(Visitor)

  case user {
    Visitor ->
      wisp.redirect("/login")
      |> wisp.set_cookie(
        req,
        "myartpage_callback",
        req.path,
        wisp.PlainText,
        60 * 10,
      )
    Login(_, _) -> handler(req, ctx)
  }
}
