import app/model/context.{type Context, Context}
import app/model/session
import app/views/layout
import gleam/io
import gleam/result
import lustre/element.{type Element}
import wisp.{type Request, type Response}

pub fn middleware(
  req: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_dir)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes()
  use req <- wisp.handle_head(req)
  use ctx <- session_middleware(req, ctx)

  handler(req, ctx)
}

pub fn response(elements: List(Element(t))) -> Response {
  elements
  |> layout.layout()
  |> element.to_document_string_builder()
  |> wisp.html_response(200)
}

fn session_middleware(
  req: Request,
  ctx: Context,
  handler: fn(Context) -> Response,
) -> Response {
  let session =
    wisp.get_cookie(req, session.cookie_name, wisp.Signed)
    |> result.unwrap("{}")
    |> session.decode()

  let new_session = case session {
    Ok(s) -> s
    Error(_) -> session.new()
  }

  let ctx =
    Context(..ctx, session: new_session)
    |> io.debug()

  handler(ctx)
  |> wisp.set_cookie(
    req,
    session.cookie_name,
    session.session_to_json(new_session),
    wisp.Signed,
    60 * 60 * 24,
  )
}
