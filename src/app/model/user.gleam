import app/model/id.{type Id}
import app/utils
import beecrypt
import cake
import cake/dialect/sqlite_dialect
import cake/insert as i
import gleam/dynamic
import gleam/list
import sqlight

pub type UserId =
  Id(User)

pub type UserLevel {
  Reader
  Admin
}

pub type User {
  Visitor
  Login(id: UserId, level: UserLevel, username: String, password_hash: String)
}

pub fn create_user(db: sqlight.Connection, username: String, password: String) {
  let password_hash = beecrypt.hash(password)
  let prp_stm =
    [
      [i.string("admin"), i.string(username), i.string(password_hash)]
      |> i.row(),
    ]
    |> i.from_values(table_name: "user", columns: [
      "level", "username", "password_hash",
    ])
    |> i.returning(["id", "level", "username", "password_hash", "created_at"])
    |> i.to_query()
    |> sqlite_dialect.write_query_to_prepared_statement()

  let sql = cake.get_sql(prp_stm)
  let db_params =
    prp_stm
    |> cake.get_params()
    |> list.map(utils.map_sql_param_type)

  sqlight.query(sql, db, db_params, get_user_decoder())
}

fn get_user_decoder() {
  let level_decoder =
    dynamic.decode1(
      fn(level) {
        case level {
          "admin" -> Admin
          _ -> Reader
        }
      },
      dynamic.string,
    )

  dynamic.decode5(
    map_user_type,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, level_decoder),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.string),
    dynamic.element(4, dynamic.string),
  )
}

fn map_user_type(
  id: Int,
  level: UserLevel,
  username: String,
  password_hash: String,
  created_at: String,
) {
  case level {
    _ -> Visitor
    // "admin" -> Login(id:, username:, password_hash:)
  }
}
