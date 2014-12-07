defmodule Abutment.Repo.Migrations.CreateInitialTask do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE tasks(
      id serial primary key,
      title text,
      body text,
      tags text[],
      created_at timestamp DEFAULT current_timestamp,
      updated_at timestamp DEFAULT current_timestamp
    )
    """
  end

  def down do
    "DROP TABLE tasks"
  end
end
