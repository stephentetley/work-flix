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

    use Interop/Json.JsonArrayBuilder;
    use Interop/Json.JsonObjectBuilder;

    use PDTKit/PdtL/Datatypes.{PdtFile, SectionHeading, LeadSheetAttribute};



    pub def addLeadSheet(sheet: {headings :: List[SectionHeading], attributes :: List[LeadSheetAttribute]}): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Interop/Json/JsonObjectBuilder.{addJsonObjectBuilder, addString};
        addJsonObjectBuilder("lead_sheet", 
            addString("sheet_name", "Asset Data Lead Sheet") *>
            addSectionHeadings("headings", sheet.headings)

        )

    def addSectionHeadings(name: String, xs: List[SectionHeading]): JsonObjectBuilder[r, Unit, Unit] \ Write(r) =
        use Interop/Json/JsonObjectBuilder.{addJsonArrayBuilder};
        addJsonArrayBuilder(name, Foldable.foreachM(addSectionHeading, xs))

    def addSectionHeading(sh: SectionHeading): JsonArrayBuilder[r, Unit, Unit] \ Write(r) =
        use Interop/Json/JsonArrayBuilder.{addJsonObjectBuilder};
        use Interop/Json/JsonObjectBuilder.{addInt32, addString};
        addJsonObjectBuilder(addInt32("row_num", sh.rowNum) *> addString("name", sh.heading))


}
