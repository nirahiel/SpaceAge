    /**********************************************************************************************
             These functions works with and uses rd3, and therefor needs rd3 to work.
    ***********************************************************************************************/

    if CAF.GetAddon("Resource Distribution") then
       
       //An egate function for linking Life Support 3 enitities. Put the file in the custom folder.
       
       //The function that links the stuff.
       local function Link(self, ent1, ent2)
          //Makes non-valid entities into world
          if (!validEntity(ent1)) then return "Invalid entity" end
          if (!validEntity(ent2)) then return "Invalid entity" end
          //Prop-Protection
          if (!isOwner(self, ent1)) then return "Not owner" end         //check ownership
          if (!isOwner(self, ent2)) then return "Not owner" end         //check ownership
          
          if (!ent1 or !ent2) then return end         //Check if it really is entities.
          local length = ( ent1:GetPos(1) - ent2:GetPos()):Length()         //gets length between the entities, so you cant link further then node range.
          
          //This if-statement check if the ents is nodes or LS3 entitie or pumps.
          if ent1.IsNode and ent2.IsNode then
             if length <= ent1.range or length <= ent2.range then
                CAF.GetAddon("Resource Distribution").linkNodes(ent1.netid, ent2.netid)
                return ""
             else
                return "Failed to link"         //Failed to link the entities.
             end
          elseif ent1.IsNode and table.Count(CAF.GetAddon("Resource Distribution").GetEntityTable(ent2)) > 0 then
             if length <= ent1.range then
                CAF.GetAddon("Resource Distribution").Link(ent2, ent1.netid)
                return ""
             else
                return "Failed to link"         //Failed to link the entities.
             end
          elseif ent2.IsNode and table.Count(CAF.GetAddon("Resource Distribution").GetEntityTable(ent1)) > 0 then
             if length <= ent2.range then
                CAF.GetAddon("Resource Distribution").Link(ent1, ent2.netid)
                return ""
             else
                return "Failed to link"         //Failed to link the entities.
             end
          elseif ent1.IsNode and ent2.IsPump then
             if length <= ent1.range then
                ent2:SetNetwork(ent1.netid)
                ent2.node = ent1
                return ""
             else
                return "Failed to link"         //Failed to link the entities.
             end
          elseif ent2.IsNode and ent1.IsPump then
             if length <= ent2.range then
                ent1:SetNetwork(ent2.netid)
                ent1.node = ent2
                return ""
             else
                return "Failed to link"         //Failed to link the entities.
             end
          end
          return "Failed to link"         //Failed to link the entities.
       end


       //Makes a function for egate2 named link and you set what entities it links for Life Support 3.
       registerFunction("link", "e:e", "s", function(self, args)
          local op1, op2 = args[2], args[3]
          local rv1, rv2 = op1[1](self, op1), op2[1](self, op2)
          return Link(self,rv1,rv2)
       end)
       
       //Makes a function for egate2 named link and you set what entities it links for Life Support 3.
       registerFunction("link", "ee", "s", function(self, args)
          local op1, op2 = args[2], args[3]
          local rv1, rv2 = op1[1](self, op1), op2[1](self, op2)
          return Link(self,rv1,rv2)
       end)

       /************************************************************************/

       //An egate function for unlinking Life Support 3 enitities. Put the file in the custom folder.

       /*
       CAF.GetAddon("Resource Distribution").UnlinkAllFromNode(ent1.netid)
       CAF.GetAddon("Resource Distribution").UnlinkNodes(ent1.netid, ent2.netid)
       CAF.GetAddon("Resource Distribution").Unlink(ent1)
       ent.caf.custom.rdentity:Unlink();
       */

       //The function that unlinks the stuff.
       local function UnLink(self, ent1, ent2)
          //Makes non-valid entities into world
          if (!validEntity(ent1)) then return "Invalid entity" end
          //Prop-Protection
          if (!isOwner(self, ent1)) then return "Not owner" end      //check ownership
          
          if (ent2 != "null") then
             if (!validEntity(ent2)) then return "Invalid entity" end
             if (!isOwner(self, ent2)) then return "Not owner" end         //check ownership
          else
             ent2 = nil
          end
       
          //This if-statement check if the ents is nodes or LS3 entitie or pumps.
          if (ent1 and ent2) then
             if (ent1.IsNode and ent2.IsNode) then
                CAF.GetAddon("Resource Distribution").UnlinkNodes(ent1.netid, ent2.netid)
                return ""
             elseif (ent1.IsNode) then
                ent1=ent2
             end
          end
          if (ent1) then
             if (ent1.IsNode) then
                CAF.GetAddon("Resource Distribution").UnlinkAllFromNode(ent1.netid)
                return ""
             elseif (table.Count(CAF.GetAddon("Resource Distribution").GetEntityTable(ent1)) > 0) then
                CAF.GetAddon("Resource Distribution").Unlink(ent1)
                //ent1.caf.custom.rdentity:Unlink()
                return ""
             elseif (ent1.IsPump) then
                ent1:SetNetwork(0)
                ent1.node = nil
                return ""
             end
          end
          return "Failed to unlink"
       end

       //Makes a function for egate2 named unLink and you set what entities it unlinks for Life Support 3. If both E is an entitie, they have to be nodes, which then unlinks.
       registerFunction("unLink", "e:e", "s", function(self, args)
          local op1, op2 = args[2], args[3]
          local rv1, rv2 = op1[1](self, op1), op2[1](self, op2)
          return UnLink(self,rv1,rv2)
       end)
       
       //Makes a function for egate2 named unLink and you set what entities it unlinks for Life Support 3. If both E is an entitie, they have to be nodes, which then unlinks.
       registerFunction("unLink", "ee", "s", function(self, args)
          local op1, op2 = args[2], args[3]
          local rv1, rv2 = op1[1](self, op1), op2[1](self, op2)
          return UnLink(self,rv1,rv2)
       end)

       //Makes a function for egate2 named unLink and you set what entitie it unlinks for Life Support 3. The ls3 entity to unlink  is E: and it will unlink it from the node (or if a node, unlink it from all entities)
       registerFunction("unLink", "e:", "s", function(self, args)
          local op1 = args[2]
          local rv1 = op1[1](self, op1)
          return UnLink(self,rv1,"null")
       end)

       //Makes a function for egate2 named unLink and you set what entitie it unlinks for Life Support 3. The ls3 entity to unlink  is (E), and it will unlink it from the node (or if a node, unlink it from all entities)
       registerFunction("unLink", "e", "s", function(self, args)
          local op1 = args[2]
          local rv1 = op1[1](self, op1)
          return UnLink(self,rv1,"null")
       end)

       /************************************************************************/

       //An EGate function for connecting pumps, aswell as set their pump-values.

       /*
       Resource strings availible (self explanatory). Just remember addons can add stuff to the list.
       "energy"
       "water"
       "nitrogen"
       "hydrogen"
       "oxygen"
       "carbon dioxide"
       "steam"
       "heavy water"
       "liquid nitrogen" (Outdated, snake removed the use of this.)
       "hot liquid nitrogen" (dunno what this is)
       */

       local function Pump(self, ent1, ent2, res, amount)
          /*
          //Makes non-valid entities into world
          if (!validEntity(ent1)) then return "Invalid entity"   end
          if (!validEntity(ent2)) then return "Invalid entity"   end
          //Prop-Protection
          if (ent1 != GetWorldEntity() and !isOwner(self, ent1)) then return "Not owner" end         //check ownership
          if (ent2 != GetWorldEntity() and !isOwner(self, ent2)) then return "Not owner" end         //check ownership
          */
          
          if (!ent1 or !ent1.IsPump) then return
          elseif (!ent2 or !ent2.IsPump) then
             RunConsoleCommand("SetResourceAmount", ent1:EntIndex(), res, amount)
             RunConsoleCommand("PumpTurnOn", ent1:EntIndex())
             return ""
          elseif (res == "none") then
             RunConsoleCommand("LinkToPump", ent1:EntIndex(), ent2:EntIndex())
             RunConsoleCommand("PumpTurnOn", ent1:EntIndex())
             return ""
          elseif (res == "all") then
             // If right, automaticly finds all resources in node.
             local netid = ent1:GetNetworkedInt("netid")
             local nettable = CAF.GetAddon("Resource Distribution").GetNetTable(netid)
             RunConsoleCommand("LinkToPump", ent1:EntIndex(), ent2:EntIndex())
             for k, v in pairs(nettable.resources) do
                RunConsoleCommand("SetResourceAmount", ent1:EntIndex(), k, amount)
             end
             RunConsoleCommand("PumpTurnOn", ent1:EntIndex())
             return ""
          else
             RunConsoleCommand("LinkToPump", ent1:EntIndex(), ent2:EntIndex())
             RunConsoleCommand("SetResourceAmount", ent1:EntIndex(), res, amount)
             RunConsoleCommand("PumpTurnOn", ent1:EntIndex())
             return ""
          end
          return "Failed to link pumps"
       end

       registerFunction("pump", "e:esn", "s", function(self, args)
          local op1, op2, op3, op4 = args[2], args[3], args[4], args[5]
          local rv1, rv2, rv3, rv4 = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3), op4[1](self, op4)
          return Pump(self,rv1,rv2,rv3,rv4)
       end)

       registerFunction("pump", "e:sn", "s", function(self, args)
          local op1, op2, op3 = args[2], args[3], args[4]
          local rv1, rv2, rv3 = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3)
          return Pump(self,rv1,0,rv2,rv3)
       end)

       registerFunction("pump", "e:es", "s", function(self, args)
          local op1, op2, op3 = args[2], args[3], args[4]
          local rv1, rv2, rv3 = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3)
          return Pump(self,rv1,rv2,rv3,0)
       end)

       registerFunction("pump", "e:en", "s", function(self, args)
          local op1, op2, op3 = args[2], args[3], args[4]
          local rv1, rv2, rv3 = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3)
          return Pump(self,rv1,rv2,"all",rv3)
       end)

       registerFunction("pump", "e:e", "s", function(self, args)
          local op1, op2 = args[2], args[3]
          local rv1, rv2 = op1[1](self, op1), op2[1](self, op2)
          return Pump(self,rv1,rv2,"none",0)
       end)
    end
