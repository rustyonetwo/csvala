defmodule Csvala do
  @moduledoc """
  Documentation for `Csvala`.
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
  defp do_parse(input_file, path, arguments) do
    input_file
    |> Stream.map(&String.split(&1, ",", trim: false))
    |> Stream.map(&add_config(&1, arguments))
    |> Stream.map(&mark_outliers(&1))
    |> Stream.uniq_by(fn
      {[_first, _last, email, _phone], {true, _do_phone?}, false} ->
        email

      {_value, _config, _outlier} ->
        nil
    end)
    |> Stream.uniq_by(fn
      {[_first, _last, _email, phone], {_do_email?, true}, false} ->
        phone

      {_value, _config, _outlier} ->
        nil
    end)
    |> Stream.map(&remove_configs_and_outlier_marks(&1))
    |> Stream.map(&format_for_csv(&1))
    |> Stream.into(File.stream!(output_path(path, arguments)))
    |> Stream.run()

    :ok
  end

  @spec add_config(list(String.t()), String.t()) :: {list(String.t()), tuple()}
  defp add_config(value, arguments) do
    {
      value,
      make_config(arguments)
    }
  end

  @spec remove_configs_and_outlier_marks({list(String.t()), {boolean(), boolean()}, boolean()}) ::
          list(String.t())
  defp remove_configs_and_outlier_marks({value, _config, _outlier}), do: value

  @spec output_path(Path.t(), String.t()) :: Path.t()
  defp output_path(path, arguments) do
    Path.basename(path, ".csv") <> "_deduplicated_by_#{arguments}.csv"
  end

  @spec make_config(String.t()) :: {boolean(), boolean()}
  defp make_config("e") do
    {true, false}
  end

  defp make_config("ep") do
    {true, true}
  end

  defp make_config("p") do
    {false, true}
  end

  defp make_config(_) do
    :error
  end

  @spec mark_outliers({list(String.t()), {boolean(), boolean()}}) ::
          {list(String.t()), {boolean(), boolean()}, boolean()}
  defp mark_outliers({value = [_first, _last, "", _phone], config = {true, _do_phone?}}) do
    {value, config, true}
  end

  defp mark_outliers({value = [_first, _last, _email, ""], config = {_do_email?, true}}) do
    {value, config, true}
  end

  defp mark_outliers({value = [_first, _last, _email, _phone], config}) do
    {value, config, false}
  end

  defp mark_outliers({value, config}) do
    {value, config, true}
  end

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
