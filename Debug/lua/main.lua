GS = {
	Appli = nil,
	DrawSys = nil,
	GrMgr = nil,
	SoundMgr = nil,
	InputMgr = nil,
	Scheduler = nil,
	
	CurrentScreen = nil,
	NextScreen = nil,
	
	IsDebug = true,
	IsPlayBgm = false
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

	GS.GrMgr:LoadFont("aoyagi.spb", "aoyagi.sff", "ao")

	-- load textures
	GS.GrMgr:LoadTexture2("全体2.png", "titleBack")
	GS.GrMgr:LoadTexture2("yamabi.png", "yamabi")
	GS.GrMgr:LoadTexture2("zako.png", "zako")
	GS.GrMgr:LoadTexture2("seresu.png", "celes")
	GS.GrMgr:LoadTexture2("岩.png", "rock")
	
	GS.GrMgr:LoadTexture2("stage1.jpg", "stage1back")
	GS.GrMgr:LoadTexture2("stage2.jpg", "stage2back")
	GS.GrMgr:LoadTexture2("stage3.jpg", "stage3back")
	GS.GrMgr:LoadTexture2("pato.png", "patcar")
	GS.GrMgr:LoadTexture2("suriken.png", "suriken")
	
	-- particle
	GS.GrMgr:LoadTexture2("pcl_burst0.png", "burst0")
	GS.GrMgr:LoadTexture2("pcl_kudake.png", "crash")
	GS.GrMgr:LoadTexture2("pcl_zan.png", "slash")
	
	GS.GrMgr:LoadTexture2("run_marker.png", "runMarker")
	
	-- demo
	GS.GrMgr:LoadTexture2("ハイク.png", 					"haiku")
	GS.GrMgr:LoadTexture2("ハイクハイケイ.png", 	"haikuBack")
	
	GS.GrMgr:LoadTexture2("demo_Start01.jpg", 	"stage1demo")
	GS.GrMgr:LoadTexture2("demo_stage1end.jpg",	"stage1clear")

	GS.GrMgr:LoadTexture2("demo_Start02.jpg", 	"stage2demo")
	GS.GrMgr:LoadTexture2("demo_stage2end.jpg",	"stage2clear")
	
	GS.GrMgr:LoadTexture2("stage3demo.png", "stage3demo")
	GS.GrMgr:LoadTexture2("stage3clear.png", "stage3clear")
	
	GS.GrMgr:LoadTexture2("debug_window.png", "debugWindow")
	
	-- tutorial
	GS.GrMgr:LoadTexture2("asobikata/aso1.png", "aso1")
	GS.GrMgr:LoadTexture2("asobikata/aso2.png", "aso2")
	GS.GrMgr:LoadTexture2("asobikata/aso3.png", "aso3")
	GS.GrMgr:LoadTexture2("asobikata/aso4.png", "aso4")
	GS.GrMgr:LoadTexture2("asobikata/aso5.png", "aso5")
	GS.GrMgr:LoadTexture2("asobikata/aso6.png", "aso6")
	GS.GrMgr:LoadTexture2("asobikata/aso7.png", "aso7")
	GS.GrMgr:LoadTexture2("asobikata/asobikata01_back.png", "asoBack")
	GS.GrMgr:LoadTexture2("asobikata/setumei.png", "asoSetumei")
	
	
	GS.SoundMgr:LoadSe("bell00.wav", "bell")
	GS.SoundMgr:LoadSe("bosu28_a.wav", "bosu")
	GS.SoundMgr:LoadSe("metal02.wav", "metal")
	GS.SoundMgr:LoadSe("burst00.wav", "burst")
	GS.SoundMgr:LoadSe("seles_damage.wav", "selesDamage")
	GS.SoundMgr:LoadSe("seles_dead.wav", "selesDead")
	GS.SoundMgr:LoadSe("slash.wav", "slash")

	GS.SoundMgr:SetSeVol("burst", 30)
	GS.SoundMgr:SetSeVol("selesDamage", 25)
	
	ChangeScreen(TitleScreen())
	
	collectgarbage("collect")
	return true
end

function ReloadReset()
end

function Update()
	CheckReload()
	
	local loopCnt = CheckSkip()
	for i=1, loopCnt do
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
end


function ChangeScreen(screen)
	GS.NextScreen = screen
end

function CheckSkip()
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_Q) then
		return 2
	end
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_W) then
		return 3
	end
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_E) then
		return 4
	end
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_R) then
		return 5
	end
	return 1
end




