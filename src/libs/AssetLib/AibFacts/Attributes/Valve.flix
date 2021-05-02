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


namespace AssetLib/AibFacts/Attributes/Valve {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue};



    /// Read from Aib file...


    pub def readValveData(sheetName: String, 
                                path: System.FilePath): Result[#{AibStringValue, AibFloatValue | r}, String] & Impure =
        AssetLib/AibFacts/Relations.readAibFacts(aibValve(), sheetName, path)
        
    


    pub def aibValve(): NamedRowEvaluator[#{AibStringValue, AibFloatValue | r}] =
        getAttributes( getValveType()
            :: getValveSizeMM()
            :: Nil
        )      

    /// Range max	Range min	Range unit	Signal max	Signal min	Signal unit

    pub def getValveType(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Valve Type", "VALVE_TYPE")

    pub def getValveSizeMM(): NamedRowEvaluator[#{AibFloatValue| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, throwError, getContentNamed, getFloat64Named}; 
        let* aibref = getContentNamed("Reference");
        let* size   = getFloat64Named("Size");
        let* units  = getContentNamed("Size Units");
        match decodeSizeMM(size, units) {
            case Some(sz) => return(#{ AibFloatValue(aibref, "VALVE_SIZE_MM", sz). })
            case None => throwError("getValveSizeMM")
        }

    def decodeSizeMM(size: Float64, units: String): Option[Float64] = match units { 
        case "MILLIMETRES" => Some(size)
        case "INCH" => Some(25.4f64 * size)
        case "UNKNOWN UNIT" => None
        case _ => None
    }

}
