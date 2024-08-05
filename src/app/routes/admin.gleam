import app/model/context.{type Context}
import gleam/string_builder
import wisp.{type Request, type Response}

pub fn admin_routes(
  path_segments: List(String),
  req: Request,
  _ctx: Context,
) -> Response {
  use _req <- auth_middleware(req)

  case path_segments {
    [] -> wisp.html_response(string_builder.from_string("Forbidden"), 403)
    ["dashboard"] ->
      wisp.html_response(string_builder.from_string("Dashboard"), 403)
    _ -> wisp.not_found()
  }
}

// FIXME: placeholder impl
fn auth_middleware(req: Request, handler: fn(Request) -> Response) {
  handler(req)
}
