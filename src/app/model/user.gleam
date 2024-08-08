import app/model/id.{type Id}

pub type UserId =
  Id(User)

pub type User {
  Visitor
  Login(id: UserId, username: String)
}
