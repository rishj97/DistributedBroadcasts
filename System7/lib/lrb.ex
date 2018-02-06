# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule LRB do

def start(peer, app) do
    IO.puts ["      RB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, beb, peer_pl_list} ->
            send app, {:broadcast, self(), peer_pl_list}
            peers = Enum.map(peer_pl_list, fn {p, _} -> p end)
            peer_msgs = Map.new(peers, fn p -> {p, MapSet.new()} end)

            next(peer, app, beb, peer_msgs, MapSet.new(peers), 0)
    end
end

# In this case, the rb module takes careof sequence number generation and not
# the pl
defp next(peer, app, beb, peer_msgs, peers, cur_seq_no) do
    receive do
        {:rb_broadcast, msg} ->
            send beb, {:beb_broadcast, {:rb_data, peer, {msg, cur_seq_no}}}
            next(peer, app, beb, peer_msgs, peers, cur_seq_no + 1)
        {:pfd_crash, crashedP} ->
            for m <- peer_msgs[crashedP], do:
                send beb, {:beb_broadcast, {:rb_data, crashedP, m}}
            next(peer, app, beb, peer_msgs, MapSet.delete(peers, crashedP), cur_seq_no)
        {:beb_deliver, _, {:rb_data, peer_from, {msg, _} = rb_m}} ->
            cond do
                MapSet.member?(peer_msgs[peer_from], rb_m) ->
                    # Check if message already received.
                    next(peer, app, beb, peer_msgs, peers, cur_seq_no)
                true ->
                    send app, {:rb_deliver, peer_from, msg}
                    sender_msgs = MapSet.put(peer_msgs[peer_from], rb_m)
                    peer_msgs = Map.put(peer_msgs, peer_from, sender_msgs)

                    # Re-broadcasting new message with the same sequence number
                    unless Enum.member?(peers, peer_from) do
                        send beb, {:beb_broadcast, {:rb_data, peer_from, rb_m}}
                    end
                    next(peer, app, beb, peer_msgs, peers, cur_seq_no)
            end
    end
end
end # module -----------------------
