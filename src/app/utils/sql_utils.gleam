import cake.{type ReadQuery, type WriteQuery}
import cake/dialect/postgres_dialect
import cake/param.{
  type Param, BoolParam, FloatParam, IntParam, NullParam, StringParam,
}
import decode.{type Decoder}
import gleam/list
import gleam/pgo.{type Connection, type QueryError}
import gleam/result
import gleam/string

fn map_sql_param_type(param: Param) {
  case param {
    BoolParam(param) -> pgo.bool(param)
    FloatParam(param) -> pgo.float(param)
    IntParam(param) -> pgo.int(param)
    StringParam(param) -> pgo.text(param)
    NullParam -> pgo.null()
  }
}

pub fn get_rows(query_result: pgo.Returned(a)) -> List(a) {
  query_result.rows
}

pub fn execute_read(
  read_query: ReadQuery,
  db: Connection,
  decoder: Decoder(a),
) -> Result(List(a), QueryError) {
  let prp_stmt = postgres_dialect.query_to_prepared_statement(read_query)
  let sql = cake.get_sql(prp_stmt)
  let params =
    cake.get_params(prp_stmt)
    |> list.map(map_sql_param_type)

  pgo.execute(sql, db, params, decode.from(decoder, _))
  |> result.map(get_rows)
}

pub fn execute_write(
  write_query: WriteQuery(a),
  db: Connection,
  decoder: Decoder(a),
) -> Result(List(a), QueryError) {
  let prp_stmt = postgres_dialect.write_query_to_prepared_statement(write_query)
  let sql = cake.get_sql(prp_stmt)
  let params =
    cake.get_params(prp_stmt)
    |> list.map(map_sql_param_type)

  pgo.execute(sql, db, params, decode.from(decoder, _))
  |> result.map(get_rows)
}

pub fn pgo_error_string(msg: String, error: QueryError) {
  let inner_msg = string.inspect(error)
  msg <> " → " <> inner_msg
}
