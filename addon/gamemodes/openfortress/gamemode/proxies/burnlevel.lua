function PROXY:Init(mat, kv)	local var_blendmode = mat:FindVar("$detailblendmode")	if var_blendmode then		var_blendmode:SetIntValue(1)	end		local var_result = mat:FindVar(kv:GetString("resultVar") or "")	if not var_result then return false end		self.Result = var_result	return trueendfunction PROXY:OnBind(ent)	if not self.Result then return end		self.Result:SetFloatValue(ent:GetProxyVar("BurnLevel") or 0)endfunction PROXY:GetMaterial()	if not self.Result then return end		return self.Result:GetOwningMaterial()end