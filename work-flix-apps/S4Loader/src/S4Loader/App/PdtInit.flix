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
 
/// Makes `PDT db` (pdt_files.sqlite) and `S4 Loader db` (s4loader.sqlite)...

namespace S4Loader/App/PdtInit {

    use Applicative.{*>};
    use BasicDb.DbMonad;
    use SheetIO/Reader.{XlsxSource};
    use S4Loader/Base/Schema.{S4Properties, StringProperty, IntProperty, FloatProperty};


    /// Needs a `PDT Db` built by PDT new reader (Asset Lib)
    pub def makePdtDb(): Result[Bool, String] & Impure =
        use Result.flatMap;
        let* srcdir     = S4Loader/App/Config.getWorkingDirectory() |> Result.map(flip(System/FilePath.snoc, "pdts"));
        let srcs        = 
            System/Directory.contents(srcdir) 
                |> Result.getWithDefault(Nil) 
                |> List.filter(x -> System/FilePath.getExtension(x) == Some("xlsx"));    
        let* dst        = S4Loader/App/Config.getS4LoaderDirectory() |> Result.map(flip(System/FilePath.snoc, "pdt_files.sqlite"));        
        let* _          = AssetLib/FileIO/PDT/SQLite.createPDTDatabase(srcs, dst);
        Ok(true)


    /// Make Loader Db...
    pub def makeLoaderDb(): Result[Bool, String] & Impure =
        use Result.flatMap;
        use BasicDb/DbMonad.{runSQLite};
        let* configSources  = getConfigSources();
        let* s4dir          = S4Loader/App/Config.getS4LoaderDirectory();
        let pdtDb           = System/FilePath.snoc(s4dir, "pdt_files.sqlite");
        let dst             = System/FilePath.snoc(s4dir, "s4loader.sqlite");
        let* _              = runSQLite(buildLoaderDb(configSources, pdtDb), dst);
        Ok(true)


    type alias ConfigSources = 
        { equiClassList :: System.FilePath
        , fieldEvals :: System.FilePath
        , assetTypes :: System.FilePath
        , otoMappings :: System.FilePath
        }
         

    def getConfigSources(): Result[ConfigSources, String] & Impure= 
        use Result.flatMap;
        let* cfgpath    = S4Loader/App/Config.getAppConfigPath();
        Ok({ equiClassList  = System/FilePath.snoc(cfgpath, "002-equi-class-list.txt")
            , fieldEvals    = System/FilePath.snoc(cfgpath, "pdt_field_eval_specifications.xlsx")
            , assetTypes    = System/FilePath.snoc(cfgpath, "pdt_asset_types.csv")
            , otoMappings   = System/FilePath.snoc(cfgpath, "s4_to_pdt_one_to_one_mapping.xlsx")
            })
        

    def buildLoaderDb(metaSources: ConfigSources, pdtDb: System.FilePath): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* _  = S4Loader/PDT/BuildDb.initDb();
        let* r1 = S4Loader/PDT/BuildDb.storeMetaData(metaSources);
        let* r2 = S4Loader/PDT/BuildDb/MakeProperties.readPDTRawValues(pathToPdtDb = pdtDb, "pdt_values_with_item_name");
        let ans = S4Loader/PDT/BuildDb/MakeProperties.genProperties(r1 <+> r2);
        let* _  = S4Loader/PDT/BuildDb/StoreProperties.storeProperties(ans);
        point()


}
