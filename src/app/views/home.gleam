import app/model/context.{type Context}
import app/model/user.{Login, Visitor}
import gleam/int
import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre_hx as hx

pub fn home(ctx: Context) -> Element(t) {
  let message = case ctx.session {
    None -> "No session"
    Some(session) -> {
      case session.user {
        Visitor -> "Not logged in"
        Login(_, _, username, _) -> "Logged in as " <> username
      }
    }
  }
  h.div([], [
    h.h1([], [text("Home")]),
    h.div([], [text(message)]),
    h.div([], [
      text(
        "(Session will timeout after "
        <> int.to_string(ctx.config.session_timeout)
        <> "s of inactivity)",
      ),
    ]),
    h.ul([], [
      h.li([], [h.a([hx.boost(True), a.href("/login")], [text("/login")])]),
      h.li([], [h.a([hx.boost(True), a.href("/admin")], [text("/admin")])]),
      h.li([], [
        h.a([hx.boost(True), a.href("/admin/dashboard")], [
          text("/admin/dashboard"),
        ]),
      ]),
    ]),
  ])
}
