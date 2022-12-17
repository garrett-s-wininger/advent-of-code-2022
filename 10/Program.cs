if (args.Length != 1)
{
    Console.Error.WriteLine("Usage: dotnet run <filepath>");
    Environment.Exit(1);
}

int cycle = 0;
int register = 1;
int signal = 0;

bool isMonitoredCycle(int cycle)
{
    return (cycle == 20 || ((cycle - 20) % 40 == 0));
}

void updateSignal(int cycle, int register, ref int signal)
{
    if (isMonitoredCycle(cycle))
    {
        signal += (cycle * register);
        Console.WriteLine($"Cycle {cycle}: {register} ({signal})");
    }
}

void noop(ref int cycle, ref int signal, int regsiter)
{
    ++cycle;
    updateSignal(cycle, register, ref signal);
}

void addx(int amount, ref int cycle, ref int signal, ref int register)
{
    ++cycle;
    updateSignal(cycle, register, ref signal);
    ++cycle;
    updateSignal(cycle, register, ref signal);
    register += amount;
}

using (StreamReader reader = new StreamReader(args[0]))
{
    string? line;

    while ((line = reader.ReadLine()) != null)
    {
        string[] instructionComponents = line.Split(" ");
        
        if (instructionComponents[0] == "noop")
        {
            noop(ref cycle, ref signal, register);
        }
        else
        {
            addx(int.Parse(instructionComponents[1]), ref cycle, ref signal, ref register);
        }
    }
}
