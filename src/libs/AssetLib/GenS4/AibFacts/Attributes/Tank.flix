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

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{TankConstruction, 
        TankLevel, TankShape, UnitCapacityCum, UnitCentreDepthM, UnitDiameterM, 
        UnitLengthM, UnitSideDepthM, UnitSideDepthMaxM, UnitSideDepthMinM};


    /// Read from Aib file...


    pub def readTankData(src: XlsxSource): GenMonad[#{TankConstruction, TankLevel, TankShape,
                                                        UnitCapacityCum, UnitCentreDepthM, UnitDiameterM, 
                                                        UnitLengthM, UnitSideDepthM, 
                                                        UnitSideDepthMinM, UnitSideDepthMaxM | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(src, evalTank()))
        
    


    def evalTank(): NamedRowEvaluator[#{TankConstruction, TankLevel, TankShape,
                                        UnitCapacityCum, UnitCentreDepthM, UnitDiameterM,
                                        UnitLengthM, UnitSideDepthM, 
                                        UnitSideDepthMinM, UnitSideDepthMaxM | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(evalTankConstruction(), #{});
        let* c2 = withDefault(evalTankLevel(), #{});
        let* c3 = withDefault(evalTankShape(), #{});
        let* c4 = withDefault(evalUnitCapacityCum(), #{});
        let* c5 = withDefault(evalUnitCentreDepthM(), #{});
        let* c6 = withDefault(evalUnitDiameterM(), #{});
        let* c7 = withDefault(evalUnitLengthM(), #{});
        let* c8 = withDefault(evalUnitSideDepthM(), #{});
        let* c9 = withDefault(evalUnitSideDepthMaxM(), #{});
        let* c10 = withDefault(evalUnitSideDepthMinM(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6 <+> c7 <+> c8 <+> c9 <+> c10)




    def evalTankConstruction(): NamedRowEvaluator[#{TankConstruction | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Tank Construction", (x1, x2) -> #{ TankConstruction(x1, x2). })

    
    def evalTankLevel(): NamedRowEvaluator[#{TankLevel | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Tank Level", (x1, x2) -> #{ TankLevel(x1, x2). })



    def evalTankShape(): NamedRowEvaluator[#{TankShape | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Tank Shape", (x1, x2) -> #{ TankShape(x1, x2). })



    def evalUnitCapacityCum(): NamedRowEvaluator[#{UnitCapacityCum | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Capacity cum", (x1, x2) -> #{ UnitCapacityCum(x1, x2). })

    
    
    def evalUnitCentreDepthM(): NamedRowEvaluator[#{UnitCentreDepthM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Centre Depth m", (x1, x2) -> #{ UnitCentreDepthM(x1, x2). })


    
    def evalUnitDiameterM(): NamedRowEvaluator[#{UnitDiameterM | r}] =
        /// Note - double space in aib field name
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Diameter  m", (x1, x2) -> #{ UnitDiameterM(x1, x2). }) 

    
    def evalUnitLengthM(): NamedRowEvaluator[#{UnitLengthM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Length m", (x1, x2) -> #{ UnitSideDepthM(x1, x2). })
 
    
    
    def evalUnitSideDepthM(): NamedRowEvaluator[#{UnitSideDepthM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Side Depth m", (x1, x2) -> #{ UnitSideDepthM(x1, x2). })

    
    
    def evalUnitSideDepthMaxM(): NamedRowEvaluator[#{UnitSideDepthMaxM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Side Depth Max m", (x1, x2) -> #{ UnitSideDepthMaxM(x1, x2). })

    

    def evalUnitSideDepthMinM(): NamedRowEvaluator[#{UnitSideDepthMinM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Unit Side Depth Min m", (x1, x2) -> #{ UnitSideDepthMinM(x1, x2). })

}
