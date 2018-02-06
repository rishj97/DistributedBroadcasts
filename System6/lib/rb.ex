# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule RB do

def start(peer, app) do
    IO.puts ["      RB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, beb, peer_pl_list} ->
            send app, {:broadcast, self(), peer_pl_list}
            received_msgs = Map.new(peer_pl_list, fn {p, _} -> {p, MapSet.new()} end)
            next(peer, app, beb, received_msgs, 0)
    end
end

# In this case, the rb module takes care of sequence number generation and not
# the pl
defp next(peer, app, beb, received_msgs, cur_seq_no) do
    receive do
        {:rb_broadcast, msg} ->
            send beb, {:beb_broadcast, {:rb_data, peer, {msg, cur_seq_no}}}
            next(peer, app, beb, received_msgs, cur_seq_no + 1)
        {:beb_deliver, _, {:rb_data, peer_from, {msg, _} = rb_m}} ->
            cond do
                MapSet.member?(received_msgs[peer_from], rb_m) ->
                    # Check if message already received.
                    next(peer, app, beb, received_msgs, cur_seq_no)
                true ->
                    send app, {:rb_deliver, peer_from, msg}

                    sender_msgs = MapSet.put(received_msgs[peer_from], rb_m)
                    received_msgs = Map.put(received_msgs, peer_from, sender_msgs)

                    # Re-broadcasting new message with the same sequence number
                    send beb, {:beb_broadcast, {:rb_data, peer_from, rb_m}}
                    next(peer, app, beb, received_msgs, cur_seq_no)
            end
    end
end
end # module -----------------------
