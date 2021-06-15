/*
 * Copyright 2021 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace AssetLib/PDT/Products/Conveyor {

    use SheetIO/SheetParser.SheetParser;

    use AssetLib/S4Lite/Datatypes.{SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};

    /// Base is CVYR
    /// CVYRBC | CVYRCC | CVYRMISC | CVYRSC

    /// Asset Type 

    /// Category = "M"
    /// objectType = "CVYR"
    
    pub def parseConveyor(equiId: String): SheetParser[ka1, (SLEquipment, List[SLEquiCharacteristic])] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* info = AssetLib/PDT/Equipment.parseEquipmentInfo(equiId, "M", "CVYR");
        let* chars = parseConveyorCharacteristics(equiId, info.assetType);
        return((info.body, chars))


    def parseConveyorCharacteristics(equiId: String, assetType: String): SheetParser[ka1, List[SLEquiCharacteristic]] = 
        use SheetIO/SheetParser.{flatMap, return};
        match conveyorClass(assetType) { 
            case "CVYRSC" => parseCVYRSC(equiId)
            case _ => return(Nil)
        }

    def conveyorClass(assetType: String): String = 
        match String.trim(String.toUpperCase(assetType)) {
            case "SCREW CONVEYOR" => "CVYRSC"
            case _ => "CVYRMISC"
        }



    pub def parseCVYRSC(equiId: String): SheetParser[ka1, List[SLEquiCharacteristic]] = 
        use SheetIO/SheetParser.{flatMap, return};
        let* c1 = getCVYR_DIAMETER_MM(equiId, "CVYRSC");
        let* c2 = getCVYR_LENGTH_MM(equiId, "CVYRSC");
        return(c1 :: c2 :: Nil)

    def getCVYR_DIAMETER_MM(equiId: String, className: String): SheetParser[ka1, SLEquiCharacteristic] = 
        use SheetIO/SheetParser.{flatMap, return, gotoRow, find, row, literal, island};
        use PDT/Common.{rowKeyValue};
        let* _  = gotoRow(0);
        let* _  = find(row(literal("Dimension & Weight Data")));
        let* s1 = island(rowKeyValue("Overall width"));
        return(
            { equiId = equiId
            , className = className
            , charName = "CVYR_DIAMETER_MM"
            , valueType = NumericInt
            , intCounterValue = 1
            , charValue = s1
            })

    def getCVYR_LENGTH_MM(equiId: String, className: String): SheetParser[ka1, SLEquiCharacteristic] = 
        use SheetIO/SheetParser.{flatMap, return, gotoRow, find, row, literal, island};
        use PDT/Common.{rowKeyValue};
        let* _  = gotoRow(0);
        let* _  = find(row(literal("Dimension & Weight Data")));
        let* s1 = island(rowKeyValue("Overall length"));
        return(
            { equiId = equiId
            , className = className
            , charName = "CVYR_LENGTH_MM"
            , valueType = NumericInt
            , intCounterValue = 1
            , charValue = s1
            })

        
}
