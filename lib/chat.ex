defmodule Chat do
  use CSP
  def start_chat(n) do
    channel = Channel.new()

    Enum.each(1..n, fn i ->
      spawn_link(fn -> add_user(i, channel) end)
    end)


    monitor_chat(channel)
  end


  defp add_user(user_id, channel) do
    send_message(channel, {:join, user_id})
    Enum.each(1..Enum.random(1..10), fn i ->
      write_message(user_id, "Hola soy usuario #{user_id} message #{i}", channel)
      :timer.sleep(1_000)
    end)
    send_message(channel, {:leave, user_id})
  end

  def write_message(user_id, message, channel) do
    send_message(channel, {:message, user_id, message})
  end

  defp send_message(channel, message) do
    Channel.put(channel, message)
  end

  def user_delete(user_id, channel) do
    send_message(channel, {:leave, user_id})
  end


  defp monitor_chat(channel) do
    loop = fn loop ->
      message = Channel.get(channel)
      handle_message(message, loop)
    end

    loop.(loop)
  end

  defp handle_message({:join, user_id}, loop) do
    IO.puts("User #{user_id} joined the chat.")
    loop.(loop)
  end
  defp handle_message({:leave, user_id}, loop) do
    IO.puts("User #{user_id} left the chat.")
    loop.(loop)
  end
  defp handle_message({:message, user_id, message}, loop) do
    IO.puts("[User #{user_id}]: #{message}")
    loop.(loop)
  end
  defp handle_message(_, loop) do
    loop.(loop)
  end
end
