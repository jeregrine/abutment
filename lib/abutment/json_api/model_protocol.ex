defprotocol JSONAPI.ModelPatch do
  def exists?(model, path)
  def add(model, path, value)
  def remove(model, path)
  def get_value(model, path)
end

defimpl JSONAPI.ModelPatch, for: Ecto.Model do
  def exists?(model, path) do
    case JSONAPI.ModelPath.get_value(model, path) do
      nil -> false
      value -> true
    end
  end

  def add(model, path, value) do
    parts = JSONAPI.Helpers.parse_path(path)
  end

  def remove(model, path) do
    parts = JSONAPI.Helpers.parse_path(path)
    try
      JASONAPI.Helper.get_in_and_update(model, parts, fn (acc, part) ->
        case acc do
          acc when is_list(acc) && is_number(part) ->
            List.delete_at(acc, part) do
          acc when is_map(acc) ->
            Map.delete(acc, part)
          _  ->
            raise "Invalid #{part} for #{acc} in remove"
          end
      end)
  end

  def get_value(model, path) do
    parts = JSONAPI.Helpers.parse_path(path)
    try
      JASONAPI.Helper.get_in(model, parts)
    rescue
      RuntimeError -> nil
    end
  end
end

defmodule JSONAPI.Helpers do
  def parse_path(path) do
    String.split(path, "/") |> Enum.map(&str_or_number/1)
  end

  defp str_or_number(p) do
    try
      String.to_integer(p)
    rescue
      ArgumentError -> p
    end
  end

  def get_in_and_update(acc, [part | []], fun), do: fun.(acc, part)
  def get_in_and_update(acc, [part | parts], fun) do
    get_in_and_update(get_in(acc, [part]), parts, fun)
  end

  def get_in(acc, []), do: acc
  def get_in(acc, [part | parts]) when is_number(part) do
    case Enum.at(acc, part, :none) do
      :none -> raise "Could not find the part #{part} in #{acc}"
      acc -> get_in(acc, parts)
    end
  end
  def get_in(acc, [part | parts]) when is_binary(part) do
    case Map.get(acc, part, :none) do
      :none -> raise "Could not find the part #{part} in #{acc}"
      acc -> get_in(acc, parts)
    end
  end
end
