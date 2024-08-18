import app/model/config.{type DbConfig}
import feather
import feather/migrate
import gleam/io
import gleam/result
import gleam/string
import sqlight
import wisp

pub const db_subdir = "/db"

pub const migrations_subdir = db_subdir <> "/migrations"

pub type DatabaseError {
  MigrationError(migrate.MigrationError)
  SqliteError(sqlight.Error)
}

pub fn migrate_database(config: DbConfig, migrations_dir: String) {
  case
    {
      wisp.log_info("Initiating database migrations...")
      use conn <- feather.with_connection(config)
      io.debug(conn)
      use migrations <- result.try(
        migrate.get_migrations(migrations_dir)
        |> result.map_error(MigrationError),
      )
      migrate.migrate(migrations, conn)
      |> result.map_error(MigrationError)
      |> io.debug
    }
    |> result.map_error(SqliteError)
    |> result.flatten()
  {
    Ok(_) -> wisp.log_info("Succesfully completed database migrations")
    Error(e) ->
      panic as {
        "An error occured duing database migration.\n" <> string.inspect(e)
      }
  }
}
