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

namespace AutoLifting/Build/ChildNew {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.{AibExportRow};
    use AssetLib/S4/Simple/Datatypes.{S4Equipment, LongText, Classification};



    type alias ChildNewPreparedStatements = 
        { selectLongText: PreparedStatement
        , selectS4SiteCode: PreparedStatement
        , selectParentRef: PreparedStatement
        , selectAibAttributes: PreparedStatement
        , selectTyDistinguished: PreparedStatement
        , selectTyOrdinary: PreparedStatement
        , selectWorkingLoad: PreparedStatement
        }

    /// Note table names are fixed - we have built a specific database for this task.

    pub def cachePreparedStatements(): DbMonad[ChildNewPreparedStatements] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* longText           = prepareLongTextQuery();
        let* siteCode           = prepareS4SiteCodeQuery();
        let* parentRef          = prepareParentAibReferenceQuery();
        let* aibAttributes      = AutoLifting/Build/ChildNew/AibAttributes.prepareAibAttributesQuery();
        let* tyDistinguished    = AutoLifting/Build/ChildNew/LiftingTypeMapping.prepareDistinguishedQuery();
        let* tyOrdinary         = AutoLifting/Build/ChildNew/LiftingTypeMapping.prepareOrdinaryQuery();
        let* workingLoad        = AutoLifting/Build/ChildNew/Classifications.prepareWorkingLoadQuery();
        return(
            { selectLongText        = longText
            , selectS4SiteCode      = siteCode
            , selectParentRef       = parentRef
            , selectAibAttributes   = aibAttributes
            , selectTyDistinguished = tyDistinguished
            , selectTyOrdinary      = tyOrdinary
            , selectWorkingLoad     = workingLoad
            })


    /// Note - fresh name supply is outside DbMonad
    pub def childNew(pstmts: ChildNewPreparedStatements, reference: String, commonName: String, freshEquiId: String): DbMonad[S4Equipment] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, liftResult};
        use AutoLifting/Build/ChildNew/Classifications.{getLiftingClassifications};
        let* description        = liftActionResult(_ -> AutoLifting/Build/ChildNew/DecodeCommonName.getS4DescriptionFromCommonName(commonName));
        let* aibEquiName        = liftActionResult(_ -> AutoLifting/Build/ChildNew/DecodeCommonName.getAibEquiNameFromCommonName(commonName));
        let* aibSiteName        = liftActionResult(_ -> AutoLifting/Build/ChildNew/DecodeCommonName.getAibSiteNameFromCommonName(commonName));
        let* aibEquiType        = liftActionResult(_ -> AutoLifting/Build/ChildNew/DecodeCommonName.getAibEquiTypeFromCommonName(commonName));
        let* flocRoot           = getS4SiteCode(pstmts, aibSiteName);
        let* longText           = getLongText(pstmts, reference, description);
        let* tymap              = AutoLifting/Build/ChildNew/LiftingTypeMapping.getTypeMapping(pstmts, aibEquiName, aibEquiType);
        let* aibAttributes      = AutoLifting/Build/ChildNew/AibAttributes.getAibAttributes(pstmts, reference);
        let funcLoc             = AutoLifting/Common/Utils.liftingFunctionalLocation(flocRoot, tymap.fixedOrPortable);
        let* parentRef          = getParentAibReference(pstmts, commonName);
        let aibReferences       = getAibReferenceClassifications(reference, parentRef);
        let* eastNorth          = liftResult(_ -> getEastingNorthingClassifications(aibAttributes.osgb36));
        let* liftings           = getLiftingClassifications(pstmts, tymap.s4Class, aibAttributes);
        return(
            { equiId            = freshEquiId
            , attributes        =
                { category              = tymap.category
                , description           = description
                , objectType            = tymap.s4Object
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
                , functionalLocation    = funcLoc
                , superOridinateEqui    = ""
                , status                = aibAttributes.assetStatus       
                }
            , longText          = longText
            , classifications   = aibReferences ::: eastNorth ::: liftings
            })

    /// Long text

    def getLongText[r](pstmts: {selectLongText: PreparedStatement| r}, reference: String, description: String): DbMonad[Option[LongText]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectLongText, BasicDb/PreparedStatementSetter.putStringAt!(0,  reference));
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

    pub def getS4SiteCode[r](pstmts: {selectS4SiteCode: PreparedStatement | r}, aibSiteName: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectS4SiteCode, BasicDb/PreparedStatementSetter.putStringAt!(0,  aibSiteName));
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
    def getEastingNorthingClassifications(gridRef: String): Result[List[Classification], System.Error] = 
        use Result.{flatMap};
        use AssetLib/Common/Osgb36.{parse, toEastingNorthing};
        let* ngr    = parse(gridRef);
        let* x      = toEastingNorthing(ngr);
        let c1      = {className = "EAST_NORTH", charName = "EASTING", datatype = "Int", value = Int32.toString(x.easting)};
        let c2      = {className = "EAST_NORTH", charName = "NORTHING", datatype = "Int", value = Int32.toString(x.northing)};
        Ok(c1 :: c2 :: Nil)


        
    /// Parent AIb Reference

    def getAibReferenceClassifications(reference: String, parentRef: String): List[Classification] = 
        let c1   = {className = "AIB_REFERENCE", charName = "AI2_AIB_REFERENCE", datatype = "Text", value = reference};
        let c2   = {className = "AIB_REFERENCE", charName = "AI2_AIB_REFERENCE", datatype = "Text", value = parentRef};
        let c3   = {className = "AIB_REFERENCE", charName = "S4_AIB_REFERENCE", datatype = "Text", value = ""};
        c1 :: c2 :: c3 :: Nil

    def getParentAibReference[r](pstmts: {selectParentRef: PreparedStatement |r}, equiCommonName: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, firstRow, rsClose};
        use AutoLifting/Build/ChildNew/DecodeCommonName.{getAibParentNameFromCommonName};
        let* parent = liftActionResult(_ -> getAibParentNameFromCommonName(equiCommonName));
        let* rs     = psExecuteQuery(pstmts.selectParentRef, BasicDb/PreparedStatementSetter.putStringAt!(0,  parent));
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