import app/views/layout
import lustre/element.{type Element}
import wisp.{type Response}

pub fn response(elements: List(Element(t))) -> Response {
  elements
  |> layout.layout()
  |> element.to_document_string_builder()
  |> wisp.html_response(200)
}
