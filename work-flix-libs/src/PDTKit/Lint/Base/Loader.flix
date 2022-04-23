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

namespace PDTKit/Lint/Base/Loader {

    use Functor.{<$>};
    use Applicative.{<*>, *>, point};
    
    use FlixSandbox/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/S4/ZTable/Datatypes.{ObjTypeManufacturer, ManufacturerModel};
    use PDTKit/Configuration/ReadAssetTypesCsv.{AssetTypeRow};    
    use PDTKit/Lint/Base/Schema.{PdtValueRow, MetaPdtAssetType, 
        ZObjTypeManufacturer, ZManufModel};

    pub type alias PDTLintSources = 
        { pdtDB :: FilePath
        , assetTypesCsv :: FilePath
        , ztableObjTypeManuf :: FilePath
        , ztableManuModel :: FilePath
        }


    pub type alias InputSchema[r1: SchemaRow] = #{PdtValueRow, MetaPdtAssetType, ZObjTypeManufacturer, ZManufModel | r1}

    pub def readAll(srcs: PDTLintSources): Result[InputSchema[r], String] & Impure = 
        BasicDb/DbMonad.runSQLite(extendDb() *> readAllDb(srcs), srcs.pdtDB)


    def extendDb(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap};
        let* _  = PDTKit/Configuration/ReadAssetTypesCsv.createMetaPdtAssetTypesTable();
        let* _  = AssetLib/FileIO/S4/ZTable/SQLite.createObjTypeManufacturerTable("ztable_objtype_manuf");
        let* _  = AssetLib/FileIO/S4/ZTable/SQLite.createManufacturerModelTable("ztable_manuf_model");
        point()


    pub def readAllDb(srcs: PDTLintSources): DbMonad[InputSchema[r]] = 
        ((x1, x2, x3, x4) -> x1 <+> x2 <+> x3 <+> x4)
            <$> readPdtValueRows()
            <*> readMetaPdtAssetTypes(srcs.assetTypesCsv)
            <*> readZObjTypeManufacturer(srcs.ztableObjTypeManuf)
            <*> readZManufModel(srcs.ztableManuModel)
        

    def readPdtValueRows(): DbMonad[#{PdtValueRow | r}] = 
        let sql = String.unlines(
                    "SELECT prv.source_file,  prv.row_num, prv.item_num, " 
                        :: "prv.asset_name,  prv.field_name, prv.field_value " 
                        :: "FROM pdt_raw_values prv; "
                        :: Nil
        );
        BasicDb/Reader.allRelations(evalPdtValueRow(), sql)


    def evalPdtValueRow(): RowEvaluator[#{PdtValueRow | r}] = 
        use BasicDb/RowEvaluator.{getStringAt, getInt32At};
        ((x1, x2, x3, x4, x5, x6) -> #{ PdtValueRow(x1, x2, x3, x4, x5, x6). })
            <$> getStringAt(0)  
            <*> getInt32At(1)
            <*> getInt32At(2)
            <*> getStringAt(3)
            <*> getStringAt(4)
            <*> getStringAt(5)

    /// From Configuration...
    
    def readMetaPdtAssetTypes(src: FilePath): DbMonad[#{MetaPdtAssetType | r}] = 
        PDTKit/Configuration/ReadAssetTypesCsv.readAndStoreAssetTypes(src)
            |> Functor.map(getMetaPdtAssetTypes)

    def getMetaPdtAssetTypes(l: List[AssetTypeRow]): #{MetaPdtAssetType | r} = 
        let make1 = x1 -> #{ MetaPdtAssetType(x1.pdtAssetType, x1.s4Category, x1.s4Object, x1.s4Class). };
        RelLib/Relation.foldMap(make1, l)
        
    /// From ZTables...

    def readZObjTypeManufacturer(src: FilePath): DbMonad[#{ZObjTypeManufacturer | r}] = 
        AssetLib/FileIO/S4/ZTable/SQLite.readAndStoreObjTypeManufacturer("ztable_objtype_manuf", src)
            |> Functor.map(getZObjTypeManufacturers)

    def getZObjTypeManufacturers(l: List[ObjTypeManufacturer]): #{ZObjTypeManufacturer | r} = 
        let make1 = x1 -> #{ ZObjTypeManufacturer(x1.objectType, x1.manufacturer). };
        RelLib/Relation.foldMap(make1, l)

    def readZManufModel(src: FilePath): DbMonad[#{ZManufModel | r}] = 
        AssetLib/FileIO/S4/ZTable/SQLite.readAndStoreManufacturerModel("ztable_manuf_model", src)
            |> Functor.map(getZManufModels)

    def getZManufModels(l: List[ManufacturerModel]): #{ZManufModel | r} = 
        let make1 = x1 -> #{ ZManufModel(x1.manufacturer, x1.model). };
        RelLib/Relation.foldMap(make1, l)

}
