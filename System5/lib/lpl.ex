# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule LPL do
def start(peer, beb, reliability) do
    IO.puts ["      PL at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, peer_pl_list} ->
            send beb, {:broadcast, self(), peer_pl_list}
            next(peer, peer_pl_list, beb, reliability, [], 0)
    end
end

defp next(peer, peer_pl_list, beb, reliability, received_msgs, cur_seq_no) do
    receive do
        {:pl_send, peer_to, msg} ->
            {_, pl} = List.keyfind(peer_pl_list, peer_to, 0, nil)
            cond do
                # Use reliabilty value to discard/send messages randomly
                DAC.random(100) <= reliability ->
                    send pl, { :pl_deliver, peer, cur_seq_no, msg }
                true ->
                    nil
            end
            next(peer, peer_pl_list, beb, reliability, received_msgs, cur_seq_no + 1)
        {:pl_deliver, peer_from, seq_no, msg} ->
            cond do
                Enum.member?(received_msgs, {peer_from, seq_no}) ->
                    # If message already received
                    next(peer, peer_pl_list, beb, reliability, received_msgs, cur_seq_no)
                true ->
                    send beb, {:pl_deliver, peer_from, msg}
                    next(peer, peer_pl_list, beb, reliability, received_msgs ++ [{peer_from, seq_no}], cur_seq_no)
            end
    end

end
end # module -----------------------
