import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre_hx as hx

pub fn signup_view() -> Element(t) {
  h.form([hx.boost(True), a.method("post"), a.action("/signup")], [
    h.div([], [
      h.label([a.for("username")], [text("User name")]),
      h.div([], [
        h.input([
          a.type_("text"),
          a.id("username"),
          a.name("username"),
          a.placeholder("Enter user name"),
          a.autocomplete("username"),
          a.autofocus(True),
        ]),
      ]),
    ]),
    h.div([], [
      h.label([a.for("new-password")], [text("Password")]),
      h.div([], [
        h.input([
          a.type_("password"),
          a.id("new-password"),
          a.name("new-password"),
          a.placeholder("Enter password"),
          a.autocomplete("new-password"),
        ]),
      ]),
    ]),
    h.div([], [
      h.label([a.for("confirm-password")], [text("Confirm password")]),
      h.div([], [
        h.input([
          a.type_("password"),
          a.id("confirm-password"),
          a.name("confirm-password"),
          a.placeholder("Confirm password"),
          a.autocomplete("new-password"),
        ]),
      ]),
    ]),
    h.div([], [
      h.label([a.for("signup-otp")], [text("Admin one-time password")]),
      h.div([], [
        h.input([
          a.type_("password"),
          a.id("signup-otp"),
          a.name("signup-otp"),
          a.placeholder("OTP"),
          a.autocomplete("one-time-code"),
        ]),
      ]),
    ]),
    h.div([], [h.div([], [h.input([a.type_("submit"), a.value("Submit")])])]),
  ])
}
