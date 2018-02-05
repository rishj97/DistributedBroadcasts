# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule App do
def start(peer, my_num, max_messages, timeout) do
    IO.puts ["      App at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, rb, peer_pl_list} ->
            peer_data = for {peer, _} <- peer_pl_list, do: {peer, {0,0}}
            broadcast(peer, peer_data, max_messages, cur_time() + timeout, my_num, rb)
    end
end

defp broadcast(peer, peer_data, broadcasts_left, end_time, my_num, rb) do
    cond do
        cur_time() >= end_time ->
            stop_broadcasting(peer, my_num, peer_data)
        broadcasts_left > 0 ->
            receive do
                {:rb_deliver, peer_from, :broadcast_msg} ->
                    peer_data = receive_broadcast(peer_from, peer_data)
                    broadcast(peer, peer_data, broadcasts_left, end_time, my_num, rb)
            after
                # Incase nothing to be received
                0 ->
                    send rb, {:rb_broadcast, :broadcast_msg}
                    peer_data = send_broadcast(peer_data)
                    broadcast(peer, peer_data, broadcasts_left - 1, end_time, my_num, rb)
            end
        true ->
            receive do
                {:rb_deliver, peer_from, :broadcast_msg} ->
                    peer_data = receive_broadcast(peer_from, peer_data)
                    broadcast(peer, peer_data, broadcasts_left, end_time, my_num, rb)
            after
                # Recursive call to recheck timeout
                0 -> broadcast(peer, peer_data, broadcasts_left, end_time, my_num, rb)
            end
    end
end

defp stop_broadcasting(peer, num, peer_data) do
    # Display results
    str = for {_, stats} <- peer_data do
        " #{inspect(stats)}"
    end
    cond do
        num == 3 ->
            str = ["Killing peer - #{num}:"] ++ str
            IO.puts str
            send peer, {:kill_peer}
        true ->
            str = ["#{num}:"] ++ str
            IO.puts str
    end
end

defp send_broadcast(peer_data) do
    for {peer, {num_sent, num_received}} <- peer_data do
        {peer, {num_sent + 1, num_received}}
    end
end

defp receive_broadcast(peer_from, peer_data) do
    {_, {num_sent, num_received}} = List.keyfind(peer_data, peer_from, 0, nil)
    List.keyreplace(
        peer_data, peer_from, 0, {peer_from, {num_sent, num_received + 1}})
end

# Returns current time in milliseconds
defp cur_time() do
    :os.system_time(:millisecond)
end
end # module -----------------------
