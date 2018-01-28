# Rishabh Jain(rj2315)

defmodule Peer do

def start(num, system, max_messages, timeout, reliability, ttl) do

    IO.puts ["      Peer at ", DNS.my_ip_addr()]
    app = spawn(App, :start, [num, max_messages, timeout])
    beb = spawn(BEB, :start, [app])
    pl = spawn(LPL, :start, [self(), beb, reliability])
    send system, {:pl, self(), pl}
    kill_process_after(cur_time() + ttl, app, beb, pl)
end

defp kill_process_after(kill_time, app, beb, pl) do
    cond do
        cur_time() >= kill_time ->
            Process.exit(beb, :kill)
            Process.exit(app, :kill)
            Process.exit(pl, :kill)
            Process.exit(self(), :kill)
        true ->
            kill_process_after(kill_time, app, beb, pl)
    end

end

defp cur_time() do
    :os.system_time(:millisecond)
end
end # module -----------------------
