/*
 * Copyright 2021 Stephen Tetley
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

namespace NewLiftingItems/MakeReport/ChildNew {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/Aib/AideChangeSummary/Datatypes.{AibExportRow};
    use NewLiftingItems/Base/Datatypes.{LiftingEquipment};



    type alias ChildNewPreparedStatements = 
        { selectLongText: PreparedStatement
        , selectS4SiteCode: PreparedStatement
        , selectParentRef: PreparedStatement
        , selectCommonName: PreparedStatement
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
        let* commonName         = prepareCommonNameQuery();
        let* aibAttributes      = NewLiftingItems/MakeReport/BuildItems/AibAttributes.prepareAibAttributesQuery();
        let* tyDistinguished    = NewLiftingItems/MakeReport/BuildItems/LiftingTypeMapping.prepareDistinguishedQuery();
        let* tyOrdinary         = NewLiftingItems/MakeReport/BuildItems/LiftingTypeMapping.prepareOrdinaryQuery();
        let* workingLoad        = NewLiftingItems/MakeReport/BuildItems/WorkingLoadFields.prepareWorkingLoadQuery();
        return(
            { selectLongText        = longText
            , selectS4SiteCode      = siteCode
            , selectParentRef       = parentRef
            , selectCommonName      = commonName
            , selectAibAttributes   = aibAttributes
            , selectTyDistinguished = tyDistinguished
            , selectTyOrdinary      = tyOrdinary
            , selectWorkingLoad     = workingLoad
            })


    /// Note - fresh name supply is outside DbMonad
    pub def childNew(pstmts: ChildNewPreparedStatements, reference: String, freshEquiId: String): DbMonad[LiftingEquipment] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, liftResult, liftOption};
        use AssetLib/S4Lite/CreateNew/Classifications.{append, getClassifications};
        use NewLiftingItems/Base/Utils.{getEastingNorthing, liftingFunctionalLocation};
        use NewLiftingItems/MakeReport/BuildItems/WorkingLoadFields.{getWorkingLoadFields};
        let* commonName         = getCommonName(pstmts, reference);
        let* description        = liftOption(NewLiftingItems/Base/DecodeCommonName.getS4Description(commonName), "getS4Description('${commonName}')");
        let* aibEquiName        = liftOption(NewLiftingItems/Base/DecodeCommonName.getAibEquiName(commonName), "getAibEquiName('${commonName}')");
        let* aibSiteName        = liftOption(NewLiftingItems/Base/DecodeCommonName.getAibSiteName(commonName), "getAibSiteName('${commonName}')");
        let* aibEquiType        = liftOption(NewLiftingItems/Base/DecodeCommonName.getAibEquiType(commonName), "getAibEquiType('${commonName}')");
        let* flocRoot           = getS4SiteCode(pstmts, aibSiteName);
        let* longText           = getLongText(pstmts, reference);
        let* tymap              = NewLiftingItems/MakeReport/BuildItems/LiftingTypeMapping.getTypeMapping(pstmts, aibEquiName, aibEquiType);
        let* aibAttributes      = NewLiftingItems/MakeReport/BuildItems/AibAttributes.getAibAttributes(pstmts, reference);
        let funcLoc             = liftingFunctionalLocation(flocRoot, tymap.fixedOrPortable);
        let* parentRef          = getParentAibReference(pstmts, commonName);
        let* eastNorth          = liftOption(getEastingNorthing(aibAttributes.osgb36), "childNew");
        let* loadFields         = getWorkingLoadFields(pstmts, tymap.s4Class);
        let ans                 = 
            { equiId            = freshEquiId
            , objectType        = tymap.s4Object
            , objectClass       = tymap.s4Class
            , attributes        =
                { category              = tymap.category
                , description           = description
                , startupDate           = aibAttributes.installedFrom
                , manufacturer          = aibAttributes.manufacturer
                , model                 = aibAttributes.model
                , partNumber            = aibAttributes.partNumber
                , serialNumber          = aibAttributes.serialNumber
                , maintPlant            = 2100
                , companyCode           = 2100
                , controllingArea       = 1000
                , planningPlant         = 1000
                , functionalLocation    = funcLoc
                , superOrdinateEqui     = ""
                , status                = aibAttributes.assetStatus       
                }
            , longText          = longText
            , classifications   = 
                { pliReference                  = reference
                , saiParentReference            = parentRef
                , easting                       = Some(eastNorth.easting)
                , northing                      = Some(eastNorth.northing)
                , locationOnSite                = aibAttributes.locationOnSite
                , workingLoadFieldName          = loadFields.valueFieldName
                , workingLoad                   = aibAttributes.workLoad
                , workingLoadUnitsFieldName     = loadFields.unitFieldName
                , workingLoadUnits              = aibAttributes.workLoadUnits
                , statutoryReference            = aibAttributes.statutoryRef
                , testCertNumber                = aibAttributes.testCertNum
                }
            } |> NewLiftingItems/MakeReport/BuildItems/RewriteValues.renameForS4;
        return(ans)

    /// Long text

    def getLongText[r](pstmts: {selectLongText: PreparedStatement| r}, reference: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectLongText, BasicDb/PreparedStatementSetter.putStringAt!(0,  reference));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("long_text"));
        let* _      = rsClose(rs);
        return(x1)

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


    def getCommonName[r](pstmts: {selectCommonName: PreparedStatement |r}, reference: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectCommonName, BasicDb/PreparedStatementSetter.putStringAt!(0,  reference));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("common_name"));
        let* _      = rsClose(rs);
        return(if (Object.isNull(x1)) "" else x1)

    def prepareCommonNameQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.common_name"
                :: "FROM wl_common_names t"
                :: "WHERE "
                :: "    t.reference = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)
        
    /// Parent AIb Reference
    /// Need to have looked up commonName beforehand
    def getParentAibReference[r](pstmts: {selectParentRef: PreparedStatement |r}, equiCommonName: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, liftOption, psExecuteQuery, firstRow, rsClose};
        use NewLiftingItems/Base/DecodeCommonName.{getAibParentName};
        let* parent = liftOption(getAibParentName(equiCommonName), "getAibParentName");
        let* rs     = psExecuteQuery(pstmts.selectParentRef, BasicDb/PreparedStatementSetter.putStringAt!(0,  parent));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("reference"));
        let* _      = rsClose(rs);
        return(if (Object.isNull(x1)) "" else x1)

    def prepareParentAibReferenceQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.reference"
                :: "FROM wl_common_names t"
                :: "WHERE "
                :: "    t.common_name = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

}