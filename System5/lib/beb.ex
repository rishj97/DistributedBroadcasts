# Rishabh Jain(rj2315)

defmodule BEB do

def start(app) do
    IO.puts ["      BEB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, pl, peer_pl_list} ->
            send app, {:broadcast, self(), peer_pl_list}
            start_listening(pl, app, peer_pl_list, [], 0)
    end
end

defp start_listening(pl, app, peer_pl_list, received_msgs, cur_seq_no) do
    receive do
        {:beb_broadcast} ->
            for {peer, _} <- peer_pl_list do
                send pl, {:pl_send, peer, cur_seq_no}
            end
            start_listening(pl, app, peer_pl_list, received_msgs, cur_seq_no + 1)
        {:pl_deliver, peer_from, seq_no} ->
            cond do
                Enum.member?(received_msgs, {peer_from, seq_no}) ->
                    start_listening(pl, app, peer_pl_list, received_msgs, cur_seq_no)
                true ->
                    send app, {:beb_deliver, peer_from}
                    start_listening(pl, app, peer_pl_list, received_msgs ++ [{peer_from, seq_no}], cur_seq_no)
            end
    end
end

end # module -----------------------
