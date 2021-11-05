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

namespace AssetLib/Aruba/Aib/Import/Internal/HierarchyNames {


    /// This is `reference` to `parentName`
    /// e.g "PLI00070001", "SITE/zzz/PROCESS_GROUP/PROCESS/PUMP-1/EQUIPMENT: CENTRIFUGAL PUMP"
    /// is "PLI00070001", "PUMP-1"
    /// Expected to be most useful for equipment which are "PLI<number>", ".../<name>/<type>"
    /// and <name> can include forward slash (though rarely does).
    /// 
    pub rel AibParentName(reference: String, parentName: String)

    pub type alias NameSource = 
        { reference :: String
        , commonName :: String
        }


    pub def getParentNames(xs: List[NameSource]): #{AibParentName | reln} = 
        let allNames = allCommonNames(xs);
        let step = row -> match getParent(allNames, row.commonName) {
            case Some(parent) => #{ AibParentName(row.reference, parent). }
            case None => #{ }
        };
        RelLib/Relation.foldMap(step, xs)


    pub def getParentNamesMap(xs: List[NameSource]): Map[String, String] = 
        let allNames = allCommonNames(xs);
        let step = (ac, row) -> match getParent(allNames, row.commonName) {
            case Some(parent) => Map.insert(row.reference, parent, ac)
            case None => ac
        };
        List.foldLeft(step, Map.empty(), xs)


    def allCommonNames(xs: List[NameSource]): Set[String] = 
        List.foldLeft((s, x1) -> Set.insert(x1.commonName, s), Set.empty(), xs)



    def getParent(allNames: Set[String], commonName: String): Option[String] = 
        let parentFull  = getLongestPrefixPath(allNames, commonName);
        if (String.isEmpty(parentFull))
            None
        else {
            let root = getLongestPrefixPath(allNames, parentFull);
            if (String.isEmpty(root))
                Some(parentFull)
            else {             
                String.stripPrefix(substr = root + "/", parentFull)
            }
        }
        



    def getLongestPrefixPath(allNames: Set[String], name: String): String = 
        let step = (ac, x) -> {
            /// Must suffix a path separator, otherwise longest prefix may return unpredictable results...
            let pathPrefix = x + "/";
            if (String.startsWith(prefix = pathPrefix, name) and String.length(x) < String.length(name)) {
                if (String.length(x) > String.length(ac)) x else ac
            } else ac
        };
        Set.foldLeft(step, "", allNames)



}
