defmodule Abutment.Repo.Migrations.CreateInitialUser do
  use Ecto.Migration

  def up do
    ["""
    CREATE TABLE users(
      id serial primary key,
      email text UNIQUE,
      name text,
      crypted_password text,
      created_at timestamp DEFAULT current_timestamp,
      updated_at timestamp DEFAULT current_timestamp
    )
    """,
    "ALTER TABLE tasks ADD COLUMN owner_id integer",
    "ALTER TABLE tasks ADD COLUMN creator_id integer",
    "ALTER TABLE tasks ADD FOREIGN KEY (owner_id) REFERENCES users(id)",
    "ALTER TABLE tasks ADD FOREIGN KEY (creator_id) REFERENCES users(id)"]
  end

  def down do
    ["DROP TABLE users",
    "ALTER TABLE tasks DROP COLUMN owner_id",
    "ALTER TABLE tasks DROP COLUMN creator_id"]
  end
end
