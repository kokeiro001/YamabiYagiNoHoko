
-- �S�ẴX�N���v�g�t�@�C��
local allLuaFiles = 
{
	"lua/common.lua",
	"lua/debug.lua",
	"lua/coroutine.lua",
	"lua/actor.lua",
	"lua/particle.lua",
	"lua/main.lua",
	
	-- title
	"lua/titleScreen.lua",
	
	-- game
	"lua/animations.lua",
	"lua/gameScreen.lua",
	
}

-- �^�C�g���Ɋ֌W����X�N���v�g�t�@�C��
local titleLuaFiles = 
{
	"lua/titleScreen.lua"
}

-- ���C���Q�[���Ɋ֌W����X�N���v�g�t�@�C��
local gameLuaFiles = 
{
	"lua/actor.lua",
	"lua/debug.lua",
	"lua/particle.lua",
	
	"lua/animations.lua",
	"lua/gameScreen.lua"
}

-- �X�N���v�g�̃����[�h���s��
function Reload(appli, reloadType)
	print("called lua Reload type="..reloadType)
	if appli == nil then
		error("appli is nil")
	end

	local targetFiles = {}			-- �����[�h�Ώۃt�@�C��
	local reloadedFuncs = {}		-- �����[�h����s����t�@�C��
	local reloadedFuncsBuf = {}		-- �����[�h��Ɏ��s����֐��̈�v�`�F�b�N�o�b�t�@
	local isReload = true			-- �����[�h���ʏ탍�[�h��



	-- �����[�h�����ɂ��ݒ�

	-- �ʏ탍�[�h
	if reloadType == "load" then
		targetFiles = allLuaFiles
		isReload = false
	
	-- F1 �S�ă����[�h
	elseif reloadType == "all" then
		RunReloadReset()
		targetFiles = allLuaFiles

		table.insert(reloadedFuncs, function() 
			OnPower(appli)
			return true
		end)
		
	-- F2 �^�C�g�������[�h
	elseif reloadType == "title" then
		RunReloadReset()
		targetFiles = titleLuaFiles
		
		table.insert(reloadedFuncs, function() 
			OnPower(appli)
			return true
		end)
		
	-- F3 �Q�[�������[�h
	elseif reloadType == "game" then
		RunReloadReset()
		targetFiles = gameLuaFiles
		
		table.insert(reloadedFuncs, function() 
			ChangeScreen(GameScreen())
			return true
		end)
		
	else
		return false
	end

	-- �X�N���v�g�����[�h
	for i, path in ipairs(targetFiles) do
		if not appli:GetLua():DoFile(path) then
			error(appli:GetLua():GetError())
		end
		print("script<"..path.."> reload success.")
	end

	-- �����[�h�̏ꍇ�A�㏈���֐������s
	if isReload then
		for i, func in ipairs(reloadedFuncs) do
			local res, err = func()
			if res == false then
				error(err)
				return false
			end
		end
	end

	collectgarbage("collect")
	return true
end




-- �X�N���v�g�̃����[�h���s�����m�F����
function CheckReload()
	if GS.InputMgr:IsKeyPush(KeyCode.KEY_F1) then
		Reload(GS.Appli, "all")
		return true
	elseif GS.InputMgr:IsKeyPush(KeyCode.KEY_F2) then
		Reload(GS.Appli, "title")
		return true
	elseif GS.InputMgr:IsKeyPush(KeyCode.KEY_F3) then
		Reload(GS.Appli, "game")
		return true
	elseif GS.InputMgr:IsKeyPush(KeyCode.KEY_F12) then
		GS.Appli:ShowDialog("��~����ł�����")
	end
	
	return false
	
end

-- �����[�h�ɂ�郊�Z�b�g�������s��
function RunReloadReset()
	local res, err = pcall( ReloadReset )
	if res == false then
		print("error on ReloadReset() : ", err)
	end
end
