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


namespace AssetLib/AibRel/HierarchicalRelations {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    /// May be a Site or a "process"
    pub rel RootNode(aibref: String, name: String, gridref: String)


    /// TODO - I don't think we should have `aibSite` as a Floc or Equi field
    /// as it can't be derived from a system is root (rather than a site is root) export.

    /// Arity 7
    pub rel AibFloc(aibref: String, 
                    aibSite: String, 
                    commonName: String, 
                    nodeName: String, 
                    installedFrom: Time.LocalDate, 
                    gridRef: String,
                    parentRef: String)

    /// Arity 13
    pub rel AibEquipment(aibref: String, 
                        aibSite: String, 
                        description: String, 
                        equipmentType: String, 
                        installedFrom: Time.LocalDate, 
                        manufacturer: String, 
                        model: String, 
                        partNumber: String, 
                        serialNumber: String, 
                        gridRef: String,
                        pandiTag: String, 
                        status: String, 
                        parentRef: String)


    /// Read from Aib file...

    type alias AibRow = 
        { reference: String
        , commonName: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , assetStatus: String
        , gridRef: String
        , pandiTag: String
        , serialNumber: String
        , specificModelFrame: String
        }

    pub def readHierarchyFacts(sheetName: String, 
                                path: System.FilePath): Result[#{RootNode, AibFloc, AibEquipment | r}, String] & Impure =
        use Result.{flatMap, map};
        let cmp  = (x,y) -> Order.compare(x.commonName, y.commonName) |> Order.toInt;
        let* xs = SheetIO/SheetReader.runXlsx(readAibSheet(sheetName), path) |> map(List.sortWith(cmp));
        let facts = extractHierarchyFacts(xs);
        Ok(facts)


    pub def readAibSheet(sheetName: String): SheetReader[List[AibRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalAibRow());
        return(xs)


    def evalAibRow(): NamedRowEvaluator[AibRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getLocalDateNamed, withDefault}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> 
                { reference             = x1
                , commonName            = x2
                , installedFrom         = x3
                , manufacturer          = x4
                , model                 = x5
                , assetStatus           = x6
                , gridRef               = x7
                , pandiTag              = x8
                , serialNumber          = x9
                , specificModelFrame    = x10
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model")
            <*> getContentNamed("AssetStatus")
            <*> getContentNamed("Loc.Ref.")
            <*> withDefault(getContentNamed("P AND I Tag No"), "")
            <*> withDefault(getContentNamed("Serial No"), "")
            <*> withDefault(getContentNamed("Specific Model/Frame"), "")

    def extractHierarchyFacts(xs: List[AibRow]): #{RootNode, AibFloc, AibEquipment |r} = 
        getRootNode(xs) <+> getDescendants(xs)
        

    /// First node is site
    def getRootNode(xs: List[AibRow]): #{RootNode |r} = match xs {
        case x :: _ => #{ AibSite(x.reference, x.commonName, x.gridRef). }
        case Nil => #{}
    }
    
    /// First node is root which we put on a a stack...
    /// Spelling reminder for me - descendants with "dants" (things which descend from)
    def getDescendants(xs: List[AibRow]): #{AibFloc, AibEquipment |r} = match xs {
        case x :: rs => getDescendantsHelper(x.commonName, Nel(x, Nil), #{}, rs)
        case Nil => #{}
    }
    
    /// Parent or stack of parents?
    def getDescendantsHelper(siteName: String, 
                             stack: Nel[AibRow], 
                             ac: #{AibFloc, AibEquipment |r}, 
                             xs: List[AibRow]): #{AibFloc, AibEquipment |r} = match xs {
        case x :: rs => { 
            let (parent, stack1) = getParent(x.commonName, stack);
            let r1 = { 
                if (String.contains(x.commonName, "EQUIPMENT:"))
                    #{ AibEquipment(x.reference, siteName, getParentName(stack1),
                                    getNodeName(x.commonName, stack1),                                 
                                    x.installedFrom, x.manufacturer, x.model, 
                                    x.specificModelFrame, x.serialNumber, x.gridRef,
                                    x.pandiTag, x.assetStatus, parent.reference). }
                else
                    #{ AibFloc(x.reference, 
                                siteName, 
                                x.commonName, 
                                getNodeName(x.commonName, stack1), 
                                x.installedFrom, 
                                x.gridRef,
                                parent.reference). }
            };
            getDescendantsHelper(siteName, Nel.cons(x, stack1), r1 <+> ac, rs)
        }
        case Nil => ac
    }

    def getParent(commonName: String, xs: Nel[AibRow]): (AibRow, Nel[AibRow]) = match xs {
        case Nel(x1, Nil) => (x1, xs)
        case Nel(x1, r1 :: rs) => if (String.startsWith(commonName, x1.commonName)) (x1, xs) else getParent(commonName, Nel(r1, rs))
    }


    def getParentName(stk: Nel[AibRow]): String = match stk {
        case Nel(x1, Nil) => x1.commonName
        case Nel(x1, r1 :: _) => String.breakOnRight(r1.commonName + "/", x1.commonName) |> snd
    }

    def getNodeName(commonName: String, stk: Nel[AibRow]): String = 
        let prefix = getParentName(stk) + "/";
        String.breakOnRight(prefix, commonName) |> snd



}
