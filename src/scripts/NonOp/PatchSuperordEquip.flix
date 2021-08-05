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



namespace AssetScripts/NonOp/PatchSuperordEquip {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.RowEvaluator;
    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{SLEquipment};
    use AssetLib/GenS4/Patch.{EquipmentPatches};

    type alias SuperordTables = 
        { aibReport: XlsxSource
        , ih08Export: XlsxSource
        }

    pub rel SuperordEquipPatch(workItemId: String, superordId: String)

    pub rel AibPliNumToParent(pliNum: String, parentPli: String)
    
    pub rel S4PliNumToEquiNum(pliNum: String, equiNum: String)

    
    pub rel WorkItemForSuperord(workItemId: String)

    /// API is a fact loader and a translation function.
    /// It is two functions so we can load facts once, but translate multiple times 
    /// (e.g. if we have batches of SLEquipment)

    pub def loadFacts(src: SuperordTables): Result[#{AibPliNumToParent, S4PliNumToEquiNum | r}, String] & Impure = 
        use Result.flatMap;
        let* r1     = SheetIO/Reader.allRelations(src.aibReport, evalAibPliNumToParent());
        let* r2     = SheetIO/Reader.allNamedRelations(src.ih08Export, evalS4PliNumToEquiNum());
        Ok(r1 <+> r2)


    pub def patchSuperordEquip(facts: #{AibPliNumToParent, S4PliNumToEquiNum, WorkItemForSuperord, SuperordEquipPatch | r}, 
                                    xs: List[SLEquipment]): Result[List[SLEquipment], String] & Impure = 
        use Result.flatMap;
        let patches = genSuperordEquipPatches(facts, xs);
        Ok(AssetLib/GenS4/Patch.softPatchEquipment(patches, xs))


    def genSuperordEquipPatches(db: #{AibPliNumToParent, S4PliNumToEquiNum, WorkItemForSuperord, SuperordEquipPatch | r}, 
                            xs: List[SLEquipment]): EquipmentPatches & Impure = 
        let rules = #{
            
            SuperordEquipPatch(workItemId, superordId) :- 
                WorkItemForSuperord(workItemId), 
                AibPliNumToParent(workItemId, aibParent),
                S4PliNumToEquiNum(aibParent, superordId).

        };
        let workitems = makeWorkItems(xs);
        solve (workitems <+> db <+> rules) project SuperordEquipPatch
            |> makeEquipmentPatches

    def makeWorkItems(xs: List[SLEquipment]): #{WorkItemForSuperord | r} = 
        let mkWorkItem1 = x1 -> #{ 
            WorkItemForSuperord(x1.equiId). 
        };
        List.foldLeft((ac, x1) -> ac <+> mkWorkItem1(x1), #{}, xs)


    def makeEquipmentPatches(relns: #{SuperordEquipPatch | r}): EquipmentPatches & Impure = 
        let mm = MutMap.empty();
        let insert1 = row -> { 
            let (equiId, superordEquip) = row;
            let update: SLEquipment -> SLEquipment = makePatch1(superordEquip);
            MutMap.put!(equiId, update, mm)            
        }; 
        query relns select (x,y) from SuperordEquipPatch(x,y) 
            |> Array.foreach(insert1);
        mm


    def makePatch1(superordEquip: String, r1: SLEquipment): SLEquipment =
        {superOrdinateEqui = superordEquip | r1}


    def evalAibPliNumToParent(): RowEvaluator[#{AibPliNumToParent | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((av1, cm1) -> 
            if ((av1 `String.startsWith` "PLI") and (cm1 `String.startsWith` "PLI"))
                #{ AibPliNumToParent(av1, cm1). }
            else
                #{})
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("CM") >>= getTrimmedContentAt)      /// PlantItemEquipReference


    def evalS4PliNumToEquiNum(): NamedRowEvaluator[#{S4PliNumToEquiNum | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> if (x2 `String.startsWith` "PLI") #{ S4PliNumToEquiNum(x1, x2). } else #{})
            <&> getTrimmedContentNamed("AI2 AIB Reference")
            <*> getTrimmedContentNamed("Equipment")

}

