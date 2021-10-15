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

/// Get AIB Names from a Hierarchy export.
/// This is arguably the safest way to account for forward-slashes in names where
/// the slash is not a separator.

namespace AssetLib/AssetQuery/Extra/AibHierarchyNames {

    pub rel AibParentName(reference: String, parentName: String)


    pub def getParentNames(xs: List[{reference :: String, commonName :: String | r}]): #{AibParentName | reln} = 
        let allNames = allCommonNames(xs);
        let step = row -> match getParent(allNames, row.commonName) {
            case Some(parent) => #{ AibParentName(row.reference, parent). }
            case None => #{}
        };
        RelLib/Relation.foldMap(step, xs)


    pub def getParentNamesMap(xs: List[{reference :: String, commonName :: String | r}]): Map[String, String] = 
        let allNames = allCommonNames(xs);
        let step = (ac, row) -> match getParent(allNames, row.commonName) {
            case Some(parent) => Map.insert(row.reference, parent, ac)
            case None => ac
        };
        List.foldLeft(step, Map.empty(), xs)


    def allCommonNames(xs: List[{commonName :: String | r}]): Set[String] = 
        List.foldLeft((s, x1) -> Set.insert(x1.commonName, s), Set.empty(), xs)



    def getParent(s: Set[String], name: String): Option[String] = 
        let strip = start -> Option.flatMap(String.stripPrefix(start));
        let parentFull = getLongestPrefix(s, name);
        let pref = getLongestPrefix(s, parentFull);
        String.stripPrefix(substr = pref, parentFull) 
            |> strip(substr = "/")
            

    def getLongestPrefix(s: Set[String], name: String): String = 
        let step = (ac, x) -> {
            if (String.startsWith(prefix = x, name) and String.length(x) < String.length(name)) {
                if (String.length(x) > String.length(ac)) x else ac
            } else ac
        };
        Set.foldLeft(step, "", s)

}