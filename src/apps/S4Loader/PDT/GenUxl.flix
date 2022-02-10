/*
 * Copyright 2022 Stephen Tetley
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

namespace S4Loader/PDT/GenUxl {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{UxlOutput, SLFunctionalLocation};
    use AssetLib/S4Lite/S4LiteRelations.{EquiLongText, EquiCharacteristic};
    
    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty, PropertyAlias, EquiObjectClass};
    use S4Loader/PDT/Gen/ReadDb.{PersistentRelations};
    use S4Loader/PDT/Gen/WorkList.{EquiWorkItemRow, EquiWorkItem};


    /// Returns a Map of the batches - may be sparse.
    pub def genEquiUxlBatches(dbpath: System.FilePath, worklist: XlsxSource): Result[Map[Int32, UxlOutput], String] & Impure =
        use Result.{flatMap};
        let* workitems      = S4Loader/PDT/Gen/WorkList.readEquiWorkList(worklist);
        let groups          = List.foldLeft((m, x1) -> Map.insertWith(Chain.append, x1.batchNumber, Chain.singleton(x1), m), 
                                            Map.empty(), workitems);
        let* db             = BasicDb/DbMonad.runSQLite(S4Loader/PDT/Gen/ReadDb.readDbAll(), dbpath);                                          
        let output          = Map.map(Chain.toList >> genUxl1(db), groups);
        Ok(output)

    /// This is a union of all relations used - it needs updating every time a new relation / lattice
    /// is added to the Rules - this is a pain, hopefully Flix gets extended with input output types for relations...
    type alias UnionSchema[r1: SchemaRow] = 
        #{EquiLongText, EquiCharacteristic, EquiWorkItem, PropertyAlias, EquiObjectClass, 
            StringProperty, IntProperty, FloatProperty, DateProperty,
            S4Loader/PDT/Rules/EquiAttributes.EquiAttributes
            | r1}

    def genUxl1(dbrelns: PersistentRelations[r1], workitems: List[EquiWorkItemRow]): UxlOutput & Impure =
        let dbrelns1        = dbrelns as UnionSchema[r1];
        let r1              = S4Loader/PDT/Gen/WorkList.genEquiWorkItems(workitems);
        let db              = dbrelns1 <+> r1
                                <+> S4Loader/PDT/Rules/EquiCommon.equiCommon() 
                                <+> S4Loader/PDT/Rules/EquiCharacteristics.equiCharacteristics()
                                /// <+> S4Loader/PDT/Rules/EquiLongText.equiLongText()
                                <+> S4Loader/PDT/Rules/EquiAttributes.equiAttributes();
        let equiMemos       = (solve db project EquiLongText) |> AssetLib/S4Lite/S4LiteRelations.toSLEquiLongTexts;
        let equiChars       = (solve db project EquiCharacteristic) |> AssetLib/S4Lite/S4LiteRelations.toSLEquiCharacteristics;
        let uxl             = AssetLib/S4Lite/Datatypes.emptyUxlOutput();
        {equipment = Chain.empty(), equiLongTexts = equiMemos, equiCharacteristics = equiChars | uxl}

}
