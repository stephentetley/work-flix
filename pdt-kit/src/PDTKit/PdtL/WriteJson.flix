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

namespace PDTKit/PdtL/WriteJson {
    
    use Applicative.{*>};

    use Basis/System.FilePath;

    use Interop/Json.JsonObject;
    use Basis/Json.JsonArrayBuilder;
    use Basis/Json.JsonObjectBuilder;

    use PDTKit/PdtL/Datatypes.{PdtFile, SectionHeading, LeadSheetAttribute, 
        DataDictMetadata, DataDictAttribute, DataSheetMultiAttribute};

    pub def buildJson(pdtL: PdtFile): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addString!};
        addString!("file_name", pdtL.fileName)  *>
        addLeadSheet!(pdtL.leadSheet)           *>
        addDataDictSheet!(pdtL.dataDictionary)  *>
        addDataSheet!(pdtL.dataSheet)

    /// ## LeadSheet

    pub def addLeadSheet!(sheet: {headings :: List[SectionHeading], attributes :: List[LeadSheetAttribute]}): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonObjectBuilder!, addString!};
        addJsonObjectBuilder!("lead_sheet", 
            addString!("sheet_name", "Asset Data Lead Sheet")        *>
            addSectionHeadings!("headings", sheet.headings)          *>
            addLeadSheetAttributes!("attributes", sheet.attributes)
        )

    def addSectionHeadings!(name: String, xs: List[SectionHeading]): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonArrayBuilder!};
        addJsonArrayBuilder!(name, Foldable.foreachM(addSectionHeading1!, xs))

    def addSectionHeading1!(sh: SectionHeading): JsonArrayBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonArrayBuilder.{addJsonObjectBuilder!};
        use Basis/Json/JsonObjectBuilder.{addInt32!, addString!};
        addJsonObjectBuilder!(addInt32!("row_num", sh.rowNum) *> addString!("name", sh.heading))

    def addLeadSheetAttributes!(name: String, xs: List[LeadSheetAttribute]): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonArrayBuilder!};
        addJsonArrayBuilder!(name, Foldable.foreachM(addLeadSheetAttribute1!, xs))

    def addLeadSheetAttribute1!(attr: LeadSheetAttribute): JsonArrayBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonArrayBuilder.{addJsonObjectBuilder!};
        use Basis/Json/JsonObjectBuilder.{addInt32!, addString!};
        addJsonObjectBuilder!(
            addInt32!("row_num", attr.rowNum) *> 
            addString!("name", attr.name)     *>
            addString!("value", attr.value)   *>
            addString!("code", attr.code)
        )

    /// ## DataDictionary
    def addDataDictSheet!(sheet: {metadata :: List[DataDictMetadata], 
                                    headings :: List[SectionHeading],
                                    attributes :: List[DataDictAttribute]}): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonObjectBuilder!, addString!};
        addJsonObjectBuilder!("data_dictionary", 
            addString!("sheet_name", "PDS_ADT")                      *>
            addDataDictMetadata!("metadata", sheet.metadata)         *>
            addSectionHeadings!("headings", sheet.headings)          *>
            addDataDictAttributes!("attributes", sheet.attributes)
        )

    def addDataDictMetadata!(name: String, xs: List[DataDictMetadata]): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonArrayBuilder!};
        addJsonArrayBuilder!(name, Foldable.foreachM(addDataDictMetadata1!, xs))

    def addDataDictMetadata1!(ddm: DataDictMetadata): JsonArrayBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonArrayBuilder.{addJsonObjectBuilder!};
        use Basis/Json/JsonObjectBuilder.{addInt32!, addString!};
        addJsonObjectBuilder!(
            addInt32!("row_num", ddm.rowNum) *> 
            addString!("name", ddm.name)     *>
            addString!("value", ddm.value)
        )

    def addDataDictAttributes!(name: String, xs: List[DataDictAttribute]): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonArrayBuilder!};
        addJsonArrayBuilder!(name, Foldable.foreachM(addDataDictAttribute1!, xs))

    def addDataDictAttribute1!(attr: DataDictAttribute): JsonArrayBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonArrayBuilder.{addJsonObjectBuilder!};
        use Basis/Json/JsonObjectBuilder.{addInt32!, addString!};
        addJsonObjectBuilder!(
            addInt32!("row_num", attr.rowNum)        *> 
            addString!("category", attr.category)    *>
            addString!("name", attr.name)            *>
            addString!("units", attr.units)
        )

    /// ## DataSheet

    def addDataSheet!(sheet: {sheetName :: String, multiAttributes :: List[DataSheetMultiAttribute]}): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonObjectBuilder!, addString!};
        addJsonObjectBuilder!("datasheet", 
            addString!("sheet_name", sheet.sheetName) *>
            addDataSheetMultiAttributes!("rows", sheet.multiAttributes)
        )

    def addDataSheetMultiAttributes!(name: String, xs: List[DataSheetMultiAttribute]): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonObjectBuilder.{addJsonArrayBuilder!};
        addJsonArrayBuilder!(name, Foldable.foreachM(addDataSheetMultiAttribute1!, xs))

    def addDataSheetMultiAttribute1!(attr: DataSheetMultiAttribute): JsonArrayBuilder[r, Unit, Unit] \ Write(r) =
        use Basis/Json/JsonArrayBuilder.{addJsonObjectBuilder!};
        use Basis/Json/JsonObjectBuilder.{addInt32!, addString!, addJsonArrayBuilder!};
        addJsonObjectBuilder!(
            addInt32!("row_num", attr.rowNum) *> 
            addString!("name", attr.name)     *>
            addJsonArrayBuilder!("values", Foldable.foreachM(Basis/Json/JsonArrayBuilder.addString!, attr.values))
        )

}
