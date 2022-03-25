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

namespace S4Loader/App/GenFlocUxl {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic, EquiLongText};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias, EquiObjectClass};
    use S4Loader/Base/AttributesLattice.{Attributes, AttributeValue};
    use S4Loader/Floc/WorkList.{FlocWorkItem};
    use S4Loader/PDT/Rules/Schema.{EquiWorkItem};
    use S4Loader/PDT/Rules/EquiAttributes.{EquiAttributesSchema, EquiAttributes};


        

    /// Need to get worklist from the command line...
    pub def runGenFlocUxl(worklist: String): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let* outputArgs     = makeOutputArgs();
        let* outputRoot     = S4Loader/App/Config.getWorkingDirectory();
        let worklistpath    = System/FilePath.snoc(outputRoot, worklist);
        let flocsrc         = {path = worklistpath, sheet = "Floc"};
        let* _              = S4Loader/Floc/GenUxl.generateFlocUxl(outputArgs, flocsrc);
        Ok()


    def makeOutputArgs(): Result[UxlOutputArgs, String] & Impure = 
        use Result.flatMap;
        let* configPath = S4Loader/App/Config.getAppConfigPath();
        let* outputRoot = S4Loader/App/Config.getWorkingDirectory();
        Ok({ uxlTemplate = System/FilePath.snoc(configPath, "1909_AIW_MOCR_Template.xlsx")
            , changeRequestName = "ABCDE ## UXL"
            , outpath = System/FilePath.snoc(outputRoot, "pdt_uxl.xlsx")
            })

}
