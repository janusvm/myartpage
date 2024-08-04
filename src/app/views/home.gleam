import lustre/element.{type Element, text}
import lustre/element/html.{h1}

pub fn home() -> Element(t) {
  h1([], [text("Home")])
}
