

def main(args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let ans = ValveReport/Phase2Main.main(args);
    Console.printLine("Done... ${Time/LocalTime.now()}");
    ans