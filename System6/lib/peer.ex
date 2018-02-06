# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule Peer do

def start(num, system, max_messages, timeout, reliability) do

    IO.puts ["      Peer at ", DNS.my_ip_addr()]
    app = spawn_link(App, :start, [self(), num, max_messages, timeout])
    rb = spawn_link(RB, :start, [self(), app])
    beb = spawn_link(BEB, :start, [self(), rb])
    pl = spawn_link(LPL, :start, [self(), beb, reliability])
    send system, {:pl, self(), pl}
end
end # module -----------------------
