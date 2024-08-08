import gleam/result
import youid/uuid.{type Uuid}

pub opaque type Id(a) {
  Id(value: Uuid)
}

pub fn new_id() -> Id(a) {
  Id(uuid.v4())
}

pub fn id_to_string(id: Id(a)) -> String {
  uuid.to_string(id.value)
}

pub fn id_from_string(string_id id: String) {
  id
  |> uuid.from_string()
  |> result.map(Id)
}
