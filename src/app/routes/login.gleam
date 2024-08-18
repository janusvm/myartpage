import app/middleware
import app/model/context.{type Context, Context}
import app/model/user.{type LoginError, type User, IncorrectPassword, NoSuchUser}
import app/state/session
import app/utils/html_utils as utils
import app/views/components/forms
import formal/form.{type Form, Form}
import gleam/dict
import gleam/http.{Get, Post}
import gleam/list
import gleam/option.{Some}
import gleam/result
import wisp.{type Request, type Response}

pub fn login_routes(
  path_segments: List(String),
  req: Request,
  ctx: Context,
) -> Response {
  case path_segments {
    [] -> {
      case req.method {
        Get -> new_login_form()
        Post -> handle_form_submission(req, ctx)
        _ -> wisp.method_not_allowed([Get, Post])
      }
    }
    _ -> wisp.not_found()
  }
}

type LoginSubmission {
  LoginSubmission(username: String, password: String)
}

fn handle_form_submission(req: Request, ctx: Context) -> Response {
  use formdata <- wisp.require_form(req)
  case
    form.decoding({
      use username <- form.parameter
      use password <- form.parameter
      LoginSubmission(username, password)
    })
    |> form.with_values(formdata.values)
    |> form.field(
      "username",
      form.string
        |> form.and(form.must_not_be_empty),
    )
    |> form.field(
      "password",
      form.string
        |> form.and(form.must_not_be_empty),
    )
    |> form.finish()
    |> try_login(ctx)
  {
    Ok(_user) -> {
      let redirect_url = middleware.get_callback_url_cookie(req)
      wisp.redirect(redirect_url)
    }
    Error(formdata) -> {
      forms.login_form(formdata)
      |> utils.render_element(200)
    }
  }
}

fn new_login_form() -> Response {
  form.new()
  |> forms.login_form()
  |> list.wrap()
  |> utils.render_page(200)
}

fn try_login(
  submission: Result(LoginSubmission, Form),
  ctx: Context,
) -> Result(User, Form) {
  use data <- result.try(submission)
  use user <- result.try(
    user.get_login(ctx.db, data.username, data.password)
    |> result.map_error(to_form_error(_, data)),
  )
  let assert Some(session) = ctx.session
  session.authenticate_user(user, session, ctx.session_manager)

  Ok(user)
}

fn to_form_error(error: LoginError, submission: LoginSubmission) {
  let form =
    [#("username", submission.username), #("password", submission.password)]
    |> form.initial_values()

  let errors =
    case error {
      NoSuchUser(username) -> #(
        "username",
        "User '" <> username <> "' does not exist",
      )
      IncorrectPassword -> #("password", "Incorrect password")
    }
    |> list.wrap()
    |> dict.from_list()

  Form(..form, errors: errors)
}
