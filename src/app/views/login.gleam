import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre_hx as hx

pub fn login_view() -> Element(t) {
  h.form([hx.boost(True), a.method("post"), a.action("/login")], [
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
      h.label([a.for("password")], [text("Password")]),
      h.div([], [
        h.input([
          a.type_("password"),
          a.id("password"),
          a.name("password"),
          a.placeholder("Enter password"),
          a.autocomplete("current-password"),
        ]),
      ]),
    ]),
    h.div([], [h.div([], [h.input([a.type_("submit"), a.value("Submit")])])]),
  ])
}
