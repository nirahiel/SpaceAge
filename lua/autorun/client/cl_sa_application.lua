AppPanel = null
AppFaction = ""

AppTable = {}
--AppTKeys = {}

--CreateClientConVar("sage_appfaction","Major Miners",false,true)
--CreateClientConVar("sage_apptext","Hi",false,true)

SAppText = "Hi"
SAppFact = "Major Miners"

CSelID = ""

function SA_DoSetAppData(len, ply)
	SAppFact = net.ReadString()
	SAppText = net.ReadString()
	if SA_AppBasePanel then SA_RefreshApplications() end
end
net.Receive("sa_dosetappdata",SA_DoSetAppData)

function SA_DoAddApp(len, ply)
	local steamid = net.ReadString()
	local name = net.ReadString()
	local text = net.ReadString()
	local playtime = net.ReadString()
	local score = net.ReadString()

	AppTable[steamid] = {name, text, playtime, AddCommasToInt(score)}
	if SA_AppBasePanel then SA_RefreshApplications() end
end
net.Receive("sa_doaddapp",SA_DoAddApp)

function SA_DoDelApp( um ) 
	AppTable[um:ReadString()] = nil
	if SA_AppBasePanel then SA_RefreshApplications() end
end
usermessage.Hook("sa_dodelapp",SA_DoDelApp)

local function CreateAppGUI(BasePanel)
	local ScrX = surface.ScreenWidth()
	local ScrY = surface.ScreenHeight()
	local bPanelGiven = true
	if not BasePanel then
		bPanelGiven = false
		BasePanel = vgui.Create("DFrame")
		BasePanel:SetPos((ScrX / 2) - 320, (ScrY / 2) - 243)
		BasePanel:SetSize(640,486)
		BasePanel:SetTitle("Application Form")
		BasePanel:SetDraggable(true)
		BasePanel:ShowCloseButton(false)
		
		local CloseButton = vgui.Create( "DButton", BasePanel )
		CloseButton:SetText("X")
		CloseButton:SetPos(BasePanel:GetWide() - 25, 1)
		CloseButton:SetSize(20,20)
		CloseButton.DoClick = CloseApply
		
		local BPanel = vgui.Create ("DPanel", BasePanel)
		BPanel:SetPos(0, 25)
		BPanel:SetSize(BasePanel:GetWide(), BasePanel:GetTall() - 25)
	end
	local plisleader = LocalPlayer():GetNWBool("isleader")

	local ApplyText = vgui.Create( "DTextEntry", BasePanel )
	
	if (!plisleader) then
		ApplyText:SetValue(SAppText)
	end

	ApplyText:SetMultiline(true)
	ApplyText:SetNumeric(false)
	ApplyText:SetEnterAllowed(true)

	if (!plisleader) then
		ApplyText:SetPos(20, 55)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 380)
		ApplyText:SetUpdateOnType(true)
		ApplyText.OnTextChanged = function()
			SAppText = ApplyText:GetValue()
		end
	else
		ApplyText:SetPos(20, 80)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 355)
		ApplyText:SetEditable(false)	
	end

	local SelFCombo = vgui.Create("DMultiChoice", BasePanel)
	SelFCombo:SetEditable(false)
	SelFCombo:SetPos(20,30)
	SelFCombo:SetSize(BasePanel:GetWide() - 40, 20)
	if (!plisleader) then
		SelFCombo:AddChoice("Major Miners")
		SelFCombo:AddChoice("The Guild")
		SelFCombo:AddChoice("The Corporation")
		SelFCombo:AddChoice("Star Fleet")
		SelFCombo:ChooseOption(SAppFact)
		SelFCombo.OnSelect = function(index,value,data)
			SAppFact = data
		end
	else
		local PTimeLBL = vgui.Create("DLabel", BasePanel)
		PTimeLBL:SetPos(20, 55)
		PTimeLBL:SetSize((BasePanel:GetWide() / 2) - 30, 20)
		PTimeLBL:SetText("Playtime: NOTHING SELECTED")
		local ScoreLBL = vgui.Create("DLabel", BasePanel)
		ScoreLBL:SetPos((BasePanel:GetWide() / 2), 55)
		ScoreLBL:SetSize((BasePanel:GetWide() / 2) - 30, 20)
		ScoreLBL:SetText("Score: NOTHING SELECTED")
		
		local fValue = false
		for k, v in pairs(AppTable) do
			SelFCombo:AddChoice(v[1].." | "..k)
			fValue = true
		end 
		if (fValue) then
			SelFCombo:ChooseOptionID(1)
			CSelID = SApp_ExtractSteamID(SelFCombo:GetOptionText(1))
			if (CSelID and AppTable[CSelID]) then
				ApplyText:SetValue(AppTable[CSelID][2])
				PTimeLBL:SetText("Playtime: "..AppTable[CSelID][3])
				ScoreLBL:SetText("Score: "..AppTable[CSelID][4])
			end
		else
			CSelID = ""
		end
		SelFCombo.OnSelect = function(index,value,data)
			CSelID = SApp_ExtractSteamID(data)
			if (CSelID and AppTable[CSelID]) then
				ApplyText:SetValue(AppTable[CSelID][2])
				PTimeLBL:SetText("Playtime: "..AppTable[CSelID][3])
				ScoreLBL:SetText("Score: "..AppTable[CSelID][4])
			end
		end
	end

	if (!plisleader) then
		local ApplyButton = vgui.Create( "DButton", BasePanel )
		ApplyButton:SetText("Submit")
		ApplyButton:SetPos((BasePanel:GetWide() / 2) - 50, BasePanel:GetTall() - 45)
		ApplyButton:SetSize(100,40)
		ApplyButton.DoClick = DoApply
	else
		local AcceptButton = vgui.Create( "DButton", BasePanel )
		AcceptButton:SetText("Accept")
		AcceptButton:SetPos((BasePanel:GetWide() / 2) - 105, BasePanel:GetTall() - 45)
		AcceptButton:SetSize(100,40)
		AcceptButton.DoClick = function()
			if CSelID != "" and AppTable[CSelID] then
				RunConsoleCommand("DoAcceptPlayer",CSelID)
			end
		end
		local DenyButton = vgui.Create( "DButton", BasePanel )
		DenyButton:SetText("Deny")
		DenyButton:SetPos((BasePanel:GetWide() / 2) + 5, BasePanel:GetTall() - 45)
		DenyButton:SetSize(100,40)
		DenyButton.DoClick = function()
			if CSelID != "" and AppTable[CSelID] then
				RunConsoleCommand("DoDenyPlayer",CSelID)
			end
		end
	end

	if not bPanelGiven then
		BasePanel:MakePopup()
		BasePanel:SetVisible(false)
		AppPanel = BasePanel	
	end
end

function SApp_ExtractSteamID(optiontext)
	local temp = string.Explode("|",optiontext)
	if(#temp < 1) then return "" end
	return string.Trim(temp[#temp])
end

function StartApply()
	CreateAppGUI()
	AppPanel:SetVisible(true)
	gui.EnableScreenClicker(true)
end

function CloseApply()
	if AppPanel then
		AppPanel:SetVisible(false)
		AppPanel:Close()
		gui.EnableScreenClicker(false)
	end
end

function DoApply()
	net.Start("sa_doapplyfaction")
		net.WriteString(SAppText)
		net.WriteString(SAppFact)
	net.SendToServer()
end