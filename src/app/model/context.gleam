import app/model/session.{type Session}

pub type Context {
  Context(static_dir: String, session: Session)
}

pub fn new(static_dir: String) {
  Context(static_dir, session.new())
}
