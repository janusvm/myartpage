import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre_hx as hx

pub fn layout(elements: List(Element(a))) -> Element(a) {
  h.html([a.class("h-full bg-white")], [
    h.head([], [
      h.title([], "myartpage"),
      h.meta([a.attribute("charset", "UTF-8")]),
      h.meta([
        a.attribute("content", "width=device-width, initial-scale=1"),
        a.name("viewport"),
      ]),
      h.link([a.rel("preconnect"), a.href("https://fonts.googleapis.com")]),
      h.link([
        a.rel("preconnect"),
        a.href("https://fonts.gstatic.com"),
        a.attribute("crossorigin", "true"),
      ]),
      h.link([
        a.rel("stylesheet"),
        a.href(
          "https://fonts.googleapis.com/css2?family=Overpass:ital,wght@0,100..900;1,100..900&display=swap",
        ),
      ]),
      h.link([a.rel("stylesheet"), a.href("/static/css/app.css")]),
    ]),
    h.body([hx.boost(True), a.class("h-full")], elements),
  ])
}
