import app/model/config.{type DbConfig}
import gleam/pgo.{type Connection}

pub const db_subdir = "/db"

pub const migrations_subdir = db_subdir <> "/migrations"

pub fn with_connection(config: DbConfig, f: fn(Connection) -> Result(a, String)) {
  let conn = pgo.connect(config)
  use conn <- pgo.transaction(conn)
  let result = f(conn)
  pgo.disconnect(conn)

  result
}

pub fn migrate_database(config: DbConfig, migrations_dir: String) {
  Nil
}
