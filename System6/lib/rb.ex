# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule RB do

def start(peer, app) do
    IO.puts ["      RB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, beb, peer_pl_list} ->
            send app, {:broadcast, self(), peer_pl_list}
            start_listening(peer, app, beb, [], 0)
    end
end

defp start_listening(peer, app, beb, received_msgs, cur_seq_no) do
    receive do
        {:rb_broadcast} ->
            send beb, {:beb_broadcast, peer, cur_seq_no}
            start_listening(peer, app, beb, received_msgs, cur_seq_no + 1)
        {:beb_deliver, peer_from, seq_no} ->
            cond do
                Enum.member?(received_msgs, {peer_from, seq_no}) ->
                    start_listening(peer, app, beb, received_msgs, cur_seq_no)
                true ->
                    send app, {:rb_deliver, peer_from}
                    send beb, {:beb_broadcast, peer_from, seq_no}
                    start_listening(peer, app, beb, received_msgs ++ [{peer_from, seq_no}], cur_seq_no)
            end
    end
end
end # module -----------------------
