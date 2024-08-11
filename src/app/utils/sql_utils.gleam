import cake.{type ReadQuery, type WriteQuery}
import cake/dialect/sqlite_dialect
import cake/param.{
  type Param, BoolParam, FloatParam, IntParam, NullParam, StringParam,
}
import decode.{type Decoder}
import gleam/list
import sqlight.{type Connection, type Error}

fn map_sql_param_type(param: Param) {
  case param {
    BoolParam(param) -> sqlight.bool(param)
    FloatParam(param) -> sqlight.float(param)
    IntParam(param) -> sqlight.int(param)
    StringParam(param) -> sqlight.text(param)
    NullParam -> sqlight.null()
  }
}

pub fn execute_read(
  read_query: ReadQuery,
  db: Connection,
  decoder: Decoder(a),
) -> Result(List(a), Error) {
  let prp_stmt = sqlite_dialect.query_to_prepared_statement(read_query)
  let sql = cake.get_sql(prp_stmt)
  let params =
    cake.get_params(prp_stmt)
    |> list.map(map_sql_param_type)

  sqlight.query(sql, db, params, decode.from(decoder, _))
}

pub fn execute_write(
  write_query: WriteQuery(a),
  db: Connection,
  decoder: Decoder(a),
) -> Result(List(a), Error) {
  let prp_stmt = sqlite_dialect.write_query_to_prepared_statement(write_query)
  let sql = cake.get_sql(prp_stmt)
  let params =
    cake.get_params(prp_stmt)
    |> list.map(map_sql_param_type)

  sqlight.query(sql, db, params, decode.from(decoder, _))
}
