create table expense (
    id uuid primary key default gen_random_uuid(),
    title text not null check (length(title) > 0),
    amount bigint not null check (amount > 0),
    date date not null,
    subcategory_id uuid not null references subcategory(id),
    created_at timestamp default now()
);
