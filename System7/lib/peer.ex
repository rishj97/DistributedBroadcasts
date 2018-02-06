# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule Peer do

def start(num, system, max_messages, timeout, reliability, fd_delay) do

    IO.puts ["      Peer at ", DNS.my_ip_addr()]
    app = spawn(App, :start, [self(), num, max_messages, timeout])
    rb = spawn(LRB, :start, [self(), app])
    beb = spawn(BEB, :start, [self(), rb])
    fd = spawn(FD, :start, [rb, fd_delay])
    pl1 = spawn(LPL, :start, [self(), beb, reliability])
    pl2 = spawn(LPL, :start, [self(), fd, reliability])
    send system, {:pls, self(), pl1, pl2}

    receive do
        {:kill_peer} ->
            Process.exit(app, :kill)
            Process.exit(rb, :kill)
            Process.exit(beb, :kill)
            Process.exit(fd, :kill)
            Process.exit(pl1, :kill)
            Process.exit(pl2, :kill)
    end
end
end # module -----------------------
