function SA_Send_CredSc(ply)
	ply.Credits = math.floor(ply.Credits)
	ply.TotalCredits = math.floor(ply.TotalCredits)
	ply:SetNWInt("Score",ply.TotalCredits)
	umsg.Start("SA_Info_CredSc",ply)
		umsg.String(ply.Credits)
		umsg.String(ply.TotalCredits)		
	umsg.End()
end

SA_Send_AllInfos = SA_Send_CredSc
SA_Send_Main = SA_Send_CredSc