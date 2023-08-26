defmodule Genetic.Rng do
  use Rustler, otp_app: :genetic, crate: "rng"

  # When your NIF is loaded, it will override this function.
  def int(), do: :erlang.nif_error(:nif_not_loaded)
  def int_range(a), do: :erlang.nif_error(:nif_not_loaded)
  def float(), do: :erlang.nif_error(:nif_not_loaded)




  ## Re-implements Genetic.Rng.take_random to use NIF rng. ##

  def take_random(_enumerable, 0) do
    []
  end

  def take_random([], _) do
    []
  end

  def take_random([h | t], 1) do
    take_random_list_one(t, h, 1)
  end

  def take_random(enumerable, 1) do
    case(Enum.reduce(enumerable, [], fn
      x, [current | index] ->
        case(int_range(index + 1) == 1) do
          false ->
            [current | index + 1]
          true ->
            [x | index + 1]
        end
      x, [] ->
        [x | 1]
    end)) do
      [] ->
        []
      [current | _index] ->
        [current]
    end
  end

  def take_random(enumerable, count) when is_integer(count) and (is_integer(count) and (count >= 0 and count <= 128)) do
    (
      sample = :erlang.make_tuple(count, nil)
      reducer = fn elem, {idx, sample} ->
        jdx = random_integer(0, idx)
        cond() do
          idx < count ->
            value = elem(sample, jdx)
            {idx + 1, put_elem(put_elem(sample, idx + 1 - 1, value), jdx + 1 - 1, elem)}
          jdx < count ->
            {idx + 1, put_elem(sample, jdx + 1 - 1, elem)}
          true ->
            {idx + 1, sample}
        end
      end
      {size, sample} = Enum.reduce(enumerable, {0, sample}, reducer)
      Enum.take(:erlang.tuple_to_list(sample), min(count, size))
      )
  end

  def take_random(enumerable, count) when is_integer(count) and count >= 0 do
    (
      reducer = fn elem, {idx, sample} ->
        jdx = random_integer(0, idx)
        cond() do
          idx < count ->
            value = Map.get(sample, jdx)
            {idx + 1, :maps.put(jdx, elem, :maps.put(idx, value, sample))}
          jdx < count ->
            {idx + 1, :maps.put(jdx, elem, sample)}
          true ->
            {idx + 1, sample}
        end
      end
      {size, sample} = Enum.reduce(enumerable, {0, %{}}, reducer)
      take_random(sample, min(count, size), [])
      )
  end

  defp take_random(sample, position, acc) do
    (
      position = position - 1
      take_random(sample, position, [Map.get(sample, position) | acc])
      )
  end

  defp take_random_list_one([h | t], current, index) do
    case(random_integer(0, index + 1) == 1) do
      false ->
        take_random_list_one(t, current, index + 1)
      true ->
        take_random_list_one(t, h, index + 1)
    end
  end

  defp take_random_list_one([], current, _) do
    [current]
  end
  defp random_integer(limit, limit) when is_integer(limit) do
    limit
  end

  defp random_integer(lower_limit, upper_limit) when upper_limit < lower_limit do
    random_integer(upper_limit, lower_limit)
  end

  defp random_integer(lower_limit, upper_limit) do
    lower_limit + int_range(upper_limit - lower_limit + 1) - 1
  end
end
