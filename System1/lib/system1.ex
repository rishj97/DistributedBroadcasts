# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule System1 do
def main() do
    init_system(:local)
end

def main_net() do
    init_system(:docker)
end

defp init_system(env) do
    IO.puts ["Peer broadcast at ", DNS.my_ip_addr()]
    peer_list = for n <- 0..9 do
        case env do
            :local ->
                spawn(Peer, :start, [n])
            :docker ->
                Process.sleep(1000)
                DAC.node_spawn("peer", n, Peer, :start, [n])
        end
    end

    for peer <- peer_list do
        send peer, {:bind, peer_list}
    end

    for peer <- peer_list do
        send peer, {:broadcast, 1000, 1000}
    end
end
end # module -----------------------
