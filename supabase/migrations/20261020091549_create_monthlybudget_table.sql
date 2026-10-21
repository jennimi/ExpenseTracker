create table monthly_budget (
    id uuid primary key default gen_random_uuid(),
    month date not null unique,
    total_amount bigint not null check (total_amount >= 0),
    needs_amount bigint not null check (total_amount >= 0),
    wants_amount bigint not null check (total_amount >= 0)
);