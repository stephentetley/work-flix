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

namespace AutoLifting/ChildNew {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.{AibExportRow};
    use AssetLib/S4/Simple/Datatypes.{S4Equipment, LongText};



    type alias ChildNewPreparedStatements = 
        { selectLongText: PreparedStatement
        , selectS4SiteCode: PreparedStatement
        , selectParentRef: PreparedStatement
        , selectAibAttributes: PreparedStatement
        }

    /// Note table names are fixed - we have built a specific database for this task.

    pub def cachePreparedStatements(): DbMonad[ChildNewPreparedStatements] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* longText       = prepareLongTextQuery();
        let* siteCode       = prepareS4SiteCodeQuery();
        let* parentRef      = prepareParentAibReferenceQuery();
        let* aibAttributes  = AutoLifting/ChildNew/AibAttributes.prepareAibAttributesQuery();
        return(
            { selectLongText        = longText
            , selectS4SiteCode      = siteCode
            , selectParentRef       = parentRef
            , selectAibAttributes   = aibAttributes
            })


    /// Note - fresh name supply is outside DbMonad
    pub def childNew(pstmts: ChildNewPreparedStatements, reference: String, commonName: String, freshEquiId: String): DbMonad[S4Equipment] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        let* description        = liftActionResult(_ -> AutoLifting/ChildNew/DecodeCommonName.getS4DescriptionFromCommonName(commonName));
        let* longText           = getLongText(pstmts.selectLongText, reference, description);
        let* aibAttributes      = AutoLifting/ChildNew/AibAttributes.getAibAttributes(pstmts.selectAibAttributes, reference);
        return(
            { equiId            = freshEquiId
            , attributes        =
                { category              = panic("category")
                , description           = description
                , objectType            = panic("objectType")
                , startupDate           = aibAttributes.installedFrom
                , manufacturer          = aibAttributes.manufacturer
                , model                 = aibAttributes.model
                , partNumber            = aibAttributes.partNumber
                , serialNumber          = aibAttributes.serialNumber
                , constructionYear      = Time/LocalDate.getYear(aibAttributes.installedFrom)
                , constructionMonth     = Time/LocalDate.getMonth(aibAttributes.installedFrom)
                , maintPlant            = 2100
                , companyCode           = 2100
                , controllingArea       = 1000
                , planningPlant         = 1000
                , functionalLocation    = panic("functionalLocation")
                , superOridinateEqui    = ""
                , status                = "OPER"        
                }
            , longText          = longText
            , classifications   = Nil
            })

    /// Long text

    def getLongText(pstmt: PreparedStatement, reference: String, description: String): DbMonad[Option[LongText]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.putStringAt!(0,  reference));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("long_text"));
        let* _      = rsClose(rs);
        if (Object.isNull(x1)) 
            return(None) 
        else 
            return(Some({shortText = description, longText = x1}))

    def prepareLongTextQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    lt.long_text"
                :: "FROM wl_memo_lines lt"
                :: "WHERE "
                :: "    lt.reference = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)



    /// S4 Site Code

    pub def getS4SiteCode(pstmt: PreparedStatement, aibSiteName: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.putStringAt!(0,  aibSiteName));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("s4_level1_code"));
        let* _      = rsClose(rs);
        return(if (Object.isNull(x1)) "" else x1)

    def prepareS4SiteCodeQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.s4_level1_code"
                :: "FROM lookup_site t"
                :: "WHERE "
                :: "    t.installation_common_name = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    /// Parent AIb Reference

    pub def getParentAibReference(pstmt: PreparedStatement, equiCommonName: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, firstRow, rsClose};
        use AutoLifting/ChildNew/DecodeCommonName.{getAibParentNameFromCommonName};
        let* parent = liftActionResult(_ -> getAibParentNameFromCommonName(equiCommonName));
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.putStringAt!(0,  parent));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("reference"));
        let* _      = rsClose(rs);
        return(if (Object.isNull(x1)) "" else x1)

    def prepareParentAibReferenceQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.reference"
                :: "FROM wl_parent_refs t"
                :: "WHERE "
                :: "    t.asset_name = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

}