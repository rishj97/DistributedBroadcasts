# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule PL do
def start(peer, app) do
    IO.puts ["      PL at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, peer_pl_list} ->
            send app, {:broadcast, self(), peer_pl_list}
            next(peer, peer_pl_list, app, [], 0)
    end
end

defp next(peer, peer_pl_list, app, received_msgs, cur_seq_no) do
    receive do
        {:pl_send, peer_to, msg} ->
            {_, pl} = List.keyfind(peer_pl_list, peer_to, 0, nil)
            send pl, { :pl_deliver, peer, cur_seq_no, msg }
            next(peer, peer_pl_list, app, received_msgs, cur_seq_no + 1)
        {:pl_deliver, peer_from, seq_no, msg} ->
            cond do
                Enum.member?(received_msgs, {peer_from, seq_no}) ->
                    next(peer, peer_pl_list, app, received_msgs, cur_seq_no)
                true ->
                    send app, {:pl_deliver, peer_from, msg}
                    next(peer, peer_pl_list, app, received_msgs ++ [{peer_from, seq_no}], cur_seq_no)
            end
    end
end
end # module -----------------------
