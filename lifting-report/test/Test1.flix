use LiftingReport/Relations.{MemoLine, EquipmentInfo, EquiMatch, EquiProps};


def runResult(r1: Result[reln, FactIO.Error]): reln & Impure = match r1 {
    case Ok(reln) => reln
    case Err(e) => {
        Console.printLine(FactIO/Error.toString(e));
        #{ }
    }
}

@test
def test01(): String = 
    use LiftingReport/Common.{getEquipmentName};
    getEquipmentName("STATUTORY/LIFTING EQUIPMENT/YW46754 DAVIT JIB/EQUIPMENT: DAVIT")

@test
def test02(): String = 
    use LiftingReport/Common.{toProperCase};
    toProperCase("YW46754 DAVIT JIB")

@test
def test03(): #{ EquiProps | r } & Impure = 
    use Result.flatMap;
    let step = () -> {
        let* facts = LiftingReport/CsvLoader.importEquiMatches("G:/work/Projects/assets/lifting-equipment-reports/01.lifting_equipment_types.csv");
        let ans = LiftingReport/MakeReport.equipmentMatch("LIFTING EQUIPMENT/OV1 LIFTING FRAME/EQUIPMENT: BEAMS - LIFTING AND SPREADING", facts);
        Ok(ans)
    };
    step() |> runResult

@test
def load01(): #{MemoLine} & Impure =
    LiftingReport/CsvLoader.importMemoLines("G:/work/Projects/assets/lifting-equipment-reports/acomb-ai2-source1.csv")
        |> runResult    

@test
def load02(): #{EquipmentInfo} & Impure =
    LiftingReport/CsvLoader.importEquipmentInfo("G:/work/Projects/assets/lifting-equipment-reports/acomb-ai2-source2-serial-no-etc.csv")
        |> runResult          

@test
def load03(): #{EquiMatch} & Impure =
    LiftingReport/CsvLoader.importEquiMatches("G:/work/Projects/assets/lifting-equipment-reports/01.lifting_equipment_types.csv")
        |> runResult  