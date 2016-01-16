-- GameSystem
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
	IsPlayBgm = true,
	Param = {
		IsCleared = true
	},
}

-- デフォルト定義色
Color = {
	Transparent = ColorF(0, 0, 0, 0),
	Black = ColorF(0, 0, 0),
	White = ColorF(1, 1, 1),
	Gray	= ColorF(0.5, 0.5, 0.5),
	Red		= ColorF(1, 0, 0),
	Green	= ColorF(0, 0.5, 0),
	Blue	= ColorF(0, 0, 1)
}

-- アプリ起動時の初期化を行う
function OnPower(appli)
	-- ゲームシステムに適当なインスタンスを設定する
	GS.Appli 		= appli
	GS.DrawSys 	= DrawSystem.GetInst()
	GS.GrMgr 		= GraphicsManager.GetInst()
	GS.SoundMgr	= SoundManager.GetInst()
	GS.InputMgr	= InputManager.GetInst()
	GS.Scheduler = Scheduler()
	
	GS.DrawSys:ClearSprite()

	-- 各種リソースを読み込む

	GS.GrMgr:LoadFont("aoyagi.spb", "aoyagi.sff", "aoyagi")

	-- load textures
	GS.GrMgr:LoadTexture2("全体2.png", "titleBack")
	GS.GrMgr:LoadTexture2("yamabi.png", "yamabi")
	
	-- enemy
	GS.GrMgr:LoadTexture2("zako.png", "zako")
	GS.GrMgr:LoadTexture2("seresu.png", "celes")
	GS.GrMgr:LoadTexture2("岩.png", "rock")
	GS.GrMgr:LoadTexture2("yagi.png", "yagi")
	
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
	GS.GrMgr:LoadTexture2("氷菓.png", 	"rank")
	
	GS.GrMgr:LoadTexture2("demo_stage1start.jpg", 	"stage1start")
	GS.GrMgr:LoadTexture2("demo_stage2start.jpg", 	"stage2start")
	GS.GrMgr:LoadTexture2("demo_stage2startzoom.png", 	"stage2startzoom")
	GS.GrMgr:LoadTexture2("demo_stage3start.jpg", 	"stage3start")
	GS.GrMgr:LoadTexture2("demo_stage3clear.jpg", 	"stage3clear")
	
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
	
	-- se
	GS.SoundMgr:LoadSe("bell00.wav", "bell")
	GS.SoundMgr:LoadSe("bosu28_a.wav", "bosu")
	GS.SoundMgr:LoadSe("metal02.wav", "metal")
	GS.SoundMgr:LoadSe("burst00.wav", "burst")
	GS.SoundMgr:LoadSe("seles_damage.wav", "selesDamage")
	GS.SoundMgr:LoadSe("seles_dead.wav", "selesDead")
	GS.SoundMgr:LoadSe("slash.wav", "slash")

	GS.SoundMgr:LoadSe("yagi_01.wav", "yagi01")
	GS.SoundMgr:LoadSe("yagi_02.wav", "yagi02")
	GS.SoundMgr:LoadSe("yagi_03.wav", "yagi03")
	GS.SoundMgr:LoadSe("yagi_04.wav", "yagi04")
	GS.SoundMgr:LoadSe("yagi_05.wav", "yagi05")
	GS.SoundMgr:LoadSe("yagi_06.wav", "yagi06")

	GS.SoundMgr:SetSeVol("burst", 30)
	GS.SoundMgr:SetSeVol("selesDamage", 25)
	
	for i=1, 6 do
		GS.SoundMgr:SetSeVol("yagi0"..i, 70)
	end

	ChangeScreen(TitleScreen())
	
	collectgarbage("collect")
	return true
end

-- リロードが行われる直前に呼び出される。リロードファイルを指定する前に呼び出される。
function ReloadReset()
end

-- メインのゲームループ
function Update()
	-- リロード用のコマンドが発行されているか確認する
	CheckReload()
	
	-- フレームスキップコマンドが発行されているか確認する
	-- 発行されていた場合、指定フレームの間は描画を行わない
	local loopCnt = CheckSkip()
	for i=1, loopCnt do
		-- 次のシーンが設定されているなら、切り替える
		if GS.NextScreen ~= nil then
			if GS.CurrentScreen ~= nil then
				GS.Scheduler:DeleteActor(GS.CurrentScreen)
			end
			-- 削除フラグが立てられているActorをスケジューラから削除する
			GS.Scheduler:ProcessDeletedActors()

			-- BGMを停止する
			GS.SoundMgr:StopBgm()
			collectgarbage("collect")

			-- 切り替える
			GS.CurrentScreen = GS.NextScreen
			GS.CurrentScreen:Begin()
			GS.CurrentScreen:AddSprToDrawSystem()
			GS.Scheduler:SortActor()
			GS.NextScreen = nil
		end
	
		-- スケジューラに登録されている要素を更新する
		GS.Scheduler:Schedule()
	end
end


function ChangeScreen(screen)
	GS.NextScreen = screen
end

-- フレームスキップ数を返却する
function CheckSkip()
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_Q) then
		return 2
	end
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_W) then
		return 5
	end
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_E) then
		return 10
	end
	if GS.InputMgr:IsKeyHold(KeyCode.KEY_R) then
		return 20
	end
	return 1
end




