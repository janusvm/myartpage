import app/middleware
import app/model/context.{type Context, Context}
import app/model/user.{type UserLevel, Admin}
import app/state/session
import app/utils/html_utils as utils
import app/views/components/form
import gleam/bool
import gleam/http.{Get, Post}
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string_builder
import wisp.{type Request, type Response}

pub fn signup_routes(
  _path_segments: List(String),
  req: Request,
  ctx: Context,
) -> Response {
  case req.method {
    Get -> [form.signup_form()] |> utils.response()
    Post -> attempt_signup(Admin, req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn attempt_signup(level: UserLevel, req: Request, ctx: Context) -> Response {
  use formdata <- wisp.require_form(req)

  let parsed = {
    use username <- result.try(list.key_find(formdata.values, "username"))
    use new_password <- result.try(list.key_find(
      formdata.values,
      "new-password",
    ))
    use confirm_password <- result.try(list.key_find(
      formdata.values,
      "confirm-password",
    ))
    use otp <- result.try(list.key_find(formdata.values, "signup-otp"))
    use <- bool.guard(new_password != confirm_password, Error(Nil))
    use <- bool.guard(otp != ctx.config.admin_otp, Error(Nil))
    Ok(#(username, new_password))
  }

  {
    use #(username, password) <- result.try(parsed)
    use new_user <- result.try(user.create_user(
      ctx.db,
      level,
      username,
      password,
    ))
    let assert Some(session) = ctx.session
    session.authenticate_user(new_user, session, ctx.session_manager)
    Ok(middleware.get_callback_url_cookie(req))
  }
  |> result.map(wisp.redirect)
  |> result.unwrap(wisp.html_response(
    string_builder.from_string("Error during signup"),
    400,
  ))
}
