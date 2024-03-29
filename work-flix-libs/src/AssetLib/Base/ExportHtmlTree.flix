/*
 * Copyright 2020 Stephen Tetley
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


namespace AssetLib/Base/ExportHtmlTree {

    use Basis/System.FilePath;
    use FlixSandbox.{RoseTree, RoseForest};
    use FlixSandbox.RoseTree.{RoseTree};
    

    use Text/HtmlDoc.{Html};
    use Text/HtmlDoc.{writeHtml, concat, html, head, meta, title, body, paragraph, text, link, div, toString, 
        lang_, charset_, class_, rel_, href_, type_, media_};
    use Text/HtmlDoc.{<&>};
    use Text/HtmlDoc/Tree.{LabelPrinter, collapsibleTree2};

    pub type alias Label = {name :: String, description :: String}


    pub def writeHtmlTree(path: FilePath, x: RoseTree[Label]): Result[Unit, String] & Impure =
        let htmltree = paragraph(Nil, collapsibleTree2(nodePrinter(), leafPrinter(), x));
        let doc = makeDoc(htmltree);
        writeHtml(160, path, Text/Charset.utf_8(), doc)

    pub def writeHtmlForest(path: FilePath, xs: RoseForest[Label]): Result[Unit, String] & Impure =
        let htmltrees = List.map(x -> paragraph(Nil, collapsibleTree2(nodePrinter(), leafPrinter(), x)), xs) |> concat;
        let doc = makeDoc(htmltrees);
        writeHtml(160, path, Text/Charset.utf_8(), doc)


    def makeDoc(content: Html): Html = 
        html(lang_("en") :: Nil, 
                head(Nil, 
                        meta(charset_("utf-8") :: Nil)
                    <&> title(Nil, text("Tree Demo"))
                    <&> link(rel_("stylesheet") :: href_("tree.css") :: type_("text/css") :: media_("all") :: Nil)
                )
            <&> body(Nil, content)
        )

    def leafPrinter(): LabelPrinter[Label] = 
        { makeAttrs = _ -> class_("treeleaf") :: Nil
        , printNode = s -> div(class_("box") :: Nil, div(Nil, text(s.name)) <&> div(Nil, text(s.description)))
        }
    
    def nodePrinter(): LabelPrinter[Label] = 
        { makeAttrs = _ -> Nil
        , printNode = s -> div(class_("box") :: Nil, div(Nil, text(s.name)) <&> div(Nil, text(s.description) ))
        }
    



}