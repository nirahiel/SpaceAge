function _R.Player:UniqueID2() 
    if !self._UniqueID then
        self._UniqueID = util.CRC("gm_"..self:SteamID().."_gm") 
    end
    return self._UniqueID 
end