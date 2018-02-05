# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule Peer do

def start(num, system, max_messages, timeout, reliability) do

    IO.puts ["      Peer at ", DNS.my_ip_addr()]
    app = spawn(App, :start, [self(), num, max_messages, timeout])
    rb = spawn(RB, :start, [self(), app])
    beb = spawn(BEB, :start, [self(), rb])
    pl = spawn(LPL, :start, [self(), beb, reliability])
    send system, {:pl, self(), pl}
    receive do
        {:kill_peer} ->
            Process.exit(beb, :kill)
            Process.exit(app, :kill)
            Process.exit(pl, :kill)
            Process.exit(self(), :kill)
    end
end
end # module -----------------------
