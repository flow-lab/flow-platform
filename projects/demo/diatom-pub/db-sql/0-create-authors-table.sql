create extension if not exists "uuid-ossp";
create extension if not exists citext;

CREATE TABLE if not exists authors
(
    id   uuid primary key default uuid_generate_v4(),
    name text not null,
    bio  text
);