defmodule Abutment.UserModel do
  use Ecto.Model
  import Ecto.Query

  schema "users" do
    field :email, :string
    field :name, :string
    field :crypted_password, :string
    has_many :created_tasks, Abutment.TaskMode, foriegn_key: :creator_id
    has_many :owned_tasks, Abutment.TaskMode, foriegn_key: :owner_id

    field :created_at, :datetime
    field :updated_at, :datetime
  end

  validate user,
    email: present() and has_format(~r/@/)
    name: present()

  def validate_password(errors, password) when is_nil(password) or (is_binary(password) and byte_size(password) == 0) do 
    errors ++ [{:password, "must be set"}]
  end
  def validate_password(errors, password) when byte_size(password) < 6 do
    errors ++ [{:password, "must be greater than 6 characters long"}]
  end
  def validate_password(errors, _password) do
    errors
  end


  def crypt(""), do: raise "You cannot encrypt an empty password."
  def crypt(password) do
    :erlpass.hash(password)
  end

  def password_check(user, ""), do: false
  def password_check(nil, password), do: false
  def password_check(%User{:crypted_password => nil}, password), do: false
  def password_check(user, password) do
    erlpass:match(password, user.crypted_password)
  end
end
