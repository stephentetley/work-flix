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


/// Build equipment from Download files + stored facts

namespace AssetLib/S4Lite/CreateNew/EquiSetupDb {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;

    use AssetLib/S4Lite/CreateNew/Datatypes.{S4Equipment, EquiAttributes, LongText, Classification};
    use AssetLib/S4Lite/CreateNew/BuildCommon.{evalClassification, evalLongText};

    /// TODO this is common for Floc and Equi so here isn't the right place...
    pub def setupFacts(classFacts: System.FilePath, zTablePaths: ZTableSourcePaths): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/FileIO/ClassList/ExportDb.{defaultTableNames => classTableNames, storeEquiClassFile};
        use AssetLib/S4/FileIO/ZTable/ExportDb.{defaultTableNames => ztableNames, storeZTableFiles};
        let* _      = storeEquiClassFile(classTableNames(), true, classFacts, Text/Charset.iso_8859_1());
        let* _      = storeZTableFiles(ztableNames(), zTablePaths);
        return()


    type alias EquiBuilderSources = 
        { equiFile: System.FilePath
        , classFile: System.FilePath
        , charFile: System.FilePath
        , mltextFile: System.FilePath
        }


    pub def buildS4EquipmentList(sources: EquiBuilderSources): DbMonad[List[S4Equipment]] = 
        use BasicDb/DbMonad.{flatMap, return, mapM, liftActionResult, liftAction};
        use AssetLib/S4/FileIO/DownloadFile/Evaluate.{allRows};
        let* _      = buildSourceDb(sources);
        let* xs     = liftActionResult(_ -> allRows(equiRowEvaluator(), sources.equiFile));
        let* ys     = buildS4LiftingItems(xs);
        return(ys)

    def buildSourceDb(sources: EquiBuilderSources): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeEqmltxtFile("eqmltxt", true, sources.mltextFile);
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeClassEquiFile("class_equi", true, sources.classFile);
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeValuaEquiFile("valua_equi", true, sources.charFile);
        return()


    def buildS4LiftingItems(xs: List[{equiId: String, attrs: EquiAttributes}]): DbMonad[List[S4Equipment]] = 
        use BasicDb/DbMonad.{flatMap, return, mapM};
        let* ltps   = prepareEquiLongTextQuery();
        let* clps   = prepareEquiClassificationsQuery();
        let* ys     = mapM(buildS4Equipment1(ltps, clps), xs);
        return(ys)

    def buildS4Equipment1(ltps: PreparedStatement, clps: PreparedStatement, x: {equiId: String, attrs: EquiAttributes}): DbMonad[S4Equipment] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* longText   = getEquiLongText(ltps, x.equiId);
        let* cs         = getEquiClassifications(clps, x.equiId);
        return(
            { equiId            = x.equiId
            , attributes        = x.attrs
            , longText          = longText
            , classifications   = cs
            })


    def equiRowEvaluator(): RowEvaluator[{equiId: String, attrs: EquiAttributes}] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getS4DateNamed, getInt32Named};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19) ->
                { equiId                = x1
                , attrs = 
                    { category              = x2
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
                    , superOrdinateEqui     = x17
                    , techIdentNo           = x18
                    , status                = x19
                    }
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
            <*> getStringNamed("TIDN_EEQZ")             /// Superord Equipment
            <*> getStringNamed("USTW_EQUI")             /// Status of an object


    /// Classification
    def prepareEquiClassificationsQuery(): DbMonad[PreparedStatement] = 
        BasicDb/DbMonad.prepareStatement(getEquiClassificationsSql())

    def getEquiClassifications(pstmt: PreparedStatement, equiId: String): DbMonad[List[Classification]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* rs     = psExecuteQuery(pstmt, setEquiClassificationPStmt!(equiId));
        let* xs     = allRows(rs, evalClassification());
        let* _      = rsClose(rs);
        return(xs)

    def getEquiClassificationsSql(): String  = 
        String.unwords(
               "SELECT"
            :: "    c.class_name, cfm.charname, cfcd.datatype, v.value_description, v.value_from"
            :: "FROM"
            :: "    class_equi c"
            :: "INNER JOIN  cf_members cfm      ON c.class_name = cfm.classname"
            :: "JOIN        cf_char_defs cfcd   ON cfm.charname = cfcd.charname"
            :: "JOIN        valua_equi v        ON c.equi = v.equi AND cfm.charname = v.char_id"
            :: "WHERE"
            :: "    c.equi = ?"
            :: "AND cfm.classtype = 'equi'"
            :: "AND cfcd.classtype = 'equi'"
            :: "ORDER BY c.class_name;"
            :: Nil
        )

    def setEquiClassificationPStmt!(equiId: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  equiId)

    /// Long Text
    pub def prepareEquiLongTextQuery(): DbMonad[PreparedStatement] = 
        BasicDb/DbMonad.prepareStatement(getEquiLongTextSql())

    pub def getEquiLongText(pstmt: PreparedStatement, equiId: String): DbMonad[Option[LongText]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, optional, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, setEquiLongTextPStmt!(equiId));
        let* ans    = optional(firstRow(rs, evalLongText()));
        let* _      = rsClose(rs);
        return(ans)

    def getEquiLongTextSql(): String  = 
        String.unwords(
               "SELECT"
            :: "    t.short_text, t.long_text"
            :: "FROM"
            :: "    eqmltxt t"
            :: "WHERE"
            :: "    t.equi = ?;"
            :: Nil
        )

    def setEquiLongTextPStmt!(equiId: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  equiId)

}