import app/middleware
import app/model/context.{type Context, Context}
import gleam/string_builder
import wisp.{type Request, type Response}

pub fn admin_routes(
  path_segments: List(String),
  req: Request,
  ctx: Context,
) -> Response {
  use _req, _ctx <- middleware.require_login(req, ctx)

  case path_segments {
    [] -> wisp.html_response(string_builder.from_string("Admin"), 200)
    ["dashboard"] ->
      wisp.html_response(string_builder.from_string("Dashboard"), 200)
    _ -> wisp.not_found()
  }
}
