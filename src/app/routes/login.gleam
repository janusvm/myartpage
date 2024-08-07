import app/model/id
import app/model/user.{Login}
import app/state/context.{type Context, Context}
import app/state/session
import app/views/login
import app/web
import gleam/http.{Get, Post}
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string_builder
import wisp.{type Request, type Response}

// FIXME: replace hardcoded test user with real user store
const test_user = #("admin", "admin")

pub fn login_routes(
  path_segments: List(String),
  req: Request,
  ctx: Context,
) -> Response {
  case path_segments {
    [] -> {
      case req.method {
        Get -> [login.login_view()] |> web.response()

        Post -> attempt_login(req, ctx)

        _ -> wisp.method_not_allowed([Get, Post])
      }
    }
    _ -> wisp.not_found()
  }
}

fn attempt_login(req: Request, ctx: Context) -> Response {
  use formdata <- wisp.require_form(req)

  let parsed = {
    use username <- result.try(list.key_find(formdata.values, "username"))
    use password <- result.try(list.key_find(formdata.values, "password"))
    Ok(#(username, password))
  }

  case parsed {
    Error(_) -> wisp.bad_request()
    Ok(user) -> {
      case user == test_user {
        True -> {
          let assert Some(session) = ctx.session
          let user = Login(id.new_id(), user.1)
          let redirect_url =
            wisp.get_cookie(req, "myartpage_callback", wisp.PlainText)
            |> result.unwrap("/")

          session.authenticate_user(user, session, ctx.session_manager)
          wisp.redirect(redirect_url)
        }
        False ->
          string_builder.from_string("Incorrect username/password!")
          |> wisp.html_response(401)
      }
    }
  }
}
