
-- 全てのスクリプトファイル
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

-- タイトルに関係するスクリプトファイル
local titleLuaFiles = 
{
	"lua/titleScreen.lua"
}

-- メインゲームに関係するスクリプトファイル
local gameLuaFiles = 
{
	"lua/actor.lua",
	"lua/debug.lua",
	"lua/particle.lua",
	
	"lua/animations.lua",
	"lua/gameScreen.lua"
}

-- スクリプトのリロードを行う
function Reload(appli, reloadType)
	print("called lua Reload type="..reloadType)
	if appli == nil then
		error("appli is nil")
	end

	local targetFiles = {}			-- リロード対象ファイル
	local reloadedFuncs = {}		-- リロード後実行するファイル
	local reloadedFuncsBuf = {}		-- リロード後に実行する関数の一致チェックバッファ
	local isReload = true			-- リロードか通常ロードか



	-- リロード引数による設定

	-- 通常ロード
	if reloadType == "load" then
		targetFiles = allLuaFiles
		isReload = false
	
	-- F1 全てリロード
	elseif reloadType == "all" then
		RunReloadReset()
		targetFiles = allLuaFiles

		table.insert(reloadedFuncs, function() 
			OnPower(appli)
			return true
		end)
		
	-- F2 タイトルリロード
	elseif reloadType == "title" then
		RunReloadReset()
		targetFiles = titleLuaFiles
		
		table.insert(reloadedFuncs, function() 
			OnPower(appli)
			return true
		end)
		
	-- F3 ゲームリロード
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

	-- スクリプトをロード
	for i, path in ipairs(targetFiles) do
		if not appli:GetLua():DoFile(path) then
			error(appli:GetLua():GetError())
		end
		print("script<"..path.."> reload success.")
	end

	-- リロードの場合、後処理関数を実行
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




-- スクリプトのリロードを行うか確認する
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
		GS.Appli:ShowDialog("停止するでござる")
	end
	
	return false
	
end

-- リロードによるリセット処理を行う
function RunReloadReset()
	local res, err = pcall( ReloadReset )
	if res == false then
		print("error on ReloadReset() : ", err)
	end
end
