# Abutment

## Requirements

- Postgres
- Elixir Latest

## Setup

1. `mix do deps.get, compile`
2. `mix ecto.create Abutement.Repo`
3. `mix ecto.migrate Abutement.Repo`
4. `mix phoenix.start`
5. `open localhost:4000`

### Extras

If you use Postman Client then check this out https://www.getpostman.com/collections/e3ccdfdb44f6a4ea7be4 it should be up to date with all my latest integration test cases.
