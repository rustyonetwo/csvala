defmodule CsvalaTest do
  @moduledoc """
  This test suite uses the file IO system in elixir to test the functions of
  the main Csvala functions.
  """
  use ExUnit.Case

  doctest Csvala

  @test_file "tmp/sample.csv"
  @test_file_deduplicated_by_e "tmp/sample_deduplicated_by_e.csv"
  @test_file_deduplicated_by_p "tmp/sample_deduplicated_by_p.csv"
  @test_file_deduplicated_by_ep "tmp/sample_deduplicated_by_ep.csv"

  @no_duplicate_emails 9
  @no_duplicate_phone_numbers 8
  @no_duplicate_emails_or_phone_numbers 7

  setup_all do
    File.write!(@test_file, test_file_contents())
    on_exit(fn -> File.rm!(@test_file) end)
    on_exit(fn -> File.rm!(@test_file_deduplicated_by_e) end)
    on_exit(fn -> File.rm!(@test_file_deduplicated_by_p) end)
    on_exit(fn -> File.rm!(@test_file_deduplicated_by_ep) end)
  end

  defp test_file_contents() do
    """
    First Name, Last Name, Email, Phone
    Garrett,Wright,inozebago@ecireazo.ws,(349) 647-8165
    Garrett,Wright,inozebago@ecireazo.ws,(349) 647-8165
    Stanley,Holloway,,(930) 439-5896
    Loretta,Banks,butecka@ihodon.vi,(936) 481-2200
    Loretta,Banks,buteckb@ihodon.vi,(936) 481-2200
    Devin,Cannon,nimojhu@rogirure.lv,
    Olga,Bush,wibhenu@belfu.gq,(803) 209-9638
    Olga,Bush,wibhenu@belfu.gq,(803) 209-9637
    Celia,Carroll,guhe@kiefura.cx,(349) 647-8165
    """
  end

  describe "parse/2" do
    test "accepts a file path and a valid arguments" do
      assert :ok = Csvala.parse(@test_file, "e")
      assert :ok = Csvala.parse(@test_file, "p")
      assert :ok = Csvala.parse(@test_file, "ep")
    end

    test "returns :error for invalid file path" do
      assert :error = Csvala.parse("invalid_file_path", "e")
    end

    test "returns :error for inavlid parameters" do
      assert :error = Csvala.parse(@test_file, "j")
    end
  end

  describe "do_parse/3" do
    setup do
      file_stream = File.stream!(@test_file, [], :line)
      %{file_stream: file_stream}
    end

    test "writes a csv file", %{file_stream: file_stream} do
      :ok = Csvala.do_parse(file_stream, @test_file, "e")
      assert {:ok, _file_stat} = File.stat("tmp/sample_deduplicated_by_e.csv")
    end

    test "deduplicating by email only removes duplicate emails", %{file_stream: file_stream} do
      :ok = Csvala.do_parse(file_stream, @test_file, "e")

      assert @no_duplicate_emails =
               File.read!(@test_file_deduplicated_by_e)
               |> String.split("\n")
               |> length()
    end

    test "deduplicating by phone only removes duplicate phones", %{file_stream: file_stream} do
      :ok = Csvala.do_parse(file_stream, @test_file, "p")

      assert @no_duplicate_phone_numbers =
               File.read!(@test_file_deduplicated_by_p)
               |> String.split("\n")
               |> length()
    end

    test "deduplicating by email and phone removes duplicate emails and phones", %{
      file_stream: file_stream
    } do
      :ok = Csvala.do_parse(file_stream, @test_file, "ep")

      assert @no_duplicate_emails_or_phone_numbers =
               File.read!(@test_file_deduplicated_by_ep)
               |> String.split("\n")
               |> length()
    end

    test "entries missing a value are retained in the output", %{file_stream: file_stream} do
      :ok = :ok = Csvala.do_parse(file_stream, @test_file, "ep")
      assert File.read!(@test_file_deduplicated_by_ep) =~ "Devin,Cannon"
    end
  end
end
