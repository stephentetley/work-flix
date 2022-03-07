
def main(_args: Array[String]): Int32 & Impure = 
    println("Running... ${Time/LocalTime.now()}");
    patch1() |> interpret |> println;
    patch2() |> interpret |> println;
    patch3() |> interpret |> println;
    0

type alias Patch = List[Instr]

pub enum Instr { 
    case New(String)
    case Delete
    case Change(String)
}

def patch1(): Patch = New("2017") :: Change("2020") :: Nil

def patch2(): Patch = Delete :: New("2017") :: Change("2020") :: Nil

def patch3(): Patch = Delete :: New("2017") :: Change("2020") :: Delete :: Nil

pub enum ValueState {
    case CreateLocal(String)
    case UpdateGlobal(String)
    case DeleteGlobal
    case DeleteLocal
}

instance ToString[ValueState] {
    pub def toString(x: ValueState): String = match x {
        case CreateLocal(s)     => "CreateLocal(${s})"
        case UpdateGlobal(s)    => "UpdateGlobal(${s})"
        case DeleteGlobal       => "DeleteGlobal"
        case DeleteLocal        => "DeleteLocal"
    }
}

def interpret(xs: Patch): Option[ValueState] = interpretFirst(xs)

/// Note
/// First interpretation is a special case as we can identify if we have a local
/// or global "variable".

def interpretFirst(xs: Patch): Option[ValueState] = match xs { 
    case Nil => None
    case New(s1)        :: rs => interpretRest(CreateLocal(s1), rs)
    case Change(s1)     :: rs => interpretRest(UpdateGlobal(s1), rs)
    case Delete         :: rs => interpretRest(DeleteGlobal, rs)
}

def interpretRest(st: ValueState, xs: Patch): Option[ValueState] = match xs { 
    case Nil            => Some(st)
    case New(s1)        :: rs => interpretRest(newValue(s1, st), rs)
    case Change(s1)     :: rs => interpretRest(changeValue(s1, st), rs)
    case Delete         :: rs => interpretRest(deleteValue(st), rs)
}

def newValue(x: String, st: ValueState): ValueState = match st {
    case CreateLocal(_)     => CreateLocal(x)
    case DeleteGlobal       => UpdateGlobal(x)
    case DeleteLocal        => CreateLocal(x)
    case UpdateGlobal(_)    => UpdateGlobal(x)      /// unreachable for valid patch sequence
}

def changeValue(x: String, st: ValueState): ValueState = match st {
    case CreateLocal(_)     => CreateLocal(x)
    case DeleteGlobal       => UpdateGlobal(x)      /// unreachable for valid patch sequence
    case DeleteLocal        => CreateLocal(x)      
    case UpdateGlobal(_)    => UpdateGlobal(x)
}

def deleteValue(st: ValueState): ValueState = match st {
    case CreateLocal(_)     => DeleteLocal
    case DeleteGlobal       => DeleteGlobal
    case DeleteLocal        => DeleteLocal
    case UpdateGlobal(_)    => DeleteGlobal
}
