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

/// DEFUNCT
/// Needs to be reimplemented to use relations.

namespace AssetLib/Aruba/S4/Builder {

    use Data.RoseTree.{RoseTree};

    
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06Tree, IH06Node, FlocNode, EquiNode};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Node.{FlocNode, EquiNode};
    use AssetLib/Aruba/S4/Datatypes.{GSSite, GSFunction, 
        GSProcessGroup, GSProcess, GSSystem, GSSubsystem, GSEquipment, GSSubequipment};

    /// How do we know the starting level of the input? 
    /// Assume user knows what they are reading.

    type alias SourceFiles =
        { ih06Text :: System.FilePath
        , ih06Table :: System.FilePath            /// SheetName always Sheet1 ?
        , ih08Table :: System.FilePath            /// SheetName always Sheet1 ?
        }

    /// TODO - add XlsSource to SheetIO?


    pub def buildGSSite(src: SourceFiles): Result[GSSite, String] & Impure = 
        use Result.{flatMap};
        let* flocProps = readFlocPropertiesMap(src.ih06Table);
        let* equiProps = readEquiPropertiesMap(src.ih08Table);
        let* x1 = AssetLib/FileIO/S4/IH06Tree/Builder.readTree(src.ih06Text);
        translateSite(flocProps, equiProps, x1)

    type alias FlocProp = 
        { status :: String
        , objectType :: String
        }

    def readFlocPropertiesMap(path: System.FilePath): Result[Map[String, FlocProp], String] & Impure = 
        use Result.{flatMap};
        let* rows =  AssetLib/FileIO/S4/IH06Table/XlsxReader.readIH06File(path);
        let ans = List.foldLeft((ac, r1) -> Map.insert(r1.floc, {status = r1.userStatus, objectType = r1.objectType}, ac), Map.empty(), rows);
        Ok(ans)

    def getFlocProps(floc: String, dict: Map[String, FlocProp]): FlocProp = 
        Map.getWithDefault(floc, {status = "", objectType = ""}, dict)


    type alias EquiProp = 
        { status :: String
        , objectType :: String
        , position :: Option[Int32]
        }

    def readEquiPropertiesMap(path: System.FilePath): Result[Map[String, EquiProp], String] & Impure = 
        use Result.{flatMap};
        let* rows =  AssetLib/FileIO/S4/IH08Table/XlsxReader.readIH08File(path);
        let ans = List.foldLeft((ac, r1) -> 
                    Map.insert(r1.equiId, {status = r1.userStatus, objectType = r1.objectType, position = r1.position}, ac), Map.empty(), rows);
        Ok(ans)

    def getEquiProps(equiId: String, dict: Map[String, EquiProp]): EquiProp = 
        Map.getWithDefault(equiId, {status = "", objectType = "", position = None}, dict)



    pub def translateSite(fprops: Map[String, FlocProp], eprops: Map[String, EquiProp], x: IH06Tree): Result[GSSite, String] = 
        translateSite1(fprops, eprops, x, msg -> Err(msg), ans -> Ok(ans))
        
    def translateSite1(fprops: Map[String, FlocProp], 
                        eprops: Map[String, EquiProp], 
                        x: IH06Tree, 
                        fk: String -> Result[GSSite, String], 
                        sk: GSSite -> Result[GSSite, String]): Result[GSSite, String] = 
        let RoseTree(n, kids) = x;
        match translateSiteNode(fprops, n) {
            case Ok(site) => translateFunctionList(fprops, eprops, kids, fk, funs -> sk({functions = funs | site}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSiteNode(fprops: Map[String, FlocProp], x: IH06Node): Result[GSSite, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 1 => {
                let props = getFlocProps(x1.floc, fprops);
                Ok({funcloc = x1.floc, name = x1.description, status = props.status, functions = Nil})
            }
            case _ => Err("Not a Site")
        }


    /// This must test that the function is not in the the Electrical Structure...
    def translateFunctionList(fprops: Map[String, FlocProp], 
                                eprops: Map[String, EquiProp],
                                xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSFunction] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => 
                if (isElectricalFunction(x))
                    translateFunctionList(fprops, eprops, rs, fk, sk)
                else 
                    translateFunction1(fprops, eprops, x, fk, v1 -> 
                        translateFunctionList(fprops, eprops, rs, fk, vs -> sk(v1 :: vs)))

            case Nil => sk(Nil)                    
        }

    def isElectricalFunction(x: IH06Tree): Bool = 
        let RoseTree(n, _) = x;
        match n { 
            case FlocNode(n1) if n1.level == 2 and String.endsWith(suffix = "-E", n1.floc) => true
            case _ => false
        }

    def translateFunction1(fprops: Map[String, FlocProp], 
                            eprops: Map[String, EquiProp],
                            x: IH06Tree, 
                            fk: String -> Result[ans, String],
                            sk: GSFunction -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateFunctionNode(fprops, n) {
            case Ok(node) => translateProcessGroupList(fprops, eprops, kids, fk, vs -> sk({processGroups = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateFunctionNode(fprops: Map[String, FlocProp], x: IH06Node): Result[GSFunction, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 2 => { 
                let props = getFlocProps(x1.floc, fprops);
                Ok({funcloc = x1.floc, name = x1.description, objectType= props.objectType, 
                    status = props.status, processGroups = Nil: List[GSProcessGroup]})
            }
            case _ => Err("Not a Function")
        }

    def translateProcessGroupList(fprops: Map[String, FlocProp], 
                                eprops: Map[String, EquiProp],
                                xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSProcessGroup] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => 
                translateProcessGroup1(fprops, eprops, x, fk, v1 -> 
                    translateProcessGroupList(fprops, eprops, rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateProcessGroup1(fprops: Map[String, FlocProp], 
                                eprops: Map[String, EquiProp],
                                x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSProcessGroup -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateProcessGroupNode(fprops, n) {
            case Ok(node) => translateProcessList(fprops, eprops, kids, fk, vs -> sk({processes = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateProcessGroupNode(fprops: Map[String, FlocProp], x: IH06Node): Result[GSProcessGroup, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 3 => {
                let props = getFlocProps(x1.floc, fprops);    
                Ok({funcloc = x1.floc, name = x1.description, objectType= props.objectType, 
                    status = props.status, processes = Nil: List[GSProcess]})
            }
            case _ => Err("Not a ProcessGroup")
        }

    def translateProcessList(fprops: Map[String, FlocProp], 
                            eprops: Map[String, EquiProp], 
                            xs: List[IH06Tree], 
                            fk: String -> Result[ans, String],
                            sk: List[GSProcess] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => 
                translateProcess1(fprops, eprops, x, fk, v1 -> 
                    translateProcessList(fprops, eprops, rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateProcess1(fprops: Map[String, FlocProp], 
                            eprops: Map[String, EquiProp], 
                            x: IH06Tree, 
                            fk: String -> Result[ans, String],
                            sk: GSProcess -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateProcessNode(fprops, n) {
            case Ok(node) => translateSystemList(fprops, eprops, kids, fk, vs -> sk({systems = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateProcessNode(fprops: Map[String, FlocProp], x: IH06Node): Result[GSProcess, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 4 => {
                let props = getFlocProps(x1.floc, fprops);
                Ok({funcloc = x1.floc, name = x1.description, objectType= props.objectType, 
                    status = props.status, systems = Nil: List[GSSystem]})
            }
            case _ => Err("Not a Process")
        }

    def translateSystemList(fprops: Map[String, FlocProp], 
                            eprops: Map[String, EquiProp], 
                            xs: List[IH06Tree], 
                            fk: String -> Result[ans, String],
                            sk: List[GSSystem] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => 
                translateSystem1(fprops, eprops, x, fk, v1 -> 
                    translateSystemList(fprops, eprops, rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateSystem1(fprops: Map[String, FlocProp], 
                            eprops: Map[String, EquiProp], 
                            x: IH06Tree, 
                            fk: String -> Result[ans, String],
                            sk: GSSystem -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateSystemNode(fprops, n) {
            case Ok(node) => 
                translateSubsystemList(fprops, eprops, kids, fk, vs1 -> 
                                translateEquipmentList(eprops, kids, fk, vs2 -> sk({subsystems = vs1, equipment = vs2 | node})))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSystemNode(fprops: Map[String, FlocProp], x: IH06Node): Result[GSSystem, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 5 => {
                let props = getFlocProps(x1.floc, fprops);
                Ok({funcloc = x1.floc, name = x1.description, objectType= props.objectType, status = props.status, 
                    subsystems = Nil: List[GSSubsystem], equipment = Nil: List[GSEquipment]})
            }
            case _ => Err("Not a System")
        }


    def translateSubsystemList(fprops: Map[String, FlocProp], 
                                eprops: Map[String, EquiProp], 
                                xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSSubsystem] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => match x { 
                case RoseTree(FlocNode(_), _) => 
                    translateSubsystem1(fprops, eprops, x, fk, v1 -> 
                        translateSubsystemList(fprops, eprops, rs, fk, vs -> sk(v1 :: vs)))
                
                case RoseTree(EquiNode(_), _) => translateSubsystemList(fprops, eprops, rs, fk, vs -> sk(vs))
            }
            case Nil => sk(Nil)                    
        }

    def translateSubsystem1(fprops: Map[String, FlocProp], 
                            eprops: Map[String, EquiProp], 
                            x: IH06Tree, 
                            fk: String -> Result[ans, String],
                            sk: GSSubsystem -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateSubsystemNode(fprops, n) {
            case Ok(node) => translateEquipmentList(eprops, kids, fk, vs -> sk({equipment = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSubsystemNode(fprops: Map[String, FlocProp], 
                                x: IH06Node): Result[GSSubsystem, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 6 => {
                let props = getFlocProps(x1.floc, fprops);
                Ok({funcloc = x1.floc, name = x1.description, objectType= props.objectType, 
                    status = props.status, equipment = Nil: List[GSEquipment]})
            }
            case _ => Err("Not a Subsystem")
        }

    def translateEquipmentList(eprops: Map[String, EquiProp],
                                xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSEquipment] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => match x { 
                case RoseTree(EquiNode(_), _) => 
                    translateEquipment1(eprops, x, fk, v1 -> 
                        translateEquipmentList(eprops, rs, fk, vs -> sk(v1 :: vs)))

                case RoseTree(FlocNode(_), _) => translateEquipmentList(eprops, rs, fk, vs -> sk(vs))
            }
            case Nil => sk(Nil)                    
        }

    def translateEquipment1(eprops: Map[String, EquiProp],
                                x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSEquipment -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateEquipmentNode(eprops, n) {
            case Ok(node) => translateSubequipmentList(eprops, kids, fk, vs -> sk({subequipment = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateEquipmentNode(eprops: Map[String, EquiProp], x: IH06Node): Result[GSEquipment, String] = 
        match x { 
            case EquiNode(x1) => {
                let props = getEquiProps(x1.equiId, eprops);
                Ok({equiId = x1.equiId, name = x1.description, objectType= props.objectType, 
                    status = props.status, position = props.position, subequipment = Nil: List[GSSubequipment]})
            }
            case FlocNode(x1) => Err("Not an EquiNode - ${x1.floc}")
        }

    def translateSubequipmentList(eprops: Map[String, EquiProp],
                                xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSSubequipment] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => 
                translateSubequipment1(eprops, x, fk, v1 -> 
                                translateSubequipmentList(eprops, rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateSubequipment1(eprops: Map[String, EquiProp],
                                x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSSubequipment -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, _) = x;
        match translateSubequipmentNode(eprops, n) {
            case Ok(node) => sk(node)
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSubequipmentNode(eprops: Map[String, EquiProp], x: IH06Node): Result[GSSubequipment, String] = 
        match x { 
            case EquiNode(x1) => {
                let props = getEquiProps(x1.equiId, eprops);
                Ok({equiId = x1.equiId, name = x1.description, objectType = props.objectType, 
                    status = props.status, position = props.position})
            }
            case _ => Err("Not a Subequipment")
        }

}
