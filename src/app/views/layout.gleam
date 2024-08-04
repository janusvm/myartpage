import lustre/attribute.{attribute, href, name, rel}
import lustre/element.{type Element}
import lustre/element/html.{body, head, html, link, meta, title}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html([], [
    head([], [
      title([], "myartpage"),
      meta([
        name("viewport"),
        attribute("content", "width=device-width, initial-scale=1"),
      ]),
      link([rel("stylesheet"), href("/static/assets/css/app.css")]),
    ]),
    body([], elements),
  ])
}
