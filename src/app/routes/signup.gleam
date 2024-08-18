import app/model/context.{type Context, Context}
import app/model/user.{Admin}
import app/state/session
import app/utils/html_utils as utils
import app/views/components/forms
import formal/form.{type Form, Form}
import gleam/bool
import gleam/dict
import gleam/http.{Get, Post}
import gleam/list
import gleam/option.{Some}
import gleam/result
import wisp.{type Request, type Response}

pub fn signup_routes(
  _path_segments: List(String),
  req: Request,
  ctx: Context,
) -> Response {
  case req.method {
    Get -> new_signup_form()
    Post -> handle_form_submission(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn new_signup_form() {
  form.new()
  |> forms.signup_form()
  |> list.wrap()
  |> utils.render_page(200)
}

type SignupSubmission {
  SignupSubmission(
    username: String,
    password: String,
    confirm: String,
    otp: String,
  )
}

fn handle_form_submission(req: Request, ctx: Context) -> Response {
  use formdata <- wisp.require_form(req)
  case
    form.decoding({
      use username <- form.parameter
      use password <- form.parameter
      use confirm <- form.parameter
      use otp <- form.parameter
      SignupSubmission(username:, password:, confirm:, otp:)
    })
    |> form.with_values(formdata.values)
    |> form.field(
      "username",
      form.string
        |> form.and(form.must_not_be_empty)
        |> form.and(form.must_be_string_longer_than(4)),
    )
    |> form.field(
      "new-password",
      form.string
        |> form.and(form.must_not_be_empty)
        |> form.and(form.must_be_string_longer_than(4)),
    )
    |> form.field("confirm-password", form.string)
    |> form.field(
      "signup-otp",
      form.string
        |> form.and(form.must_equal(
          ctx.config.admin_otp,
          "Must match the configured admin OTP",
        )),
    )
    |> form.finish()
    |> post_validate_submission()
  {
    Ok(submission) -> {
      let _ = do_signup(submission, ctx)
      wisp.redirect("/login")
    }
    Error(form) -> {
      forms.signup_form(form)
      |> utils.render_element(200)
    }
  }
}

fn do_signup(submission data: SignupSubmission, ctx ctx: Context) {
  use new_user <- result.try(user.create_user(
    ctx.db,
    Admin,
    data.username,
    data.password,
  ))
  let assert Some(session) = ctx.session
  Ok(session.authenticate_user(new_user, session, ctx.session_manager))
}

fn post_validate_submission(
  submission: Result(SignupSubmission, Form),
) -> Result(SignupSubmission, Form) {
  use data <- result.try(submission)
  use <- bool.guard(
    data.password != data.confirm,
    make_form_error(data, #(
      "confirm-password",
      "Must match the selected password",
    )),
  )
  submission
}

fn make_form_error(
  submission data: SignupSubmission,
  error error: #(String, String),
) {
  let form =
    [
      #("username", data.username),
      #("new-password", data.password),
      #("confirm-password", data.confirm),
      #("signup-otp", data.otp),
    ]
    |> form.initial_values()
  Form(..form, errors: dict.from_list([error]))
  |> Error()
}
