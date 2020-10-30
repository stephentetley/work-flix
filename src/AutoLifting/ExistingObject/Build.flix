/*
 * Copyright 2020 Stephen Tetley
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

namespace AutoLifting/ExistingObject/Build {

    use BasicDb.DbMonad;

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;
    use AutoLifting/Common.ReportMonad;

    type alias BuilderSource = 
        { equiFile: System.FilePath
        , classFile: System.FilePath
        , charFile: System.FilePath
        , mltextFile: System.FilePath
        , dbtempFile: System.FilePath
        }

    type alias S4LiftingItem = 
        { equi: EquiAtibutes
        , longText: String
        , classifications: List[Classification]
        }

    type alias EquiAttributes = 
        { equiId: String
        , category: String          /// Should always be "H" (probably)
        , description: String
        , objectType: String
        , startupDate: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , constructionYear: Int32
        , constructionMonth: Int32
        , maintPlant: Int32
        , companyCode: Int32
        , costCenter: Int32
        , planningPlant: Int32
        , functionalLocation: String
        , superOridinateEqui: String
        , status: String
        }

    type alias Classification = 
        { className: String
        , charName: String
        , value: String
        }

    pub def setupFacts(classFacts: System.FilePath, zTablePaths: ZTableSourcePaths, dbout: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/Common/ReportMonad.{liftActionResult};
        use BasicDb/DbMonad.{runSQLite};
        liftActionResult(_ -> runSQLite(setupFactsHelper(classFacts, zTablePaths), dbout))
        


    def setupFactsHelper(classFacts: System.FilePath, zTablePaths: ZTableSourcePaths): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/FileIO/ClassList/ExportDb.{defaultTableNames => classTableNames, storeEquiClassFile};
        use AssetLib/S4/FileIO/ZTable/ExportDb.{defaultTableNames => ztableNames, storeZTableFiles};
        let* _      = storeEquiClassFile(classTableNames(), true, classFacts, Text/Charset.iso_8859_1());
        let* _      = storeZTableFiles(ztableNames(), zTablePaths);
        return()


    pub def build(src: BuilderSource): ReportMonad[Unit] = 
        use AutoLifting/Common/ReportMonad.{flatMap, return, mapM, liftActionResult, liftAction};
        use AssetLib/S4/FileIO/DownloadFile/Evaluate.{allRows};
        use BasicDb/DbMonad.{runSQLite};
        let* xs = liftActionResult(_ -> allRows(equiRowEvaluator(), src.equiFile));
        let* _ = mapM(x -> liftAction(_ -> Console.printLine("${x.equiId} ${x.description}")), xs);
        let* _ = liftActionResult(_ -> runSQLite(buildSourceDb(src), src.dbtempFile));
        return()

    def buildSourceDb(src: BuilderSource): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeEqmltxtFile("eqmltext", true, src.mltextFile);
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeClassEquiFile("class_equi", true, src.classFile);
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeValuaEquiFile("valua_equi", true, src.charFile);
        return()



    /// TODO - this should be a builtin in the S4/FileTypes/DownloadFile namespace
    pub def equiRowEvaluator(): RowEvaluator[EquiAttributes] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getS4DateNamed, getInt32Named};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) ->
                { equiId                = x1
                , category              = x2
                , description           = x3
                , objectType            = x4
                , startupDate           = x5
                , manufacturer          = x6
                , model                 = x7
                , partNumber            = x8
                , serialNumber          = x9
                , constructionYear      = x10
                , constructionMonth     = x11
                , maintPlant            = x12
                , companyCode           = x13
                , costCenter            = x14
                , planningPlant         = x15
                , functionalLocation    = x16
                , superOridinateEqui    = x17
                , status                = x18
                })
            <&> getStringNamed("EQUI")                  /// Equipment ID
            <*> getStringNamed("EQTYP")                 /// Equipment Category
            <*> getStringNamed("TXTMI")                 /// Description (medium text)        
            <*> getStringNamed("EQART_EQU")             /// Object Type          
            <*> getS4DateNamed("INBDT")                 /// Startup Date
            <*> getStringNamed("HERST")                 /// Manufacturer
            <*> getStringNamed("TYPBZ")                 /// Model 
            <*> getStringNamed("MAPA_EEQZ")             /// Manufact Part No
            <*> getStringNamed("SERGE")                 /// Manufact Serial Number
            <*> getInt32Named("BAUJJ")                  /// Construction year
            <*> getInt32Named("BAUMM_EQI")              /// Construction month
            <*> getInt32Named("SWER_EILO")              /// Maintenance Plant
            <*> getInt32Named("BUKR_EILO")              /// Company Code
            <*> getInt32Named("KOST_EILO")              /// Cost Center
            <*> getInt32Named("PPLA_EEQZ")              /// Planning Plant
            <*> getStringNamed("TPLN_EILO")             /// Functional Location
            <*> getStringNamed("HEQU_EEQZ")             /// Superord Equipment
            <*> getStringNamed("USTW_EQUI")             /// Status of an object

}