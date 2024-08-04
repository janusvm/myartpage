import app/views/layout
import lustre/element.{type Element}
import wisp.{type Request, type Response}

pub type Context {
  Context(static_dir: String)
}

pub fn middleware(
  req: Request,
  ctx: Context,
  handler: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_dir)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes()
  use req <- wisp.handle_head(req)

  handler(req)
}

pub fn response(elements: List(Element(t))) -> Response {
  elements
  |> layout.layout()
  |> element.to_document_string_builder()
  |> wisp.html_response(200)
}
