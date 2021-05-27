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


namespace AssetLib/AibFacts/HierarchyFacts {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    /// May be a Site or a "process"
    pub rel AibRootNode(aibref: String, name: String, gridref: String)


    /// Note - I don't think we should have `aibSite` as a Floc or Equi field
    /// as it can't be derived from an export when a system is root rather than 
    /// when a site is root.

    /// Arity 6
    pub rel AibFloc(aibref: String, 
                    commonName: String, 
                    nodeName: String, 
                    installedFrom: Time.LocalDate, 
                    gridRef: String,
                    parentRef: String)

    /// Arity 9
    /// All fields are derived from a "vanilla" Aib export.
    pub rel AibEquipment(aibref: String, 
                        description: String, 
                        equipmentType: String, 
                        installedFrom: Time.LocalDate, 
                        manufacturer: String, 
                        model: String, 
                        gridRef: String,
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
        }

    pub def readHierarchyRelations(sheetName: String, 
                                    path: System.FilePath): Result[#{AibRootNode, AibFloc, AibEquipment | r}, String] & Impure =
        use Result.{flatMap, map};
        let cmp  = (x,y) -> Order.compare(x.commonName, y.commonName) |> Comparison.toInt;
        let* xs = SheetIO/SheetReader.runXlsx(readAibSheet(sheetName), path) |> map(List.sortWith(cmp));
        let facts = extractHierarchyFacts(xs);
        Ok(facts)


    pub def readAibSheet(sheetName: String): SheetReader[List[AibRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalAibRow());
        return(xs)


    def evalAibRow(): NamedRowEvaluator[AibRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getLocalDateNamed, withDefault, swapErrorWithRowNum}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
                { reference             = x1
                , commonName            = x2
                , installedFrom         = x3
                , manufacturer          = x4
                , model                 = x5
                , assetStatus           = x6
                , gridRef               = x7
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model")
            <*> getContentNamed("AssetStatus")
            <*> getContentNamed("Loc.Ref.")

    def extractHierarchyFacts(xs: List[AibRow]): #{AibRootNode, AibFloc, AibEquipment |r} = 
        getAibRootNode(xs) <+> getDescendants(xs)
        

    /// First node is site
    def getAibRootNode(xs: List[AibRow]): #{AibRootNode |r} = match xs {
        case x :: _ => #{ AibRootNode(x.reference, x.commonName, x.gridRef). }
        case Nil => #{}
    }
    
    /// First node is root which we put on a a stack...
    /// Spelling reminder for me - descendants with "dants" (things which descend from)
    def getDescendants(xs: List[AibRow]): #{AibFloc, AibEquipment |r} = match xs {
        case x :: rs => getDescendantsHelper(Nel(x, Nil), #{}, rs)
        case Nil => #{}
    }
    
    /// Parent or stack of parents?
    def getDescendantsHelper(stack: Nel[AibRow], 
                             ac: #{AibFloc, AibEquipment |r}, 
                             xs: List[AibRow]): #{AibFloc, AibEquipment |r} = match xs {
        case x :: rs => { 
            let (parent, stack1) = getParent(x.commonName, stack);
            let r1 = { 
                if (String.contains(x.commonName, "EQUIPMENT:"))
                    #{ AibEquipment(x.reference, 
                                    getParentName(stack1),
                                    getNodeName(x.commonName, stack1),                                 
                                    x.installedFrom, 
                                    x.manufacturer, 
                                    x.model, 
                                    x.gridRef, 
                                    x.assetStatus, 
                                    parent.reference). }
                else
                    #{ AibFloc(x.reference, 
                                x.commonName, 
                                getNodeName(x.commonName, stack1), 
                                x.installedFrom, 
                                x.gridRef,
                                parent.reference). }
            };
            getDescendantsHelper(Nel.cons(x, stack1), r1 <+> ac, rs)
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
