-- Schema definition for v1 of myartpage
do $ddl$
begin

create or replace function updated_trigger_fn() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

create table if not exists users (
  id serial primary key,
  level varchar(20) not null,
  username varchar(100) not null unique,
  password_hash text not null,
  password_salt text not null,
  created_at timestamp not null default current_timestamp,
  updated_at timestamp not null default current_timestamp
);

create index if not exists idx_user_level on users (level);

create or replace trigger trg_user_updated_at
  before update on users
  for each row
  execute function updated_trigger_fn();

end
$ddl$;
