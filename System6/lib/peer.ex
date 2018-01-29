# Rishabh Jain(rj2315)

defmodule Peer do

def start(num, system, max_messages, timeout, reliability, ttl) do

    IO.puts ["      Peer at ", DNS.my_ip_addr()]
    app = spawn(App, :start, [num, max_messages, timeout])
    beb = spawn(BEB, :start, [app])
    pl = spawn(LPL, :start, [self(), beb, reliability])
    send system, {:pl, self(), pl}
    kill_peer_after(ttl, app, beb, pl)
end

defp kill_peer_after(ttl, app, beb, pl) do
    Process.sleep(ttl)
    Process.exit(beb, :kill)
    Process.exit(app, :kill)
    Process.exit(pl, :kill)
    Process.exit(self(), :kill)
end
end # module -----------------------
