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

namespace AssetLib/AssetModels/GeneralStructure/Builder {

    use Data.RoseTree.{RoseTree};

    
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06Tree, IH06Node, FlocNode, EquiNode};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Node.{FlocNode, EquiNode};
    use AssetLib/AssetModels/GeneralStructure/Datatypes.{GSSite, GSFunction, 
        GSProcessGroup, GSProcess, GSSystem, GSSubsystem, GSEquipment, GSSubequipment};

    /// How do we know the starting level of the input? 
    /// Assume user knows what they are reading.


    pub def buildGSSite(src: System.FilePath): Result[GSSite, String] & Impure = 
        use Result.{flatMap};
        let* x1 = AssetLib/FileIO/S4/IH06Tree/Builder.readTree(src);
        translateSite(x1)



    /// type alias FlocNode = { level: Int32, floc: String, description: String, parent: String }
    /// type alias EquiNode = { level: Int32, equiId: String, description: String, floc: String, superordinate: String }

    pub def translateSite(x: IH06Tree): Result[GSSite, String] = 
        translateSite1(x, msg -> Err(msg), ans -> Ok(ans))
        
    def translateSite1(x: IH06Tree, 
                        fk: String -> Result[GSSite, String], 
                        sk: GSSite -> Result[GSSite, String]): Result[GSSite, String] = 
        let RoseTree(n, kids) = x;
        match translateSiteNode(n) {
            case Ok(site) => translateFunctionList(kids, fk, funs -> sk({functions = funs | site}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSiteNode(x: IH06Node): Result[GSSite, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 1 => 
                Ok({funcloc = x1.floc, name = x1.description, status = "", functions = Nil})
            case _ => Err("Not a Site")
        }


    /// This must test that the function is not in the the Electrical Structure...
    def translateFunctionList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSFunction] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => 
                if (isElectricalFunction(x))
                    translateFunctionList(rs, fk, sk)
                else 
                    translateFunction1(x, fk, v1 -> translateFunctionList(rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def isElectricalFunction(x: IH06Tree): Bool = 
        let RoseTree(n, _) = x;
        match n { 
            case FlocNode(n1) if n1.level == 2 and String.endsWith(n1.floc, "-E") => true
            case _ => false
        }

    def translateFunction1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSFunction -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateFunctionNode(n) {
            case Ok(node) => translateProcessGroupList(kids, fk, vs -> sk({processGroups = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateFunctionNode(x: IH06Node): Result[GSFunction, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 2 =>             
                Ok({funcloc = x1.floc, name = x1.description, objectType= "", status = "", processGroups = Nil: List[GSProcessGroup]})
            case _ => Err("Not a Function")
        }

    def translateProcessGroupList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSProcessGroup] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => translateProcessGroup1(x, fk, v1 -> translateProcessGroupList(rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateProcessGroup1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSProcessGroup -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateProcessGroupNode(n) {
            case Ok(node) => translateProcessList(kids, fk, vs -> sk({processes = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateProcessGroupNode(x: IH06Node): Result[GSProcessGroup, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 3 =>             
                Ok({funcloc = x1.floc, name = x1.description, objectType= "", status = "", processes = Nil: List[GSProcess]})
            case _ => Err("Not a ProcessGroup")
        }

    def translateProcessList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSProcess] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => translateProcess1(x, fk, v1 -> translateProcessList(rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateProcess1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSProcess -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateProcessNode(n) {
            case Ok(node) => translateSystemList(kids, fk, vs -> sk({systems = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateProcessNode(x: IH06Node): Result[GSProcess, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 4 =>
                Ok({funcloc = x1.floc, name = x1.description, objectType= "", status = "", systems = Nil: List[GSSystem]})
            case _ => Err("Not a Process")
        }

    def translateSystemList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSSystem] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => translateSystem1(x, fk, v1 -> translateSystemList(rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateSystem1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSSystem -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateSystemNode(n) {
            case Ok(node) => translateSubsystemList(kids, fk, vs1 -> 
                                translateEquipmentList(kids, fk, vs2 -> sk({subsystems = vs1, equipment = vs2 | node})))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSystemNode(x: IH06Node): Result[GSSystem, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 5 =>
                Ok({funcloc = x1.floc, name = x1.description, objectType= "", status = "", 
                    subsystems = Nil: List[GSSubsystem], equipment = Nil: List[GSEquipment]})
            case _ => Err("Not a System")
        }


    def translateSubsystemList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSSubsystem] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => match x { 
                case RoseTree(FlocNode(_), _) => 
                    translateSubsystem1(x, fk, v1 -> translateSubsystemList(rs, fk, vs -> sk(v1 :: vs)))
                
                case RoseTree(EquiNode(_), _) => translateSubsystemList(rs, fk, vs -> sk(vs))
            }
            case Nil => sk(Nil)                    
        }

    def translateSubsystem1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSSubsystem -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateSubsystemNode(n) {
            case Ok(node) => translateEquipmentList(kids, fk, vs -> sk({equipment = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSubsystemNode(x: IH06Node): Result[GSSubsystem, String] = 
        match x { 
            case FlocNode(x1) if x1.level == 6 =>
                Ok({funcloc = x1.floc, name = x1.description, objectType= "", status = "", equipment = Nil: List[GSEquipment]})
            case _ => Err("Not a Subsystem")
        }

    def translateEquipmentList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSEquipment] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => match x { 
                case RoseTree(EquiNode(_), _) => 
                    translateEquipment1(x, fk, v1 -> translateEquipmentList(rs, fk, vs -> sk(v1 :: vs)))
                    
                case RoseTree(FlocNode(_), _) => translateEquipmentList(rs, fk, vs -> sk(vs))
            }
            case Nil => sk(Nil)                    
        }

    def translateEquipment1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSEquipment -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, kids) = x;
        match translateEquipmentNode(n) {
            case Ok(node) => translateSubequipmentList(kids, fk, vs -> sk({subequipment = vs | node}))
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateEquipmentNode(x: IH06Node): Result[GSEquipment, String] = 
        match x { 
            case EquiNode(x1) =>
                Ok({equiId = x1.equiId, name = x1.description, objectType= "", status = "", subequipment = Nil: List[GSSubequipment]})
            case FlocNode(x1) => Err("Not an EquiNode - ${x1.floc}")
        }

    def translateSubequipmentList(xs: List[IH06Tree], 
                                fk: String -> Result[ans, String],
                                sk: List[GSSubequipment] -> Result[ans, String]): Result[ans, String] = 
        match xs { 
            case x :: rs => translateSubequipment1(x, fk, v1 -> translateSubequipmentList(rs, fk, vs -> sk(v1 :: vs)))
            case Nil => sk(Nil)                    
        }

    def translateSubequipment1(x: IH06Tree, 
                                fk: String -> Result[ans, String],
                                sk: GSSubequipment -> Result[ans, String]): Result[ans, String] =
        let RoseTree(n, _) = x;
        match translateSubequipmentNode(n) {
            case Ok(node) => sk(node)
            case Err(msg) => fk(msg)
        }

    /// No recursion, doesn't need to be in CPS
    def translateSubequipmentNode(x: IH06Node): Result[GSSubequipment, String] = 
        match x { 
            case EquiNode(x1) =>
                Ok({equiId = x1.equiId, name = x1.description, objectType = "", status = ""})
            case _ => Err("Not a Subequipment")
        }

}
