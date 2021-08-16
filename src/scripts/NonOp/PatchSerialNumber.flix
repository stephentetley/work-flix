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

/// Improvement patch for serial number and P and I tag.

namespace AssetScripts/NonOp/PatchSerialNumber {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{SLEquipment};
    use AssetLib/GenS4/Patch.{EquipmentPatches};

    type alias AibExportTables = 
        { aibSerialNumbers: XlsxSource
        , aibPandiTags: XlsxSource
        }
    
    /// API is a fact loader and a translation function.
    /// It is two functions so we can load facts once, but translate multiple times 
    /// (e.g. if we have batches of SLEquipment)

    pub def loadFacts(src: AibExportTables): Result[#{SerialNumber, PandiTag | r}, String] & Impure = 
        use Result.flatMap;
        let* r1     = SheetIO/Reader.allNamedRelations(src.aibSerialNumbers, evalSerialNumber());
        let* r2     = SheetIO/Reader.allNamedRelations(src.aibPandiTags, evalPandiTag());
        Ok(r1 <+> r2)



    pub rel SerialNumberPatch(equiId: String, serialNumber: String, pandiTag: String)

    pub rel SerialNumber(equiId: String, serialNumber: String)
    
    pub rel PandiTag(equiId: String, pandiTag: String)

    pub rel HasSerialNumber(equiId: String)
    
    pub rel HasPandiTag(equiId: String)

    pub rel EquiWorkItem1(equiId: String)

    pub def patchSerialNumber(facts: #{SerialNumber, PandiTag, 
                                        HasSerialNumber, HasPandiTag, EquiWorkItem1, SerialNumberPatch | r}, 
                                    xs: List[SLEquipment]): Result[List[SLEquipment], String] & Impure = 
        use Result.flatMap;
        let patches = genManufacturerModelPatches(facts, xs);
        Ok(AssetLib/GenS4/Patch.softPatchEquipment(patches, xs))


    def genManufacturerModelPatches(db: #{SerialNumber, PandiTag, 
                                                HasSerialNumber, HasPandiTag, EquiWorkItem1, SerialNumberPatch | r}, 
                            xs: List[SLEquipment]): EquipmentPatches & Impure = 
        let rules = #{
            
            HasSerialNumber(equiId) :- SerialNumber(equiId, _).
            HasPandiTag(equiId) :- PandiTag(equiId, _).

            SerialNumberPatch(equiId, serialNumber, pandiTag) :- 
                EquiWorkItem1(equiId),
                SerialNumber(equiId, serialNumber),
                PandiTag(equiId, pandiTag).

            SerialNumberPatch(equiId, serialNumber, "") :- 
                EquiWorkItem1(equiId),
                SerialNumber(equiId, serialNumber),
                not HasPandiTag(equiId).

            SerialNumberPatch(equiId, "UNKNOWN", pandiTag) :- 
                EquiWorkItem1(equiId),
                PandiTag(equiId, pandiTag),
                not HasSerialNumber(equiId).

        };
        let workitems = makeWorkItems(xs);
        solve (workitems <+> db <+> rules) project SerialNumberPatch
            |> makeEquipmentPatches

    def makeWorkItems(xs: List[SLEquipment]): #{EquiWorkItem1 | r} = 
        Relation.foldMap(x1 -> #{ EquiWorkItem1(x1.equiId). }, xs)


    def makeEquipmentPatches(relns: #{SerialNumberPatch | r}): EquipmentPatches & Impure = 
        let mm = MutMap.empty();
        let insert1 = row -> { 
            let (equiId, serialNumber, pandiTag) = row;
            let update: SLEquipment -> SLEquipment = makePatch1(serialNumber, pandiTag);
            MutMap.put!(equiId, update, mm)            
        }; 
        query relns select (x,y,z) from SerialNumberPatch(x,y,z) 
            |> Array.foreach(insert1);
        mm


    def makePatch1(serialNumber: String, pandiTag: String, r1: SLEquipment): SLEquipment =
        {serialNumber = serialNumber, techIdentNo = pandiTag | r1}



    def evalSerialNumber(): NamedRowEvaluator[#{SerialNumber | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> Relation.whenNot(String.isEmpty(x2), #{ SerialNumber(x1, sciNumCheck(x2)). }))
            <&> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("Serial No")

 

    /// def longNumCheck(s: String): String = 
    ///     match Text/Regex/Pattern.compile("\\d{10,}") {
    ///         case Some(patt1) => if (Text/Regex.matches(s, patt1)) "#${s}" else sciNumCheck(s)
    ///         case None => bug!("Impossible")
    ///     }

    /// e.g 4.50137E+11
    def sciNumCheck(s: String): String = 
        let scipatt = "\\d{1}.\\d{1,}E\\+\\d{1,}";
        match Text/Regex/Pattern.compile(scipatt) {
            case Some(patt1) => if (Text/Regex.matches(s, patt1)) unsci(s) else s
            case None => bug!("Impossible")
        }

    /// TODO - probably add this functionality to SheetIO...
    def unsci(s: String): String = 
        import new java.math.BigDecimal(String) as newBigDecimal;
        import java.math.BigDecimal.longValueExact();
        try {
            let bd = newBigDecimal(s) as & Pure;
            let i = longValueExact(bd) as & Pure;
            ToString.toString(i)
        } catch {
            case _: ##java.lang.Exception => s
        }


    def evalPandiTag(): NamedRowEvaluator[#{PandiTag | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> Relation.whenNot(String.isEmpty(x2), #{ PandiTag(x1, x2). }))
            <&> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("P AND I Tag No")

}

