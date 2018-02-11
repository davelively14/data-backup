defmodule DataBackupTest do
  use ExUnit.Case
  alias DataBackup.{Supervisor, DataMaster, Server}

  describe "start/0" do
    test "starts supervisor and servers" do
      assert :erlang.whereis(Supervisor) == :undefined
      assert :erlang.whereis(DataMaster) == :undefined
      assert :erlang.whereis(Server) == :undefined

      DataBackup.start()

      assert is_pid :erlang.whereis(Supervisor)
      assert is_pid :erlang.whereis(DataMaster)
      assert is_pid :erlang.whereis(Server)
    end
  end

  describe ":ets table" do
    setup :start_app

    test "data is preserved when Server dies and restarts" do
      seed_ets()
      assert base_data = {1, "test"} = Server.get_data(1)

      server_pid = :erlang.whereis(Server)
      Process.exit(server_pid, :error)
      :timer.sleep(100)
      refute server_pid == :erlang.whereis(Server)
      assert Server.get_data(1) == base_data
    end
  end

  ###################
  # Setup Functions #
  ###################

  def start_app(_context) do
    DataBackup.start()
    table_name = Server.get_state |> Map.get(:ets)

    {:ok, %{table_name: table_name}}
  end

  #####################
  # Private Functions #
  #####################

  def seed_ets, do: Server.insert_data(1, "test")
end
