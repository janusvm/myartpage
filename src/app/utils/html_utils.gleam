import app/views/layout
import lustre/element.{type Element} as e
import wisp.{type Response}

pub fn render_page(elements: List(Element(t)), http_code: Int) -> Response {
  elements
  |> layout.layout()
  |> e.to_document_string_builder()
  |> wisp.html_response(http_code)
}

pub fn render_element(element: Element(t), http_code: Int) -> Response {
  element
  |> e.to_string_builder()
  |> wisp.html_response(http_code)
}
