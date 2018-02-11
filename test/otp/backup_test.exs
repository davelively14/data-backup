defmodule DataBackup.BackupTest do
  use ExUnit.Case
  alias DataBackup.Backup

  describe "init/1" do
    test "starts correctly" do
      assert :erlang.whereis(Backup) == :undefined

      assert {:ok, pid} = Backup.start_link()
      assert is_pid(pid)
    end

    test "state initiates to nil" do
      Backup.start_link()
      assert nil == Backup.get_state()
    end
  end

  describe "restore/0" do
    setup :start_server_make_ets

    test "returns nil if no backup data" do
      refute Backup.restore()
    end

    test "returns table name if backup exists", %{ets: ets} do
      transfer_ets(ets)
      assert ets == Backup.restore()
    end

    test "regains control of ets on restore", %{ets: ets} do
      assert Keyword.get(:ets.info(ets), :owner) == self()
      transfer_ets(ets)
      refute Keyword.get(:ets.info(ets), :owner) == self()
      Backup.restore()
      assert Keyword.get(:ets.info(ets), :owner) == self()
    end
  end

  describe ":ets.give_away" do
    setup :start_server_make_ets

    test "triggers handle_info for ETS-TRANSFER", %{ets: ets, backup_pid: backup_pid} do
      :ets.give_away(ets, backup_pid, nil)
      state = Backup.get_state()
      assert state.table_name == :data
    end
  end

  ###################
  # Setup Functions #
  ###################

  def start_server_make_ets(_context) do
    Backup.start_link()

    :ets.new(:data, [:set, :private, :named_table])
    Enum.each(1..5, fn i ->
      :ets.insert(:data, {i, "data for #{i}"})
    end)

    {:ok, %{ets: :data, backup_pid: :erlang.whereis(Backup)}}
  end

  #####################
  # Private Functions #
  #####################

  def transfer_ets(table_name) do
    :ets.give_away(table_name, :erlang.whereis(Backup), nil)
  end
end
