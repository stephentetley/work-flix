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

namespace PDTKit/PdtL/Internal/Resolver {

    use PDTKit/PdtL/Datatypes.{SectionHeading, LeadSheetAttribute, DDMetadata, DDAttribute};
    /// use PDTKit/PdtL/Internal/Datatypes.{LeadSheetRow};

    pub type alias LeadSheetRow = (Int32, String, String, String)

    pub type alias DataDictionaryRow = (Int32, String, String, String)

    pub def resolveLeadSheet(rs: List[LeadSheetRow]): {headings :: List[SectionHeading], attributes :: List[LeadSheetAttribute]} = 
        let db = inject rs into Row;
        let ask1 = #{
            Heading(rowNum, title) :- Row(rowNum, title, "", "").
        };
        let ask2 = #{
            Attribute(rowNum, title, descr, code) :- 
                Row(rowNum, title, descr, code),
                if not String.isEmpty(descr).
        };
        let xs = query db, ask1 select (x, y) from Heading(x, y) |> List.map(match (x, y) -> {rowNum = x, heading = y});
        let ys = query db, ask2 select (w, x, y, z) from Attribute(w, x, y, z) 
                    |> List.map(match (w, x, y, z) -> {rowNum = w, name = x, value = y, code = z});
        {headings = xs, attributes = ys}


    pub def resolveDataDictionary(rs: List[DataDictionaryRow]): {metadata :: List[DDMetadata], 
                                                                    headings :: List[SectionHeading], 
                                                                    attributes :: List[DDAttribute]} = 
        let db = inject rs into Row;
        let ask1 = #{
            Metadata(rowNum, name, value) :- 
                Row(rowNumBody, "Information Category", _, _),
                Row(rowNum, name, value, _),
                if rowNum < rowNumBody.
        };
        let ask2 = #{
            Heading(rowNum, title) :-
                Row(rowNumBody, "Information Category", _, _),
                Row(rowNum, title, "", ""),
                if rowNum > rowNumBody.
        };
        let ask3 = #{
            Attribute(rowNum, category, parameter, units) :- 
                Row(rowNumBody, "Information Category", _, _),
                Row(rowNum, category, parameter, units),
                if not String.isEmpty(parameter) and rowNum > rowNumBody.
        };        
        let xs = query db, ask1 select (x, y, z) from Metadata(x, y, z) |> List.map(match (x, y, z) -> {rowNum = x, name = y, value = z});
        let ys = query db, ask2 select (x, y) from Heading(x, y) |> List.map(match (x, y) -> {rowNum = x, heading = y});
        let zs = query db, ask3 select (w, x, y, z) from Attribute(w, x, y, z) 
                    |> List.map(match (w, x, y, z) -> {rowNum = w, name = x, value = y, units = z});
        {metadata = xs, headings = ys, attributes = zs}



}
