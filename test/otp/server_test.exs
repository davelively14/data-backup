defmodule DataBackup.ServerTest do
  use ExUnit.Case
  alias DataBackup.{DataMaster, Server}

  @ets_name :data

  describe "start_link/1" do
    setup :start_data_master

    test "starts correctly" do
      assert :erlang.whereis(Server) == :undefined

      assert {:ok, pid} = Server.start_link()
      assert is_pid(pid)
    end

    test "assumes ownership of the ets table" do
      assert :ets.info(@ets_name)[:owner] == :erlang.whereis(DataMaster)
      Server.start_link()
      assert :ets.info(@ets_name)[:owner] == :erlang.whereis(Server)
    end
  end

  describe "insert_data/2" do
    setup :start_all_servers

    test "inserts data correctly" do
      assert :ok == Server.insert_data(12, %{name: "John Smith"})
      assert :ets.lookup(@ets_name, 12) == [{12, %{name: "John Smith"}}]
    end

    test "overwrites data if id is the same" do
      Server.insert_data(12, %{name: "John Smith"})
      Server.insert_data(12, %{name: "Jane Smith"})
      assert :ets.lookup(@ets_name, 12) == [{12, %{name: "Jane Smith"}}]
    end
  end

  describe "get_data/1" do
    setup :start_all_servers_and_seed

    test "returns correct value" do
      assert Server.get_data(1) == {1, "data for 1"}
      assert Server.get_data(3) == {3, "data for 3"}
    end
  end

  ###################
  # Setup Functions #
  ###################

  def start_data_master(_context) do
    DataMaster.start_link()

    {:ok, %{}}
  end

  def start_all_servers(_context) do
    DataMaster.start_link()
    Server.start_link()

    {:ok, %{}}
  end

  def start_all_servers_and_seed(_context) do
    start_all_servers(nil)

    Enum.each(1..10, fn i ->
      Server.insert_data(i, "data for #{i}")
    end)
  end
end
