import decode
import gleam/result
import youid/uuid.{type Uuid}

pub opaque type Id(a) {
  Id(value: Int)
}

pub fn id_to_int(id: Id(a)) -> Int {
  id.value
}

pub fn parse_id(id: Int) -> Id(a) {
  Id(id)
}

pub fn id_decoder() {
  decode.int
  |> decode.map(Id)
}

pub opaque type Uid(a) {
  Uid(value: Uuid)
}

pub fn uid_to_string(uid: Uid(a)) -> String {
  uuid.to_string(uid.value)
}

pub fn parse_uid(uid: String) -> Result(Uid(a), Nil) {
  uid
  |> uuid.from_string()
  |> result.map(Uid)
}

pub fn new_uid() -> Uid(a) {
  Uid(uuid.v4())
}
