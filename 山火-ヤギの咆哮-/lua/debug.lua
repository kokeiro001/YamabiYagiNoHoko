-- �f�o�b�O�v�̋@�\��񋟂��܂�

-- �X�g�b�v�E�H�b�`�̒l�����I�Ƀf�o�b�O�R���\�[���ɏo�͂���Ƃ��̎��ԊԊu(�t���[��)
local OutputTiming = 10

class 'Debug'
function Debug:__init()
	self.indent = 0
	self.runStopwatch = false
	
	-- �ȈՕ`��p�X�v���C�g�̊m��
	self.textSprits = {}
	for i=1, 16 do
		local spr = Sprite()
		spr:SetTextMode("debug_kakuho")
		spr.visible = false
		table.insert(self.textSprits, spr)
	end
end

function Debug:Init()
	self.indent = 0
end

-- �C���f���g���w�肵�ăf�o�b�O�R���\�[���ɕ������`�悵�܂�
function Debug:iprint(text, indent)
	-- ���̃C���f���g�̐[���{�����́uindent�v
	if indent ~= nil then
		indent = indent + self.indent
		for i = 1, indent do
			text = " "..text
		end
	end
	print(text)
end

-- �C���f���g�̐[����ݒ肵�܂�
function Debug:SetIndent(indent)
	self.indent = indent
end

-- �C���f���g�̐[�����P�i�[�����܂�
function Debug:AddIndent()
	self.indent = self.indent + 1
end

--�@�C���f���g�̐[�����P�i�󂭂��܂�
function Debug:DecIndent()
	self.indent = self.indent - 1
end

-- �X�g�b�v�E�H�b�`�Q�����������܂�
function Debug:InitStopwatch()
	self.outputStopwatch = 0
	self.wrapStopwatch = Stopwatch()
	self.currentStopwatch = nil
	self.stopwatches = {}
	
	self.swNameArray = {}
end

-- �X�g�b�v�E�H�b�`�Ōv�����J�n���܂�
function Debug:StartStopwatch(name)
	-- ��x�ɋN����������X�g�b�v�E�H�b�`�͈�����ł�
	-- todo: �����N���ł����ق����֗��ł���B�g�p��ύX���ׂ��ł���B
	assert(self.currentStopwatch == nil)
	
	self.wrapStopwatch:Start()
	
	-- ���߂Ďg�p����X�g�b�v�E�H�b�`���ł���΁A�L���b�V�����쐬����
	if self.stopwatches[name] == nil then
		self.stopwatches[name] = Stopwatch()
		self.stopwatchIdx = 0
		table.insert(self.swNameArray, name)
	end
	-- �X�g�b�v�E�H�b�`�ɂ��v�����J�n����
	self.stopwatches[name]:Start()
	self.currentStopwatch = self.stopwatches[name]
	self.runStopwatch = true
end

-- ���삵�Ă���X�g�b�v�E�H�b�`��؂�ւ���
function Debug:ChangeStopwatch(name)
	-- �N�����̃X�g�b�v�E�H�b�`���Ȃ���Ύ�
	assert(self.currentStopwatch ~= nil)
	self.currentStopwatch:Stop()

	-- ���߂Ďg�p����X�g�b�v�E�H�b�`���ł���΁A�L���b�V�����쐬����
	if self.stopwatches[name] == nil then
		self.stopwatches[name] = Stopwatch()
		table.insert(self.swNameArray, name)
	end

	-- �X�g�b�v�E�H�b�`�ɂ��v�����J�n����
	self.stopwatches[name]:Start()
	self.currentStopwatch = self.stopwatches[name]
end

-- �X�g�b�v�E�H�b�`���~����
function Debug:StopStopwatch(name)
	-- todo: name�������v��Ȃ���ԁB�����̃X�g�b�v�E�H�b�`���N���ł���悤�ɂ��邽�߂̏����B

	-- �N�����̃X�g�b�v�E�H�b�`���Ȃ���Ύ�
	assert(self.currentStopwatch ~= nil)

	-- �X�g�b�v�E�H�b�`���~����
	self.currentStopwatch:Stop()
	self.currentStopwatch = nil

	self.wrapStopwatch:Stop()
end

-- �f�o�b�O�����X�V���܂�
function Debug:Update()
	-- �X�g�b�v�E�H�b�`���N�����Ȃ�A����I�Ƀf�o�b�O�����f�o�b�O�R���\�[���ɕ\������
	if self.runStopwatch then
		-- ���t���[�����ƂɃf�o�b�O�R���\�[���ɕ\������
		self.outputStopwatch = self.outputStopwatch + 1
		if self.outputStopwatch == OutputTiming then
			
			-- �o�ߎ��ԁA1�t���[��������̌v�����Ԃ�\������
			local pfunc = function(name, sw)
				local msec = sw:ElapsedMil()
				local ave = msec / OutputTiming
				local text = "name:"..name.." msec:"..msec.." ave:"..ave
				self:iprint(text, 1)
			end

			-- �t���[���S�̂ł����������Ԃ�\������
			self:iprint("Stopwatch")
			pfunc("all", self.wrapStopwatch)
			
			-- �e�X�g�b�v�E�H�b�`���Ƃɂ����������Ԃ�\������
			for idx, name in pairs(self.swNameArray) do
				local sw = self.stopwatches[name]
				pfunc(name, sw)
				sw:Reset()
			end
			self:iprint("_Stopwatch")

			-- �S�̌v���p�X�g�b�v�E�H�b�`�����Z�b�g����
			self.wrapStopwatch:Reset()
			self.outputStopwatch = 0
		end
	end
	self.runStopwatch = false
end

-- �w�肳�ꂽ�E�B���h�E���W�Ƀf�o�b�O����`�悷��
function Debug:Print(x, y, text)
	-- todo: �������ł���
	if true then
	end
end










