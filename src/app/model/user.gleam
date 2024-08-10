import app/model/id.{type Id}
import app/utils
import argus
import cake
import cake/dialect/sqlite_dialect
import cake/insert as i
import cake/select as s
import cake/where as w
import decode
import gleam/bool
import gleam/dynamic
import gleam/list
import gleam/result
import sqlight.{type Connection}

pub type UserId =
  Id(User)

pub type UserLevel {
  Reader
  Admin
}

pub type Password {
  Password(hash: String, salt: String)
}

pub type User {
  Visitor
  Login(id: UserId, level: UserLevel, username: String, password: Password)
}

fn user_level_to_string(level: UserLevel) {
  case level {
    Reader -> "reader"
    Admin -> "admin"
  }
}

fn user_decoder() {
  decode.into({
    use id <- decode.parameter
    use level <- decode.parameter
    use username <- decode.parameter
    use hash <- decode.parameter
    use salt <- decode.parameter

    Login(id:, level:, username:, password: Password(hash:, salt:))
  })
  |> decode.field(0, id.id_decoder())
  |> decode.field(1, user_level_decoder())
  |> decode.field(2, decode.string)
  |> decode.field(3, decode.string)
  |> decode.field(4, decode.string)
}

fn user_level_decoder() {
  decode.string
  |> decode.then(fn(decoded_string) {
    case decoded_string {
      "reader" -> decode.into(Reader)
      "admin" -> decode.into(Admin)
      _ -> decode.fail("UserLevel")
    }
  })
}

pub fn parse_user_level(level: String) {
  user_level_decoder()
  |> decode.from(dynamic.from(level))
}

/// Returns `True` if any user with level `Admin` is present in the database.
///
pub fn admin_exists(db: Connection) -> Bool {
  let prp_stm =
    s.new()
    |> s.select(s.col("1"))
    |> s.from_table("user")
    |> s.where(w.eq(w.col("level"), w.string(user_level_to_string(Admin))))
    |> s.limit(1)
    |> s.to_query()
    |> sqlite_dialect.query_to_prepared_statement()

  let sql = cake.get_sql(prp_stm)
  let db_params =
    prp_stm
    |> cake.get_params()
    |> list.map(utils.map_sql_param_type)

  sqlight.query(sql, db, db_params, dynamic.dynamic)
  |> result.unwrap([])
  |> list.is_empty()
  |> bool.negate()
}

pub fn get_login(
  db: Connection,
  username: String,
  password: String,
) -> Result(User, Nil) {
  let prp_stm =
    s.new()
    |> s.selects([
      s.col("id"),
      s.col("level"),
      s.col("username"),
      s.col("password_hash"),
      s.col("password_salt"),
    ])
    |> s.from_table("user")
    |> s.where(w.eq(w.col("username"), w.string(username)))
    |> s.limit(1)
    |> s.to_query()
    |> sqlite_dialect.query_to_prepared_statement()

  let sql = cake.get_sql(prp_stm)
  let db_params =
    prp_stm
    |> cake.get_params()
    |> list.map(utils.map_sql_param_type)

  let result = sqlight.query(sql, db, db_params, decode.from(user_decoder(), _))
  case result {
    Ok([Login(password: pw, ..) as unauthenticated_user]) -> {
      let assert Ok(hashed) = argus.hash(argus.hasher(), password, pw.salt)
      case hashed.encoded_hash == pw.hash {
        True -> Ok(unauthenticated_user)
        False -> Error(Nil)
      }
    }
    // TODO: add error codes?
    _ -> Error(Nil)
  }
}

pub fn create_user(
  db: Connection,
  level: UserLevel,
  username: String,
  password: String,
) -> Result(User, Nil) {
  let salt = argus.gen_salt()
  let assert Ok(hash) = argus.hash(argus.hasher(), password, salt)
  let prp_stm =
    [
      [
        i.string(user_level_to_string(level)),
        i.string(username),
        i.string(hash.encoded_hash),
        i.string(salt),
      ]
      |> i.row(),
    ]
    |> i.from_values(table_name: "user", columns: [
      "level", "username", "password_hash", "password_salt",
    ])
    |> i.returning(["id", "level", "username", "password_hash", "password_salt"])
    |> i.to_query()
    |> sqlite_dialect.write_query_to_prepared_statement()

  let sql = cake.get_sql(prp_stm)
  let db_params =
    prp_stm
    |> cake.get_params()
    |> list.map(utils.map_sql_param_type)

  sqlight.query(sql, db, db_params, decode.from(user_decoder(), _))
  |> result.nil_error
  |> result.then(list.first)
}
