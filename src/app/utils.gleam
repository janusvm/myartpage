import app/views/layout
import cake/param.{
  type Param, BoolParam, FloatParam, IntParam, NullParam, StringParam,
}
import lustre/element.{type Element}
import sqlight
import wisp.{type Response}

pub fn response(elements: List(Element(t))) -> Response {
  elements
  |> layout.layout()
  |> element.to_document_string_builder()
  |> wisp.html_response(200)
}

pub fn map_sql_param_type(param: Param) {
  case param {
    BoolParam(param) -> sqlight.bool(param)
    FloatParam(param) -> sqlight.float(param)
    IntParam(param) -> sqlight.int(param)
    StringParam(param) -> sqlight.text(param)
    NullParam -> sqlight.null()
  }
}
