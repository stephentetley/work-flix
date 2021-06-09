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

namespace PDT/Conveyor {

    use SheetIO/SheetParser.SheetParser;

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};

    /// Base is CVYR
    /// CVYRBC | CVYRCC | CVYRMISC | CVYRSC
    
    type alias ConveyorData = 
        { overallLength: String
        , overallWidth: String
        }

    pub def parseConveyorData(): SheetParser[ka1, ConveyorData] = 
        use SheetIO/SheetParser.{flatMap, return, gotoRow, find, row, literal, island};
        use PDT/Common.{rowKeyValue};
        let* _  = gotoRow(0);
        let* _  = find(row(literal("Dimension & Weight Data")));
        let* s1 = island(rowKeyValue("Overall length"));
        let* s2 = island(rowKeyValue("Overall width"));
        return({overallLength = s1
            , overallWidth = s2
        })


}
