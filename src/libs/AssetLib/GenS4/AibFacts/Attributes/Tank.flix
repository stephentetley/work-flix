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


namespace AssetLib/GenS4/AibFacts/Attributes/Tank {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};


    /// Read from Aib file...


    pub def readTankData(src: XlsxSource): Result[#{TankConstruction, TankLevel, TankShape,
                                                        UnitCapacityCum, UnitCentreDepthM, UnitDiameterM, 
                                                        UnitLengthM, UnitSideDepthM, 
                                                        UnitSideDepthMinM, UnitSideDepthMaxM | r}, String] & Impure =
        AssetLib/GenS4/AibFacts/Utils.readAibFacts(aibTank(), true, src)
        
    


    pub def aibTank(): NamedRowEvaluator[#{TankConstruction, TankLevel, TankShape,
                                            UnitCapacityCum, UnitCentreDepthM, UnitDiameterM, 
                                            UnitLengthM, UnitSideDepthM, 
                                            UnitSideDepthMinM, UnitSideDepthMaxM | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getTankConstruction(), #{});
        let* c2 = withDefault(getTankLevel(), #{});
        let* c3 = withDefault(getTankShape(), #{});
        let* c4 = withDefault(getUnitCapacityCum(), #{});
        let* c5 = withDefault(getUnitCentreDepthM(), #{});
        let* c6 = withDefault(getUnitDiameterM(), #{});
        let* c7 = withDefault(getUnitLengthM(), #{});
        let* c8 = withDefault(getUnitSideDepthM(), #{});
        let* c9 = withDefault(getUnitSideDepthMaxM(), #{});
        let* c10 = withDefault(getUnitSideDepthMinM(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6 <+> c7 <+> c8 <+> c9 <+> c10)


    pub rel TankConstruction(aibref: String, construction: String)

    def getTankConstruction(): NamedRowEvaluator[#{TankConstruction | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Tank Construction", (aibref, ans) -> #{ TankConstruction(aibref, ans). })


    pub rel TankLevel(aibref: String, level: String)
    
    def getTankLevel(): NamedRowEvaluator[#{TankLevel | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Tank Level", (aibref, ans) -> #{ TankLevel(aibref, ans). })


    pub rel TankShape(aibref: String, shape: String)

    def getTankShape(): NamedRowEvaluator[#{TankShape | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Tank Shape", (aibref, ans) -> #{ TankShape(aibref, ans). })


    pub rel UnitCapacityCum(aibref: String, capacity: Float64)

    def getUnitCapacityCum(): NamedRowEvaluator[#{UnitCapacityCum | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Capacity cum", (aibref, ans) -> #{ UnitCapacityCum(aibref, ans). })

    
    pub rel UnitCentreDepthM(aibref: String, depth: Float64)
    
    def getUnitCentreDepthM(): NamedRowEvaluator[#{UnitCentreDepthM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Centre Depth m", (aibref, ans) -> #{ UnitCentreDepthM(aibref, ans). })


    pub rel UnitDiameterM(aibref: String, diameter: Float64)
    
    def getUnitDiameterM(): NamedRowEvaluator[#{UnitDiameterM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Diameter  m", (aibref, ans) -> #{ UnitDiameterM(aibref, ans). }) /// double space in aib field      

    pub rel UnitLengthM(aibref: String, length: Float64)
    
    def getUnitLengthM(): NamedRowEvaluator[#{UnitLengthM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Length m", (aibref, ans) -> #{ UnitSideDepthM(aibref, ans). })
 
    
    pub rel UnitSideDepthM(aibref: String, depth: Float64)
    
    def getUnitSideDepthM(): NamedRowEvaluator[#{UnitSideDepthM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Side Depth m", (aibref, ans) -> #{ UnitSideDepthM(aibref, ans). })

    
    pub rel UnitSideDepthMaxM(aibref: String, depth: Float64)
    
    def getUnitSideDepthMaxM(): NamedRowEvaluator[#{UnitSideDepthMaxM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Side Depth Max m", (aibref, ans) -> #{ UnitSideDepthMaxM(aibref, ans). })

    
    pub rel UnitSideDepthMinM(aibref: String, depth: Float64)

    def getUnitSideDepthMinM(): NamedRowEvaluator[#{UnitSideDepthMinM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Side Depth Min m", (aibref, ans) -> #{ UnitSideDepthMinM(aibref, ans). })

}
