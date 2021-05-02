

def main(args: Array[String]): Int32 & Impure =  
    Console.printLine("Running... ${Time/LocalTime.now()}");
    let ans = ValveReport/Phase1Main.main1(args);
    Console.printLine("Done... ${Time/LocalTime.now()}");
    ans