GS = {
	Appli = nil,
	DrawSys = nil,
	GrMgr = nil,
	SoundMgr = nil,
	InputMgr = nil,
	Scheduler = nil,
	
	CurrentScreen = nil,
	NextScreen = nil,
}

Color = {
	Transparent = ColorF(0, 0, 0, 0),
	Black = ColorF(0, 0, 0),
	White = ColorF(1, 1, 1),
	Gray	= ColorF(0.5, 0.5, 0.5),
	Red		= ColorF(1, 0, 0),
	Green	= ColorF(0, 0.5, 0),
	Blue	= ColorF(0, 0, 1)
}

function OnPower(appli)
	GS.Appli 		= appli
	GS.DrawSys 	= DrawSystem.GetInst()
	GS.GrMgr 		= GraphicsManager.GetInst()
	GS.SoundMgr	= SoundManager.GetInst()
	GS.InputMgr	= InputManager.GetInst()
	GS.Scheduler = Scheduler()
	
	GS.DrawSys:ClearSprite()

	-- load textures
	GS.GrMgr:LoadTexture2("‚â‚¬‚Ì‚Ù‚¤‚±‚¤/‘S‘Ì2.png", "titleBack")
	GS.GrMgr:LoadTexture2("player.png", "player")
	GS.GrMgr:LoadTexture2("yamabi.png", "yamabi")
	GS.GrMgr:LoadTexture2("zako.png", "zako")
	GS.GrMgr:LoadTexture2("seresu.png", "celes")
	
	GS.GrMgr:LoadTexture2("s-stage1.jpg", "stage1back")
	GS.GrMgr:LoadTexture2("s-stage2.jpg", "stage2back")
	GS.GrMgr:LoadTexture2("s-stage3.jpg", "stage3back")
	GS.GrMgr:LoadTexture2("pato.png", "patcar")
	GS.GrMgr:LoadTexture2("suriken.png", "suriken")
	GS.GrMgr:LoadTexture2("burst0.png", "burst0")
	GS.GrMgr:LoadTexture2("run_marker.png", "runMarker")
	GS.GrMgr:LoadTexture2("Šâ.png", "rock")
	GS.GrMgr:LoadTexture2("zan.png", "slash")
	
	GS.GrMgr:LoadTexture2("stage1demo.png", "stage1demo")
	GS.GrMgr:LoadTexture2("stage2demo.png", "stage2demo")
	GS.GrMgr:LoadTexture2("stage3demo.png", "stage3demo")
	
	GS.GrMgr:LoadTexture2("stage1clear.png", "stage1clear")
	GS.GrMgr:LoadTexture2("stage2clear.png", "stage2clear")
	GS.GrMgr:LoadTexture2("stage3clear.png", "stage3clear")
	
	GS.GrMgr:LoadTexture2("debug_window.png", "debugWindow")
	
	
	GS.SoundMgr:LoadSe("bell00.wav", "bell")
	GS.SoundMgr:LoadSe("bosu28_a.wav", "bosu")
	GS.SoundMgr:LoadSe("metal02.wav", "metal")
	GS.SoundMgr:LoadSe("burst00.wav", "burst")
	GS.SoundMgr:LoadSe("seles_damage.wav", "selesDamage")
	GS.SoundMgr:LoadSe("seles_dead.wav", "selesDead")
	GS.SoundMgr:LoadSe("slash.wav", "slash")

	GS.SoundMgr:SetSeVol("burst", 30)
	
	ChangeScreen(TitleScreen())
	
	collectgarbage("collect")
	return true
end

function ReloadReset()
end

function Update()
	CheckReload()
	
	if GS.NextScreen ~= nil then
		if GS.CurrentScreen ~= nil then
			GS.Scheduler:DeleteActor(GS.CurrentScreen)
		end
		GS.Scheduler:ProcessDeletedActors()
		GS.SoundMgr:StopBgm()
		collectgarbage("collect")

		GS.CurrentScreen = GS.NextScreen
		GS.CurrentScreen:Begin()
		GS.CurrentScreen:AddSprToDrawSystem()
		GS.Scheduler:SortActor()
		GS.NextScreen = nil
	end
	
	GS.Scheduler:Schedule()
end


function ChangeScreen(screen)
	GS.NextScreen = screen
end
