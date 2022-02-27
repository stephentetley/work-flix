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
    
    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/Configuration/PDT/ReadAssetTypesCsv.{AssetTypeRow};
    use PDTKit/Lint/Base/Schema.{PdtValueRow, MetaPdtAssetType};

    pub type alias PDTLintSources = 
        { pdtDB :: System.FilePath
        , assetTypesCsv :: System.FilePath
        , manuModelZTable :: System.FilePath
        }


    pub def readAll(srcs: PDTLintSources): Result[#{PdtValueRow, MetaPdtAssetType | r}, String] & Impure = 
        BasicDb/DbMonad.runSQLite(extendDb() *> readAllDb(srcs), srcs.pdtDB)


    def extendDb(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap};
        let* _  = AssetLib/FileIO/Configuration/PDT/ReadAssetTypesCsv.createMetaPdtAssetTypesTable();
        point()


    pub def readAllDb(srcs: PDTLintSources): DbMonad[#{PdtValueRow, MetaPdtAssetType | r}] = 
        ((x1, x2) -> x1 <+> x2)
            <$> readPdtValueRows()
            <*> readMetaPdtAssetTypes(srcs.assetTypesCsv)
        

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
    

    def readMetaPdtAssetTypes(src: System.FilePath): DbMonad[#{MetaPdtAssetType | r}] = 
        AssetLib/FileIO/Configuration/PDT/ReadAssetTypesCsv.readAndStoreAssetTypes(src)
            |> Functor.map(getMetaPdtAssetTypes)



    def getMetaPdtAssetTypes(l: List[AssetTypeRow]): #{MetaPdtAssetType | r} = 
        let make1 = x1 -> #{ MetaPdtAssetType(x1.pdtAssetType, x1.s4Category, x1.s4Object, x1.s4Class). };
        RelLib/Relation.foldMap(make1, l)
        


}
