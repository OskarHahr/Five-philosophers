defmodule Philosopher do

@dream 1000
@eat 50
@delay 200
@timeout 5000

def start(hunger, right, left, name, ctrl)do 
     spawn_link(fn -> init(hunger, right, left, name, ctrl) end)
end

defp init(hunger, right, left, name, ctrl)do 
     dreaming(hunger, right, left, name, ctrl)

end

def dreaming(0, right, left, name, ctrl)do 
IO.puts("#{name} is full")
send(ctrl, :done)
end
def dreaming(10, right, left, name, ctrl)do
IO.puts("#{name} starved to death!***************")
send(ctrl, :done)
end
def dreaming(hunger, right, left, name, ctrl) do 
    IO.puts("#{name} is dreaming, hunger is #{hunger}")
    sleep(@dream)
    waiting(hunger, right, left, name, ctrl)
end

def waiting(hunger, left, right, name, ctrl) do 
IO.puts("#{name} is waiting, at #{hunger} hunger")
    ref = make_ref()
    case Chopstick.request(left, ref, @timeout)do
        :ok ->
            sleep(@delay)
            case Chopstick.request(right, ref, @timeout)do
                :ok -> 
                IO.puts("#{name} received two chopsticks")
                eating(hunger, ref, left, right, name, ctrl)
            
                :no -> 
                IO.puts("#{name} did not receieve right chopstick!")
                Chopstick.return(left, ref)
                Chopstick.return(right, ref)
                dreaming(hunger, right, left, name, ctrl)
                end

        :no -> IO.puts("#{name} did not receive left chopstick!")
        Chopstick.return(left, ref)
        dreaming(hunger,right,left,name,ctrl)
    end

end

def eating(hunger, ref, left, right, name , ctrl) do
IO.puts("#{name} is eating!")
sleep(@eat)
Chopstick.return(left, ref)
IO.puts ("#{name} returned left chopstick")
Chopstick.return(right, ref)
IO.puts ("#{name} returned right chopstick")
dreaming(hunger-1, left, right, name, ctrl)
end

def sleep(0) do :ok end
def sleep(t) do
    :timer.sleep(:rand.uniform(t))
end



end