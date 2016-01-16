-- �O���[�o����Ԃ��疈��T���Əd���̂ŁA�L���b�V�������
local coyield = coroutine.yield

-- Actor�ɂ͗B��ƂȂ�ID�����蓖�Ă�
local ActorId = 1
function GetNextActorId()
	local id = ActorId
	ActorId = ActorId + 1
	return id
end

-- Actor�N���X
-- �S�ẴQ�[�����I�u�W�F�N�g�̊�b�ƂȂ�
-- ���W�A�X�v���C�g�������A�qActor�������Ƃ��o����
class'Actor'

function Actor:__tostring()
	return "class Actor name="..self.name
end

-- ID����������΁A�����I�u�W�F�N�g�ł���
function Actor:__eq(val)
	if val.id ~= nil and val.id == self.id then
		return true
	end
	return false
end

-- ����������
function Actor:__init()
	self.id = GetNextActorId()	-- ID���擾����

	self.spr = nil

	self.x = 0
	self.y = 0
	self.name = "class Actor"
	self.params = {}
	
	self.scheduler = nil
	
	self.currentRoutine = nil
	self.stateFuncName = "StateStart"	-- �����Update�ŌĂяo�����֐���
	
	self.enable = true
	self.isDead	= false
	self.updateOrder	= 0
	
	self.parent = nil
	self.children = {}
end

-- ���W���擾����(x, y)
function Actor:GetPos()
	return self.x, self.y
end

-- ���W��ݒ肷��
function Actor:SetPos(x, y)
	self.x = x
	self.y = y
end

-- Actor��L���ɂ���
function Actor:Begin()
	if self.StateStart ~= nil then
		-- Actor�J�n�p���[�`���ɐ؂�ւ���
		if self:ChangeRoutine("StateStart") then
			GS.Scheduler:AddActor(self)
			self.scheduler = GS.Scheduler
		else
			print("change_routine failed.")
		end
	end
end

-- Actor�𖳌��ɂ���
function Actor:Dead()
	self.enable = false
	self.isDead = true
	if self.anim ~= nil then
		self.anim:Dead()
	end
	
	-- Scheduler�ɍ폜�t���O�𗧂Ă�悤�v������B
	-- �K�؂ȃ^�C�~���O�ŁA���ۂɔj�������
	GS.Scheduler:DeleteActor(self)
end

-- ���\�[�X�̔j�����s��
function Actor:Dispose()
	-- Scheduler����A�K�؂ȃ^�C�~���O�ŌĂяo�����
	self.params = nil
	self:RemoveFromParent()
	
	-- �`��V�X�e������؂藣��
	if self.spr ~= nil then
		GS.DrawSys:RemoveSprite(self.spr)
	end
	
	-- �qActor��Scheduler����؂藣��
	for i, chr in pairs(self.children) do
		GS.Scheduler:DeleteActor(chr)
	end
	self.children = {}

	self.drawSys = nil
	self.scheduler = nil
end



-- �qActor��ǉ�����
function Actor:AddChild(chr)
	chr.parent = self
	table.insert(self.children, chr)
	
	-- �q�v�f�ɃX�v���C�g���ݒ肳��Ă���ꍇ�A���g�̃X�v���C�g�Ɗ֌W�t���s��
	if chr.spr ~= nil then
		-- ���g�̃X�v���C�g����̏ꍇ�A�q�X�v���C�g��ǉ����邽�߂ɋ�̃X�v���C�g�����g�ɕt�^����
		if self.spr == nil then
			self:CreateSpr()
			self.spr:Show()
		end
		self.spr:AddChild(chr.spr)
	end
end

-- �qActor��S�č폜����
function Actor:ClearChild()
	for i, chr in pairs(self.children) do
		chr:RemoveFromParent()
	end
	self.children = {}
end

-- �w�肵���qActor���폜����
function Actor:RemoveChild(chr)
	if chr.parent == self then
		-- �X�v���C�g�̊֌W��f��
		if chr.spr ~= nil then
			self.spr:RemoveChild(chr.spr)
		end
		chr.parent = nil
		-- �qActor���܂Ƃ߂�e�[�u������폜����
		RemoveValue(self.children, chr)
	end
end

-- �eActor���玩�g��؂藣��
function Actor:RemoveFromParent()
	if self.parent ~= nil then
		-- �X�v���C�g�̊֌W��f��
		if self.spr ~= nil then
			self.spr:RemoveFromParent()
		end
		
		self.parent:RemoveChild(self)
	end
end

-- �qActor�̃e�[�u�����擾����
function Actor:GetChild()
	return self.children
end

-- id����qActor���擾����
function Actor:GetChildId(id)
	for idx, chr in ipairs(self.children) do
		if chr.id == id then
			return chr
		end
	end
	return nil
end


-- �X�v���C�g���擾����
function Actor:GetSpr()
	return self.spr
end

-- ��̃X�v���C�g���쐬���A���g�ɕt�^����
function Actor:CreateSpr()
	self.spr = Sprite()
	self.spr.name = "lua_spr actor.id="..self.id
	
	-- �eActor������ꍇ�A�e�̃X�v���C�g�Ɏ��g�̃X�v���C�g��t�^����
	if self.parent ~= nil then
		self.parent:GetSpr():AddChild(self.spr)
	end
end

-- �`��V�X�e���Ɏ��g�̃X�v���C�g��ǉ�����B�ǉ����Ȃ��ƕ`�悳��Ȃ��B
function Actor:AddSprToDrawSystem()
	if self.spr ~= nil then
		GS.DrawSys:AddSprite(self.spr)
	end
end

-- �w�肵���G�C���A�X�̉摜���X�v���C�g�ɐݒ肷��
function Actor:SetTexture(name)
	-- ���g�̃X�v���C�g����̏ꍇ�A��̃X�v���C�g�����g�ɕt�^����
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextureMode(name)
end

-- �w�肵���G�C���A�X�̉摜���X�v���C�g�ɐݒ肷��
-- @param name	�摜�̃G�C���A�X
-- @param xdiv	�g�p�摜�̉��̕�����
-- @param ydiv	�g�p�摜�̏c�̕�����
-- @param width	������̉摜�̕�(pix)
-- @param height	������̉摜�̍���(pix)
function Actor:SetDivTexture(name, xdiv, ydiv, width, height)
	-- ���g�̃X�v���C�g����̏ꍇ�A��̃X�v���C�g�����g�ɕt�^����
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetDivTextureMode(name, xdiv, ydiv, width, height)
end


-- �F��ClorF�Ŏw�肷�邱��
function Actor:SetText(text, col)
	-- ���g�̃X�v���C�g����̏ꍇ�A��̃X�v���C�g�����g�ɕt�^����
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextMode(text)
	if col ~= nil then
		self.spr:SetTextColorF(col)
	end
end

function Actor:SetText2(text, fontName, col)
	-- ���g�̃X�v���C�g����̏ꍇ�A��̃X�v���C�g�����g�ɕt�^����
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextMode2(text, fontName)
	if col ~= nil then
		self.spr:SetTextColorF(col)
	end
end

-- Actor�̍��W���X�v���C�g�ɂ��K�p����
function Actor:ApplyPosToSpr()
	self.spr.x = self.x
	self.spr.y = self.y
end

-- Actor�̍��W���X�v���C�g�ɂ��K�p����B
-- camera�𗘗p�����␳���s��
function Actor:ApplyPosToSprUseCamera(camera)
	local x, y = camera:GetValidPos()
	self.spr.x = self.x - x
	self.spr.y = self.y - y
end

-- �X�v���C�g��\������
function Actor:Show()
	self:GetSpr():Show()
end

-- �X�v���C�g���\���ɂ���
function Actor:Hide()
	self:GetSpr():Hide()
end

-- ���t���[���Ăяo�����[�`����ύX����B�����o�֐������w�肷��B
function Actor:ChangeRoutine(name)
	-- �N���X�̎������o�֐�����T��
	local f = self[name]
  if f == nil or type(f) ~= "function" then
		error("Actor:change_routine : coroutine func not found :"..name)
		return false
  end

  -- �X�P�W���[�������ݒ�̏ꍇ�A���g��o�^����
	if self.scheduler == nil then
		self.currentRoutine = Routine()
		GS.Scheduler:AddActor(self)
		self.scheduler = GS.Scheduler
	end

	-- ���[�`���ύX���ă��X�^�[�g����
	self.currentRoutine:ChangeFunc(f)
	self.state_func_name = name
	return true
end

-- ���t���[���Ăяo�����[�`����ύX����B�����Ɏw�肳�ꂽ�֐������[�`���Ƃ��Đݒ肷��B
function Actor:ChangeFunc(func)
	-- todo: Actor:ChangeRoutine�ƋL�q���d�����Ă���B���t�@�N�^�����O����B

  -- �X�P�W���[�������ݒ�̏ꍇ�A���g��o�^����
	if self.scheduler == nil then
		self.currentRoutine = Routine()
		GS.Scheduler:AddActor(self)
		self.scheduler = GS.Scheduler
	end

	-- ���[�`���ύX���ă��X�^�[�g����
	self.currentRoutine:ChangeFunc(func)
	self.state_func_name = ""
	return true
end

-- �w�肳�ꂽ�t���[�����A���[�`���̌Ăяo�����~����
function Actor:Wait(count)
	coyield("wait", count or 0)
end


-- �R���[�`��������ĂԊ֐�
function Actor:Goto(label)
	coroutine.yield("goto", label)
end

-- �R���[�`�����I������
function Actor:Exit(label)
	coroutine.yield("exit")
end

-- �A�j���[�V������ݒ肷��B������e��Animation�N���X���Q�Ƃ���
function Actor:SetAnimation(anim)
	anim:Begin()
	anim:SetOwner(self)
	self.anim = anim
end


-- ���[�`�����J�n����
function Actor:StateStart(rt)
	while true do
		rt:Wait()
	end
end




-- �w��t���[���̊ԁA�w�肳�ꂽ���x(pix)�ňړ�����
-- �ړ����̂��̂����[�`���Ƃ��Đݒ肳��邽�߁A���̓�������Ȃ���ړ����邱�Ƃ͂ł��Ȃ�
function Actor:MoveSpd(cnt, spdX, spdY)
	self.cnt = cnt
	self.spdX = spdX
	self.spdY = spdY
	self:ChangeRoutine("StateMoveSpd")
end

-- ���ۂ̈ړ����s�����[�`���B
-- �����MoveSpd�����o�֐�����Ăяo�����
function Actor:StateMoveSpd(rt)
	for i=1, self.cnt do
		self.x = self.x + self.spdX
		self.y = self.y + self.spdY
		rt:Wait()
	end
	-- �������I��������Ăяo�����[�`�������ɖ߂�
	self:Goto("StateStart")
end

-- �w�肳�ꂽ�t���[���������āA�w�肳�ꂽ���W�ֈړ�����
function Actor:Move(cnt, toX, toY)
	self.cnt = cnt
	self.fromX = self.x
	self.fromY = self.y
	self.toX = toX
	self.toY = toY
	self:ChangeRoutine("StateMove")
end

-- �����Move�����o�֐�����Ăяo�����A���ۂɈړ�������@���L�ڂ��ꂽ�����o�֐�
function Actor:StateMove(rt)
	local saX = self.fromX - self.toX
	local saY = self.fromY - self.toY
	for i=1, self.cnt do
		self.x = self.toX + saX * (1 - (i / self.cnt))
		self.y = self.toY + saY * (1 - (i / self.cnt))
		rt:Wait()
	end
	self.x = self.toX
	self.y = self.toY
	-- �������I��������Ăяo�����[�`�������ɖ߂�
	self:Goto("StateStart")
end

-- �W�����v����
-- @param maxTime as num	�ō����B�_�ɂ��ǂ蒅���܂ł̎���
-- @param maxTime as num	�ō����B�_�̍���
-- @param maxTime as num	�W�����v�[�`�����I������܂ł̎���
function Actor:MoveJump(maxTime, maxY, enableTime)
	self.srcY = self.y
	self.maxTime = maxTime
	self.maxY = maxY
	self.enableTime = enableTime
	self:ChangeRoutine("StateMoveJump")
end

-- �����MoveJump�����o�֐�����Ăяo�����A���ۂɃW�����v�̕��@���L�ڂ��ꂽ�����o�֐�
function Actor:StateMoveJump(rt)
	for i=1, self.enableTime do
		self.y = self.srcY 
						 + (2*self.maxY*i)/self.maxTime
						 -0.5*(2*self.maxY*(i*i)) / (self.maxTime * self.maxTime)
		rt:Wait()
	end
	self.y = self.srcY
	-- �������I��������Ăяo�����[�`�������ɖ߂�
	self:Goto("StateStart")
end


-- �t�F�[�h�������s���@�\��񋟂���N���X
class 'FadeHelper'(Actor)
function FadeHelper:__init(owner)
	Actor.__init(self)
	self.owner = owner
end

function FadeHelper:StateStart(rt)
	while true do
		rt:Wait()
	end
end

-- ���W�A�A���t�@�l���t�F�[�h����
function FadeHelper:Fade(cnt, fromX, fromY, fromAlpha, toX, toY, toAlpha)
	local spr = self.owner:GetSpr()
	self.cnt				= cnt
	self.fromX			= fromX
	self.fromY			= fromY
	self.fromAlpha	= fromAlpha
	self.toX				= toX
	self.toY				= toY
	self.toAlpha		= toAlpha
	
	self.owner:SetPos(fromX, fromY)
	spr.alpha = fromAlpha
	self.owner:ApplyPosToSpr()

	-- �X�v���C�g�Ɏ��g�̃A���t�@�l��K�p����B�ⓚ���p�ŏ㏑������B�ʓr�Ǘ�����ׂ��B�����������W���J���[�����������o�֐��Ńt�F�[�h���悤�Ƃ���Ȃ�Ă������܂����B�n�[�h�R�[�f�B���O�̎Y���B�������ăZ�J�C�͈łɐ��܂�B
	for i=0, spr:GetChildCnt()-1 do
		local chr = spr:GetChild(i)
		chr.alpha = self.fromAlpha
	end
	
	-- ���[�`�����J�n����
	self:ChangeRoutine("StateFade")
end

-- �����Fade�����o�֐�����Ăяo�����A���ۂɃt�F�[�h���@���L�ڂ��ꂽ�����o�֐�
function FadeHelper:StateFade(rt)
	local owner = self.owner
	local spr = owner:GetSpr()

	local len = spr:GetChildCnt()
	local saX = self.fromX - self.toX
	local saY = self.fromY - self.toY
	local saAlpha = self.fromAlpha - self.toAlpha
	
	for i=1, self.cnt do
		-- ���g�̍��W�A�A���t�@�l���X�V����
		owner.x = self.toX + saX * (1 - (i / self.cnt))
		owner.y = self.toY + saY * (1 - (i / self.cnt))
		spr.alpha = self.toAlpha + saAlpha * (1 - (i / self.cnt))
		
		-- �q�X�v���C�g�̍��W�A�A���t�@�l���X�V����
		for j=0, len-1 do
			local chr = spr:GetChild(j)
			chr.alpha = self.toAlpha + saAlpha * (1 - (i / self.cnt))
		end
		owner:ApplyPosToSpr()
		rt:Wait()
	end
	-- �������I��������Ăяo�����[�`�������ɖ߂�
	self:Goto("StateStart")
end



-- �X�e�[�W�J�n�O�̈ꖇ�G�Ƃ���\�����邽�߂ɂƂ肠�����쐬���ꂽ�N���X�B���A���g�͋�B
-- �g���������Ȃ������ɂ̓R�R�ɋ@�\��ǉ����Ă���
class 'DemoActor'(Actor)
function DemoActor:__init()
	Actor.__init(self)
end

function DemoActor:StateStart(rt)
	while true do
		rt:Wait()
	end
end








-- �}�E�X�̍��W��\������@�\��񋟂���N���X�B
class 'DebugMouseViewer'(Actor)
function DebugMouseViewer:__init()
	Actor.__init(self)
end

function DebugMouseViewer:Begin()
	Actor.Begin(self)
	self:SetText("tmp")
	self:GetSpr():SetFontSize(12)
	self:GetSpr().z = -100000000	-- ��O�ɕ`�悷��
end

function DebugMouseViewer:StateStart(rt)
	-- �}�E�X�̍��W��\������
	local prePos = Point2DI()
	while true do
		local pos = GS.InputMgr:GetMousePos()
		if pos.x ~= prePos.x and pos.y ~= prePos.y then
			prePos = pos
			self:GetSpr():SetText(string.format("MousePos(%3d, %3d)", pos.x, pos.y))
		end
		rt:Wait()
	end
end
