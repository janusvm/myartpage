import app/state/context.{type Context, Context}
import app/state/session
import app/views/layout
import gleam/option.{Some}
import lustre/element.{type Element}
import wisp.{type Request, type Response}

pub fn middleware(
  req: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) -> Response {
  use <- wisp.rescue_crashes()
  let req = wisp.method_override(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_dir)
  use <- wisp.log_request(req)
  use req <- wisp.handle_head(req)
  use ctx <- set_session(req, ctx)

  handler(req, ctx)
}

pub fn response(elements: List(Element(t))) -> Response {
  elements
  |> layout.layout()
  |> element.to_document_string_builder()
  |> wisp.html_response(200)
}

fn set_session(
  req: Request,
  ctx: Context,
  handler: fn(Context) -> Response,
) -> Response {
  let session =
    wisp.get_cookie(req, session.cookie_name, wisp.Signed)
    |> session.get_or_create_session(ctx.session_manager)

  let ctx = Context(..ctx, session: Some(session))

  handler(ctx)
  |> wisp.set_cookie(
    req,
    session.cookie_name,
    session.serialize_session(session),
    wisp.Signed,
    session.timeout,
  )
}
