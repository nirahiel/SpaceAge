local function sa_info_msg_credsc( msg )
	fa_info.credits = AddCommasToInt(msg:ReadString())
	fa_info.totalcredits = AddCommasToInt(msg:ReadString())
end
usermessage.Hook("SA_Info_CredSc", sa_info_msg_credsc) 

FA.Topbar.Register(1,"Credits","fa_info","credits")
FA.Topbar.Register(1,"Score","fa_info","totalcredits")