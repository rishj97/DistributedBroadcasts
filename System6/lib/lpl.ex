# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule LPL do
def start(peer, beb, reliability) do
    IO.puts ["      PL at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, peer_pl_list} ->
            send beb, {:broadcast, self(), peer_pl_list}
            next(peer, peer_pl_list, beb, reliability)
    end
end

defp next(peer, peer_pl_list, beb, reliability) do
    receive do
        {:pl_send, peer_to, msg} ->
            {_, pl} = List.keyfind(peer_pl_list, peer_to, 0, nil)
            cond do
                # Use reliabilty value to discard/send messages randomly
                DAC.random(100) <= reliability ->
                    send pl, {:pl_deliver, peer, msg}
                true ->
                    nil
            end
        {:pl_deliver, peer_from, msg} ->
            # Since we're checking for duplicate messages in RB already,
            # we don't need to check again here.
            send beb, {:pl_deliver, peer_from, msg}
    end
    next(peer, peer_pl_list, beb, reliability)
end
end # module -----------------------
