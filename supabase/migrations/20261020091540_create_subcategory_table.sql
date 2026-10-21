create type category_kind as enum('need', 'want')

create table sub_category (
    id uuid primary key default gen_random_uuid(),
    kind category_kind not null,
    name text not null check (length(title) > 0),
    icon text not null
);
