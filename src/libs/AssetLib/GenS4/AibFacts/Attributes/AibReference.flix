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


namespace AssetLib/GenS4/AibFacts/Attributes/AibReference {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{AibPliNum, AibParentRef};


    /// Read from Aib file...

    pub type alias AibRow = 
        { reference :: String
        , commonName :: String
        }

    pub def readHierarchyRelations(src: XlsxSource): GenMonad[#{AibPliNum, AibParentRef | r}] =
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftActionResult};
        let cmp         = (x,y) -> Order.compare(x.commonName, y.commonName);
        let* xs         = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibSheet(src.sheet), src.path) |> Result.map(List.sortWith(cmp)));
        let parents     = extractHierarchyFacts(xs);
        let plinums     = RelLib/Relation.foldMap(x1 -> #{ AibPliNum(x1.reference, x1.reference). }, xs);
        return(parents <+> plinums)


    def readAibSheet(sheetName: String): SheetReader[List[AibRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(evalAibRow(), s1);
        return(xs)


    def evalAibRow(): NamedRowEvaluator[AibRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getLocalDateNamed, withDefault, swapErrorWithRowNum}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> {reference = x1, commonName = x2})
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")

    def extractHierarchyFacts(xs: List[AibRow]): #{AibParentRef | r} = 
        getAibRootNode(xs) <+> getDescendants(xs)
        

    /// First node is site
    def getAibRootNode(xs: List[AibRow]): #{AibParentRef | r} = match xs {
        case x :: _ => #{ AibParentRef(x.reference, ""). }
        case Nil => #{}
    }
    
    /// First node is root which we put on a a stack...
    /// Spelling reminder for me - descendants with "dants" (things which descend from)
    def getDescendants(xs: List[AibRow]): #{AibParentRef | r} = match xs {
        case x :: rs => getDescendantsHelper(Nel(x, Nil), #{}, rs)
        case Nil => #{}
    }
    
    /// Parent or stack of parents?
    def getDescendantsHelper(stack: Nel[AibRow], 
                             ac: #{AibParentRef | r}, 
                             xs: List[AibRow]): #{AibParentRef | r} = match xs {
        case x :: rs => { 
            let (parent, stack1) = getParent(x.commonName, stack);
            let r1 = #{ AibParentRef(x.reference, parent.reference). };
            getDescendantsHelper(Nel.cons(x, stack1), r1 <+> ac, rs)
        }
        case Nil => ac
    }

    def getParent(commonName: String, xs: Nel[AibRow]): (AibRow, Nel[AibRow]) = match xs {
        case Nel(x1, Nil) => (x1, xs)
        case Nel(x1, r1 :: rs) => if (String.startsWith({prefix = x1.commonName}, commonName)) (x1, xs) else getParent(commonName, Nel(r1, rs))
    }

}
