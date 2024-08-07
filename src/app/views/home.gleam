import app/model/user.{Login, Visitor}
import app/state/context.{type Context}
import app/state/session
import gleam/option.{None, Some}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h1, span}

pub fn home(ctx: Context) -> Element(t) {
  let message = case ctx.session {
    None -> "No session"
    Some(session) -> {
      case session.get_user(session) {
        Visitor -> "Not logged in"
        Login(_, username) -> "Logged in as " <> username
      }
    }
  }
  div([], [h1([], [text("Home")]), span([], [text(message)])])
}
