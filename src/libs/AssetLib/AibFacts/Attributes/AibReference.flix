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


namespace AssetLib/AibFacts/Attributes/AibReference {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;


    /// TODO - needs testing!!!

    pub rel ParentRef(aibref: String, commonName: String, parent: String)




    /// Read from Aib file...

    type alias AibRow = 
        { reference: String
        , commonName: String
        }

    pub def readHierarchyRelations(sheetName: String, 
                                    path: System.FilePath): Result[#{ParentRef | r}, String] & Impure =
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
        ((x1, x2) -> {reference = x1, commonName = x2})
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")

    def extractHierarchyFacts(xs: List[AibRow]): #{ParentRef | r} = 
        getAibRootNode(xs) <+> getDescendants(xs)
        

    /// First node is site
    def getAibRootNode(xs: List[AibRow]): #{ParentRef | r} = match xs {
        case x :: _ => #{ ParentRef(x.reference, x.commonName, ""). }
        case Nil => #{}
    }
    
    /// First node is root which we put on a a stack...
    /// Spelling reminder for me - descendants with "dants" (things which descend from)
    def getDescendants(xs: List[AibRow]): #{ParentRef | r} = match xs {
        case x :: rs => getDescendantsHelper(Nel(x, Nil), #{}, rs)
        case Nil => #{}
    }
    
    /// Parent or stack of parents?
    def getDescendantsHelper(stack: Nel[AibRow], 
                             ac: #{ParentRef | r}, 
                             xs: List[AibRow]): #{ParentRef | r} = match xs {
        case x :: rs => { 
            let (parent, stack1) = getParent(x.commonName, stack);
            let r1 = #{ ParentRef(x.reference, x.commonName, parent.reference). };
            getDescendantsHelper(Nel.cons(x, stack1), r1 <+> ac, rs)
        }
        case Nil => ac
    }

    def getParent(commonName: String, xs: Nel[AibRow]): (AibRow, Nel[AibRow]) = match xs {
        case Nel(x1, Nil) => (x1, xs)
        case Nel(x1, r1 :: rs) => if (String.startsWith(commonName, x1.commonName)) (x1, xs) else getParent(commonName, Nel(r1, rs))
    }


    /// def getParentName(stk: Nel[AibRow]): String = match stk {
    ///     case Nel(x1, Nil) => x1.commonName
    ///     case Nel(x1, r1 :: _) => String.breakOnRight(r1.commonName + "/", x1.commonName) |> snd
    /// }

    /// def getNodeName(commonName: String, stk: Nel[AibRow]): String = 
    ///     let prefix = getParentName(stk) + "/";
    ///     String.breakOnRight(prefix, commonName) |> snd



}
