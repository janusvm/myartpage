create table if not exists user (
    id integer primary key autoincrement not null,
    level text not null,
    username text not null unique,
    password_hash text not null,
    password_salt text not null,
    created_at text not null default (datetime('now')),
    updated_at text not null default (datetime('now'))
) strict;

create trigger if not exists trg_user_updated_at
    before update on user
    for each row
    begin
        update user set updated_at = datetime('now');
    end;
