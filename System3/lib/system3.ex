# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule System3 do
def main() do
    init_system(:local)
end

def main_net() do
    init_system(:docker)
end

defp init_system(env) do
    IO.puts ["BEB broadcast at ", DNS.my_ip_addr()]
    peer_list = for n <- 0..9 do
        case env do
            :local ->
                spawn(Peer, :start, [n, self(), 1000, 10000])
            :docker ->
                Process.sleep(1000)
                DAC.node_spawn("peer", n, Peer, :start, [n, self(), 10, 10000])
        end
    end

    peer_pl_list = for _ <- peer_list do
        receive do
            {:pl, peer, pl} -> {peer, pl}
        end
    end

    for {_, pl} <- peer_pl_list do
        send pl, {:broadcast, peer_pl_list}
    end
end
end # module -----------------------
