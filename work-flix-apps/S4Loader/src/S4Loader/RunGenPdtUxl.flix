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

namespace S4Loader/RunGenPdtUxl {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic, EquiLongText};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias, EquiObjectClass};
    use S4Loader/Base/AttributesLattice.{Attributes, AttributeValue};
    use S4Loader/Floc/WorkList.{FlocWorkItem};
    use S4Loader/PDT/Rules/Schema.{EquiWorkItem};
    use S4Loader/PDT/Rules/EquiAttributes.{EquiAttributesSchema, EquiAttributes};


    pub def runGenPdtUxl(_: Array[String]): Int32 & Impure = 
        println("Running... ${Time/LocalTime.now()}");
        main01() |> println;
        0
        

    def outputArgs(): UxlOutputArgs = 
        { uxlTemplate = System/FilePath.new("G:/work/assets/uxl/1909_AIW_MOCR_Template.xlsx")
        , changeRequestName = "Chello ## UXL"
        , outpath = System/FilePath.new("G:/work/assets/capital_schemes/sca05/output/sca05_dsear_pdt_uxl.xlsx")
        }

    def main01(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let dbpath          = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-s4loader.sqlite");
        let flocsrc         = {path = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt-worklist.xlsx"),
                                sheet = "Floc"};
        let equisrc         = {path = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt-worklist.xlsx"), 
                                sheet = "Equi"};
        let* _              = S4Loader/Uxl/GenUxl.generatePDTUxl(outputArgs(), {dbpath = dbpath, flocsrc = flocsrc, equisrc = equisrc});
        Ok()

}
