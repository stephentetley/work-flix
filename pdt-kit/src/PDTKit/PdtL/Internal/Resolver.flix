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

    use PDTKit/PdtL/Datatypes.{SectionHeading, LeadSheetAttribute, DataDictMetadata, DataDictAttribute, DataSheetMultiAttribute};

    use PDTKit/PdtL/Internal/Datatypes.{PdtFile, LeadSheetRow, DataDictionaryRow, DataSheetRow};


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


    pub def resolveDataDictionary(rs: List[DataDictionaryRow]): 
            {metadata :: List[DataDictMetadata], headings :: List[SectionHeading], attributes :: List[DataDictAttribute]} = 
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
                    |> List.map(match (w, x, y, z) -> {rowNum = w, category = x, name = y, units = z});
        {metadata = xs, headings = ys, attributes = zs}



    /// Cannot identify section headers by content (would need to decipher bold, background colour...)
    /// Datalog isn't much help...
    pub def resolveDataSheetRows(rs: List[DataSheetRow]): List[DataSheetMultiAttribute] = 
        let maxim = List.foldLeft((acc, row) -> let (_, _, cs) = row; Int32.max(acc, List.length(cs)), 0 , rs);
        let padr = xs -> {let padSize = maxim - List.length(xs); List.append(xs, List.repeat(padSize, ""))};
        let step = match (n, name, cs) -> {
            // Drop rows with no values...
            if (List.isEmpty(cs)) 
                None 
            else 
                Some({rowNum = n, name = name, values = padr(cs)})
        };
        List.filterMap(step, rs)

}
