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
 
/// TODO make this a proper `main` with GetOpt or JSON params etc.

namespace S4Loader/RunMakeLoaderDb {

    use Applicative.{*>};
    use BasicDb.DbMonad;
    use SheetIO/Reader.{XlsxSource};
    use S4Loader/Base/Schema.{S4Properties, StringProperty, IntProperty, FloatProperty};


    /// Needs a `PDT Db` built by PDT new reader (Asset Lib)

    /// Make Loader Db...
    pub def makeLoaderDb(_: Array[String]): Int32 & Impure = 
        use BasicDb/DbMonad.{runSQLite};
        println("Running S4Loader... ${Time/LocalTime.now()}");
        let metaSources = 
            { equiClassList = System/FilePath.new("G:/work/assets/facts/002-equi-class-list.txt")
            , fieldTypes = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_field_types.csv")
            , assetTypes = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_asset_types.csv")
            };
        let pdtDb = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt.sqlite");
        let dst = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-s4loader.sqlite");
        let overwrite = true;
        if (System/IO.fileExists(dst) != Ok(true) or overwrite == true)
            match runSQLite(buildDb(metaSources, pdtDb), dst) {
                case Ok(_) => println("Ok")
                case Err(e) => println("Error: ${e}")
            }
        else
            ();
        println("Done.");
        0



    def buildDb(metaSources: {equiClassList :: System.FilePath, 
                                fieldTypes :: System.FilePath,
                                assetTypes :: System.FilePath}, 
                pdtDb: System.FilePath): DbMonad[S4Properties[r1]] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _  = S4Loader/PDT/BuildDb.initDb();
        let* r1 = S4Loader/PDT/BuildDb.storeMetaData(metaSources);
        let* r2 = S4Loader/PDT/BuildDb/MakeProperties.readPDTRawValues(pathToPdtDb = pdtDb, "pdt_values_with_item_name");
        let ans = S4Loader/PDT/BuildDb/MakeProperties.genProperties(r1 <+> r2);
        let* _  = S4Loader/Base/StoreProperties.storeProperties(ans);
        point(ans)


}
