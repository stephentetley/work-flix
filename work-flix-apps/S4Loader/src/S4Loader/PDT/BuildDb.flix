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

namespace S4Loader/PDT/BuildDb {

    use FlixSandbox/System.FilePath;
    use BasicDb.DbMonad;
    use PDTKit/Configuration/ReadFieldEvalSpecXlsx.{FieldEvalRow};
    use PDTKit/Configuration/ReadFieldValueEnumXlsx.{FieldValueEnumRow};
    use S4Loader/PDT/BuildDb/Schema.{FieldEvalSpec, FieldValueEnum};

    /// Create tables...
    pub def initDb(): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _  = S4Loader/Base/InitDb.createPropertiesTables();
        let* _  = S4Loader/Base/InitDb.createEquiClassListTables();
        let* _  = PDTKit/Configuration/ReadAssetTypesCsv.createMetaPdtAssetTypesTable();
        let* _  = PDTKit/Configuration/ReadFieldEvalSpecXlsx.createMetaPdtFieldEvaluatorsTable();
        let* _  = PDTKit/Configuration/ReadFieldValueEnumXlsx.createMetaPdtFieldValueEnumsTable();
        let* _  = PDTKit/Configuration/ReadOtoMappingsXlsx.createMetaPdtOtoMappingsTable();
        let* _  = S4Loader/Base/InitDb.createPdtViews();
        point()


    /// Load from PDT Db and metadata
    pub def storeMetaData(x: {equiClassList :: FilePath,
                                fieldEvals :: FilePath,
                                fieldValueEnums :: FilePath,
                                assetTypes :: FilePath,
                                otoMappings :: FilePath}): DbMonad[#{FieldEvalSpec, FieldValueEnum | r}] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = S4Loader/Base/InitDb.storeEquiClassListData(x.equiClassList);
        let* _          = PDTKit/Configuration/ReadAssetTypesCsv.readAndStoreAssetTypes(x.assetTypes);
        let* xs         = PDTKit/Configuration/ReadFieldEvalSpecXlsx.readAndStoreFieldEvalSpecs(x.fieldEvals);
        let evals       = RelLib/Relation.foldMap(makeFieldEvalSpec, xs);
        let* ys         = PDTKit/Configuration/ReadFieldValueEnumXlsx.readAndStoreFieldValueEnums(x.fieldValueEnums);
        let valEnums    = RelLib/Relation.foldMap(makeFieldValueEnum, ys);
        let* _          = PDTKit/Configuration/ReadOtoMappingsXlsx.readAndStoreOtoMappings(x.otoMappings);
        point(evals <+> valEnums)


    def makeFieldEvalSpec(r: FieldEvalRow): #{FieldEvalSpec | r} = 
        #{ FieldEvalSpec(r.pdtFieldName, r.pdtAssetClass, r.s4Type, r.evaluatorType, r.evaluator, r.builtinArg1). } 

    def makeFieldValueEnum(r: FieldValueEnumRow): #{FieldValueEnum | r} = 
        #{ FieldValueEnum(r.pdtFieldName, r.pdtAssetClass, r.pdtEnumValue, r.s4EnumValue). }


}
