defmodule Csvala do
  @moduledoc """
  Csvala is a CSV parser that specifically looks for duplicate records
  based on email, phone number, or either. The main entry point for the program
  is the parse/2 function, which accepts a file path and a configuration string,
  which can be "e" for email, "p" for phone, or "ep" for either.

  ##Example
    iex> Csvala.parse("sample_100.csv", "e")
    :ok
  """
  @spec parse(Path.t(), String.t()) :: :ok | :error
  def parse(path, arguments) do
    case {File.stat(path), validate_arguments(arguments)} do
      {{:ok, _stat}, true} ->
        do_parse(File.stream!(path, [], :line), path, arguments)
        :ok

      {{:ok, _stat}, false} ->
        IO.puts("Invalid argument!\nValid arguments are: e = email, p = phone, ep = either")
        :error

      {{:error, reason}, _} ->
        IO.puts("File not found: #{reason}")
        :error
    end
  end

  @spec do_parse(File.Stream.t(), Path.t(), String.t()) :: :ok
  def do_parse(input_file, path, arguments) do
    input_file
    |> Stream.map(&String.split(&1, ",", trim: false))
    |> Stream.map(&mark_outliers(&1))
    |> unique_by_email_or_phone(arguments)
    |> Stream.map(&remove_outlier_marks(&1))
    |> Stream.map(&format_for_csv(&1))
    |> Stream.into(File.stream!(output_path(path, arguments)))
    |> Stream.run()

    :ok
  end

  @spec unique_by_email_or_phone(Enumerable.t(), String.t()) :: Enumerable.t()
  defp unique_by_email_or_phone(stream, arguments) do
    case arguments do
      "e" ->
        stream |> Stream.uniq_by(&unique_by_email(&1))

      "p" ->
        stream |> Stream.uniq_by(&unique_by_phone(&1))

      "ep" ->
        stream |> Stream.uniq_by(&unique_by_email(&1)) |> Stream.uniq_by(&unique_by_phone(&1))
    end
  end

  @spec unique_by_phone({list(String.t()), boolean()}) :: String.t() | nil
  defp unique_by_phone({[_first, _last, _email, phone], false}), do: phone
  defp unique_by_phone({_value, _outlier}), do: false

  @spec unique_by_email({list(String.t()), boolean()}) :: String.t() | nil
  defp unique_by_email({[_first, _last, email, _phone], false}), do: email
  defp unique_by_email({_value, _outlier}), do: nil

  @spec remove_outlier_marks({list(String.t()), boolean()}) ::
          list(String.t())
  defp remove_outlier_marks({value, _outlier}), do: value

  @spec output_path(Path.t(), String.t()) :: Path.t()
  defp output_path(path, arguments) do
    Path.join([Path.dirname(path), Path.basename(path, ".csv")]) <>
      "_deduplicated_by_#{arguments}.csv"
  end

  @spec mark_outliers({list(String.t())}) :: {list(String.t()), boolean()}
  defp mark_outliers(value = [_first, _last, "", _phone]), do: {value, true}
  defp mark_outliers(value = [_first, _last, _email, ""]), do: {value, true}
  defp mark_outliers(value = [_first, _last, _email, _phone]), do: {value, false}
  defp mark_outliers(value), do: {value, true}

  @spec format_for_csv(list(String.t())) :: String.t()
  defp format_for_csv([last, first, email, phone]) do
    "#{last},#{first},#{email},#{phone}"
  end

  defp format_for_csv([first, second, third]) do
    "#{first},#{second},#{third}"
  end

  @spec validate_arguments(String.t()) :: boolean()
  defp validate_arguments("e"), do: true
  defp validate_arguments("ep"), do: true
  defp validate_arguments("p"), do: true
  defp validate_arguments(_args), do: false
end
