defmodule Chopstick do 

def start do
stick = spawn_link(fn -> init() end)
{:stick, stick}
end

defp init(), do: available() 

defp available() do

    receive do
    {:request, from} -> 
    send(from, :granted)
    gone(nil)

    {:request, ref, from} ->
    send(from, {:granted, ref})
    gone(ref)

    :quit -> :ok
    end
end

def gone(ref) do

    receive do
        ##:return -> available()

        {:return, ^ref} ->
        available()

        :quit -> :ok
        end
    end

def return({:stick, pid}, ref)do 
    send(pid, {:return,ref})
end

def quit({:stick, pid})do send(pid, :quit) end

def request({:stick, pid}, timeout) do
    send(pid,{:request, self()})
    receive do
    :granted -> :ok
    after 
    timeout -> :no

    end
end

def request({:stick, pid}, ref, timeout) do
    send(pid, {:request, ref, self()})
    wait(ref, timeout)
    end

def wait(ref, timeout) do
    receive do
    {:granted, ^ref} ->
    :ok

    {:granted,_} ->
    wait(ref, timeout)

    after 
    timeout -> :no
    end

end

end