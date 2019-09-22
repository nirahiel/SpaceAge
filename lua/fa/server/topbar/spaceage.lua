function SA_Send_CredSc(ply)
	ply.Credits = math.floor(ply.Credits)
	ply.TotalCredits = math.floor(ply.TotalCredits)
	ply:SetNWInt("Score",ply.TotalCredits)
	net.Start("SA_CreditsScore")
		net.WriteString(ply.Credits)
		net.WriteString(ply.TotalCredits)		
	net.Send(ply)
end

SA_Send_AllInfos = SA_Send_CredSc
SA_Send_Main = SA_Send_CredSc
