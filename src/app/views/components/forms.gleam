import app/views/components/button
import formal/form.{type Form}
import gleam/dict
import gleam/option.{None}
import gleam/result
import gleam/string
import lustre/attribute.{type Attribute} as a
import lustre/element.{type Element} as e
import lustre/element/html as h
import lustre_hx as hx

pub fn labelled_input_field(
  form: Form,
  input_text: String,
  input_id: String,
  input_type: String,
  input_attrs: List(Attribute(a)),
  input_classes: List(String),
  label_classes: List(String),
) -> Element(a) {
  let label_class =
    [
      "block",
      "text-sm",
      "font-medium",
      "leading-6",
      "text-gray-900",
      ..label_classes
    ]
    |> string.join(" ")

  let input_class =
    [
      "block",
      "w-full",
      "rounded-md",
      "border-0",
      "py-1.5",
      "text-gray-900",
      "shadow-sm",
      "ring-1",
      "ring-inset",
      "ring-gray-300",
      "placeholder:text-gray-400",
      "focus:ring-2",
      "focus:ring-inset",
      "focus:ring-pink-600",
      "sm:text-sm",
      "sm:leading-6",
      ..input_classes
    ]
    |> string.join(" ")

  let error_element = case form.field_state(form, input_id) {
    Ok(_) -> e.none()
    Error(message) ->
      h.div([a.class("error text-red-500 sm:text-sm")], [e.text(message)])
  }
  let has_error = result.is_error(form.field_state(form, input_id))

  h.div([], [
    h.label([a.for(input_id), a.class(label_class)], [e.text(input_text)]),
    error_element,
    h.div([a.class("mt-2")], [
      h.input([
        a.id(input_id),
        a.name(input_id),
        a.type_(input_type),
        a.class(input_class),
        a.value(form.value(form, input_id)),
        a.autofocus(has_error),
        ..input_attrs
      ]),
    ]),
  ])
}

pub fn username_field(form: Form) {
  let no_error = dict.is_empty(form.errors)
  labelled_input_field(
    form,
    "Username",
    "username",
    "text",
    [
      a.placeholder("Enter username"),
      a.autocomplete("username"),
      a.autofocus(no_error),
      a.required(True),
    ],
    [],
    [],
  )
}

pub fn password_field(form: Form) {
  labelled_input_field(
    form,
    "Password",
    "password",
    "password",
    [
      a.placeholder("Enter password"),
      a.autocomplete("current-password"),
      a.required(True),
    ],
    [],
    [],
  )
}

pub fn login_form(form: Form) -> Element(a) {
  h.div(
    [
      a.id("login-view"),
      a.class("flex min-h-full flex-col justify-center px-6 py-12 lg:px-8"),
    ],
    [
      h.div([a.class("sm:mx-auto sm:w-full sm:max-w-sm")], [
        h.h2(
          [
            a.class(
              "mt-10 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900",
            ),
          ],
          [e.text("Sign into your account")],
        ),
      ]),
      h.div([a.class("mt-10 sm:mx-auto sm:w-full sm:max-w-sm")], [
        h.form(
          [
            hx.post("/login"),
            hx.swap(hx.OuterHTML, None),
            hx.target(hx.CssSelector("#login-view")),
            a.class("space-y-6"),
            a.action("/login"),
            a.method("post"),
          ],
          [
            username_field(form),
            password_field(form),
            h.div([], [button.submit_button("Sign in", [])]),
          ],
        ),
        h.p([a.class("mt-10 text-center text-sm text-gray-500")], [
          e.text("Not a member? "),
          h.a(
            [
              a.href("/signup"),
              a.class(
                "font-semibold leading-6 text-pink-600 hover:text-pink-500",
              ),
            ],
            [e.text("Create new user")],
          ),
        ]),
      ]),
    ],
  )
}

pub fn signup_form(form: Form) -> Element(a) {
  let no_error = dict.is_empty(form.errors)
  h.div(
    [
      a.id("signup-view"),
      a.class("flex min-h-full flex-col justify-center px-6 py-12 lg:px-8"),
    ],
    [
      h.div([a.class("sm:mx-auto sm:w-full sm:max-w-sm")], [
        h.h2(
          [
            a.class(
              "mt-10 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900",
            ),
          ],
          [e.text("Create admin account")],
        ),
      ]),
      h.div([a.class("mt-10 sm:mx-auto sm:w-full sm:max-w-sm")], [
        h.form(
          [
            hx.post("/signup"),
            hx.swap(hx.OuterHTML, None),
            hx.target(hx.CssSelector("#signup-view")),
            a.class("space-y-6"),
            a.action("/signup"),
            a.method("post"),
          ],
          [
            labelled_input_field(
              form,
              "Username",
              "username",
              "text",
              [
                a.autocomplete("username"),
                a.required(True),
                a.autofocus(no_error),
              ],
              [],
              [],
            ),
            labelled_input_field(
              form,
              "Choose password",
              "new-password",
              "password",
              [a.autocomplete("new-password"), a.required(True)],
              [],
              [],
            ),
            labelled_input_field(
              form,
              "Confirm password",
              "confirm-password",
              "password",
              [a.autocomplete("new-password"), a.required(True)],
              [],
              [],
            ),
            labelled_input_field(
              form,
              "One-time setup code",
              "signup-otp",
              "text",
              [a.autocomplete("one-time-code"), a.required(True)],
              [],
              [],
            ),
            h.div([], [button.submit_button("Create account", [])]),
          ],
        ),
      ]),
    ],
  )
}
