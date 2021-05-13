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


namespace AssetLib/AibFacts/Attributes/Tank {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue, getFloatValue};



    /// Read from Aib file...


    pub def readTankData(sheetName: String, 
                                path: System.FilePath): Result[#{AibStringValue, AibFloatValue | r}, String] & Impure =
        AssetLib/AibFacts/Relations.readAibFacts(aibTank(), sheetName, path)
        
    


    pub def aibTank(): NamedRowEvaluator[#{AibStringValue, AibFloatValue | r}] =
        getAttributes( getTankConstruction()
            :: getTankLevel()
            :: getTankShape()
            :: getUnitCapacityCum()
            :: getUnitCentreDepthM()
            :: getUnitDiameterM()
            :: getUnitLengthM()
            :: getUnitSideDepthM()
            :: getUnitSideDepthMaxM()
            :: getUnitSideDepthMinM()
            :: Nil
        )      

    pub def getTankConstruction(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Tank Construction", "TANK_CONSTRUCTION")

    pub def getTankLevel(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Tank Level", "TANK_LEVEL")

    pub def getTankShape(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Tank Shape", "TANK_SHAPE")

    pub def getUnitCapacityCum(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Capacity cum", "UNIT_CAPACITY_CUM")

    pub def getUnitCentreDepthM(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Centre Depth m", "UNIT_CENTRE_DEPTH_M")

    pub def getUnitDiameterM(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Diameter  m", "UNIT_DIAMETER_M")      /// double space in aib field

    pub def getUnitLengthM(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Length m", "UNIT_LENGTH_M")
 
    pub def getUnitSideDepthM(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Side Depth m", "UNIT_SIDE_DEPTH_M")

    pub def getUnitSideDepthMaxM(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Side Depth Max m", "UNIT_SIDE_DEPTH_MAX_M")

    pub def getUnitSideDepthMinM(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Unit Side Depth Min m", "UNIT_SIDE_DEPTH_MIN_M")


}
