defmodule FD do # exclude on timeout
def start(rb, delay) do
    receive do
        {:broadcast, pl, peer_pl_list} ->
            Process.send_after(self(), :timeout, delay)
            peers = for {peer, _} <- peer_pl_list do
                peer
            end
            next(rb, pl, MapSet.new(peers), delay, MapSet.new(peers), MapSet.new())
    end
end

defp next(rb, pl, peers, delay, alive, detected) do
    receive do
        { :pl_deliver, from, :heartbeat_request } ->
            send pl, { :pl_send, from, :heartbeat_reply }
            next(rb, pl, peers, delay, alive, detected)
        { :pl_deliver, from, :heartbeat_reply } ->
            next(rb, pl, peers, delay, MapSet.put(alive, from), detected)
        :timeout ->
            more_detected =
                for p <- peers,
                    not MapSet.member?(alive, p) and
                    not MapSet.member?(detected, p) do
                        p
                end
            for p <- more_detected do
                send rb, { :pfd_crash, p }
            end
            for p <- alive, do: send pl, { :pl_send, p, :heartbeat_request }
            Process.send_after(self(), :timeout, delay)
            next(rb, pl, alive, delay, MapSet.new(), MapSet.union(detected, MapSet.new(more_detected)))
     end # receive
end # next
end
