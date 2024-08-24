import app/model/config.{type DbConfig}
import app/utils/sql_utils as sql
import gleam/bool
import gleam/dynamic
import gleam/list
import gleam/order.{type Order}
import gleam/pgo.{type Connection}
import gleam/result
import gleam/string
import simplifile
import wisp

pub fn with_connection(config: DbConfig, f: fn(Connection) -> Result(a, String)) {
  let conn = pgo.connect(config)
  use conn <- pgo.transaction(conn)
  let result = f(conn)
  pgo.disconnect(conn)

  result
}

// Migrations -------------------------------------------------------------------------------------

const migrations_subdir = "db/migrations"

const migrations_ddl = "create table if not exists migrations (
  name varchar(100) primary key,
  applied boolean default false
);"

const check_migration_sql = "select applied from migrations where name = $1;"

type Migration {
  Migration(name: String, patch: String)
}

pub type MigrationError {
  FileError(simplifile.FileError)
  PathError
  TransactionError(pgo.TransactionError)
}

pub fn migrate_database(db: Connection, priv_dir: String) {
  wisp.log_info("Running database migrations...")
  let migrations_path = priv_dir <> "/" <> migrations_subdir
  use migrations <- result.try(get_migrations(migrations_path))

  {
    use conn <- pgo.transaction(db)
    use _apply_migrations_ddl <- result.try(
      pgo.execute(migrations_ddl, conn, [], dynamic.dynamic)
      |> result.replace_error("Error executing migrations DDL"),
    )
    use _apply_migrations <- result.try(
      migrations
      |> list.try_each(apply_migration(_, conn)),
    )

    wisp.log_info("Database migrations succesfully applied")
    Ok(Nil)
  }
  |> result.map_error(TransactionError)
}

fn apply_migration(
  migration: Migration,
  conn: Connection,
) -> Result(Nil, String) {
  use migrated <- result.try(
    check_migration_sql
    |> pgo.execute(
      conn,
      [pgo.text(migration.name)],
      dynamic.element(0, dynamic.bool),
    )
    |> result.map(sql.get_rows)
    |> result.replace_error(
      "Error occured while looking up migration in database",
    ),
  )

  let already_applied = case migrated {
    [] -> False
    [applied] -> applied
    _ ->
      panic as "Multiple migrations with the same name in the `migrations` table"
  }

  use <- bool.guard(when: already_applied, return: Ok(Nil))

  use _apply_patch <- result.try({
    wisp.log_info("Applying migration: " <> migration.name)
    pgo.execute(migration.patch, conn, [], dynamic.dynamic)
    |> result.replace_error(
      "Error occured while applying migration: " <> migration.name,
    )
  })

  use _register_patch <- result.try(
    "insert into migrations (name, applied) values ($1, $2);"
    |> pgo.execute(
      conn,
      [pgo.text(migration.name), pgo.bool(True)],
      dynamic.dynamic,
    )
    |> result.replace_error("Error occured while registering migration"),
  )

  Ok(Nil)
}

fn get_migrations(in path: String) -> Result(List(Migration), MigrationError) {
  simplifile.get_files(path)
  |> result.map_error(FileError)
  |> result.then(list.try_map(_, path_to_migration))
  |> result.map(list.sort(_, compare_migrations))
}

fn path_to_migration(path: String) -> Result(Migration, MigrationError) {
  use name <- result.try(
    string.split(path, "/")
    |> list.last()
    |> result.replace_error(PathError),
  )

  use patch <- result.try(
    simplifile.read(path)
    |> result.map_error(FileError),
  )

  Ok(Migration(name:, patch:))
}

fn compare_migrations(a: Migration, b: Migration) -> Order {
  string.compare(a.name, b.name)
}
