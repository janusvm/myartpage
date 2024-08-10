import app/model/context.{type Context, Context}
import app/model/user.{Login, Visitor}
import app/state/session
import gleam/option.{Some}
import wisp.{type Request, type Response}

pub const session_cookie_name = "myartpage.session"

pub const callback_url_cookie_name = "myartpage.callback_url"

pub const callback_url_cookie_timeout = 300

pub fn wrap_base(
  req: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) -> Response {
  use <- wisp.rescue_crashes()
  let req = wisp.method_override(req)
  use <- wisp.serve_static(
    req,
    under: "/static",
    from: ctx.priv_dir <> "/static",
  )
  use <- wisp.log_request(req)
  use req <- wisp.handle_head(req)
  use ctx <- wrap_session(req, ctx)

  handler(req, ctx)
}

pub fn wrap_session(
  req: Request,
  ctx: Context,
  handler: fn(Context) -> Response,
) -> Response {
  let session =
    wisp.get_cookie(req, session_cookie_name, wisp.Signed)
    |> session.get_or_create_session(ctx.session_manager)

  let ctx = Context(..ctx, session: Some(session))

  handler(ctx)
  |> wisp.set_cookie(
    req,
    session_cookie_name,
    session.serialize_session(session),
    wisp.Signed,
    ctx.config.session_timeout,
  )
}

pub fn require_admin_exists(
  req: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) -> Response {
  case user.admin_exists(ctx.db) {
    False -> wisp.redirect("/signup?level=admin")
    True -> handler(req, ctx)
  }
}

pub fn require_login(
  req: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) -> Response {
  let user =
    ctx.session
    |> option.map(session.get_user)
    |> option.unwrap(Visitor)

  case user {
    Visitor ->
      wisp.redirect("/login")
      |> wisp.set_cookie(
        req,
        callback_url_cookie_name,
        req.path,
        wisp.Signed,
        callback_url_cookie_timeout,
      )
    Login(..) -> handler(req, ctx)
  }
}
