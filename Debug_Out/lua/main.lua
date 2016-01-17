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

-- �f�t�H���g��`�F
Color = {
	Transparent = ColorF(0, 0, 0, 0),
	Black = ColorF(0, 0, 0),
	White = ColorF(1, 1, 1),
	Gray	= ColorF(0.5, 0.5, 0.5),
	Red		= ColorF(1, 0, 0),
	Green	= ColorF(0, 0.5, 0),
	Blue	= ColorF(0, 0, 1)
}

-- �A�v���N�����̏��������s��
function OnPower(appli)
	-- �Q�[���V�X�e���ɓK���ȃC���X�^���X��ݒ肷��
	GS.Appli 		= appli
	GS.DrawSys 	= DrawSystem.GetInst()
	GS.GrMgr 		= GraphicsManager.GetInst()
	GS.SoundMgr	= SoundManager.GetInst()
	GS.InputMgr	= InputManager.GetInst()
	GS.Scheduler = Scheduler()
	
	GS.DrawSys:ClearSprite()

	-- �e�탊�\�[�X��ǂݍ���

	GS.GrMgr:LoadFont("aoyagi.spb", "aoyagi.sff", "aoyagi")

	-- load textures
	GS.GrMgr:LoadTexture2("�S��2.png", "titleBack")
	GS.GrMgr:LoadTexture2("yamabi.png", "yamabi")
	
	-- enemy
	GS.GrMgr:LoadTexture2("zako.png", "zako")
	GS.GrMgr:LoadTexture2("seresu.png", "celes")
	GS.GrMgr:LoadTexture2("��.png", "rock")
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
	GS.GrMgr:LoadTexture2("�n�C�N.png", 					"haiku")
	GS.GrMgr:LoadTexture2("�n�C�N�n�C�P�C.png", 	"haikuBack")
	GS.GrMgr:LoadTexture2("�X��.png", 	"rank")
	
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

-- �����[�h���s���钼�O�ɌĂяo�����B�����[�h�t�@�C�����w�肷��O�ɌĂяo�����B
function ReloadReset()
end

-- ���C���̃Q�[�����[�v
function Update()
	-- �����[�h�p�̃R�}���h�����s����Ă��邩�m�F����
	CheckReload()
	
	-- �t���[���X�L�b�v�R�}���h�����s����Ă��邩�m�F����
	-- ���s����Ă����ꍇ�A�w��t���[���̊Ԃ͕`����s��Ȃ�
	local loopCnt = CheckSkip()
	for i=1, loopCnt do
		-- ���̃V�[�����ݒ肳��Ă���Ȃ�A�؂�ւ���
		if GS.NextScreen ~= nil then
			if GS.CurrentScreen ~= nil then
				GS.Scheduler:DeleteActor(GS.CurrentScreen)
			end
			-- �폜�t���O�����Ă��Ă���Actor���X�P�W���[������폜����
			GS.Scheduler:ProcessDeletedActors()

			-- BGM���~����
			GS.SoundMgr:StopBgm()
			collectgarbage("collect")

			-- �؂�ւ���
			GS.CurrentScreen = GS.NextScreen
			GS.CurrentScreen:Begin()
			GS.CurrentScreen:AddSprToDrawSystem()
			GS.Scheduler:SortActor()
			GS.NextScreen = nil
		end
	
		-- �X�P�W���[���ɓo�^����Ă���v�f���X�V����
		GS.Scheduler:Schedule()
	end
end


function ChangeScreen(screen)
	GS.NextScreen = screen
end

-- �t���[���X�L�b�v����ԋp����
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



