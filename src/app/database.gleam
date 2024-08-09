import app/model/config.{type DbConfig}
import feather
import feather/migrate
import gleam/result

pub const db_subdir = "/db"

pub const migrations_subdir = db_subdir <> "/migrations"

pub fn migrate_database(config: DbConfig, migrations_dir: String) {
  use conn <- feather.with_connection(config)
  use migrations <- result.try(migrate.get_migrations(migrations_dir))

  migrate.migrate(migrations, conn)
}
