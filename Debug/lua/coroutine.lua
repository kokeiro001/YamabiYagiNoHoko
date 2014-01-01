local costatus = coroutine.status
local coresume = coroutine.resume
local coyield = coroutine.yield

class 'Scheduler'

-- �R���X�g���N�^
function Scheduler:__init()
	self.actors = {}					-- �X�P�W���[���ΏۃA�N�^�[���X�g
	self.addedActors = {}		-- �X�P�W���[�����ɒǉ����ꂽ�A�N�^�[
	self.deletedActors = {}	-- �X�P�W���[�����ɍ폜���ꂽ�A�N�^�[
	self.deleteTmp = {}			-- �폜�p�e���|�����e�[�u��
	self.actorSortFlag = false
end

-- �A�N�^�[�P���X�P�W���[������
function Scheduler:ScheduleActor(act)
	local rt = act.currentRoutine
	if rt ~= nil and rt.co ~= nil then
		if rt.waitCnt == 0 then
			if act.enable then
				-- �A�N�^�[�̏�Ԋ֐����ĊJ
				local ret = rt:Resume(act)
				
				if ret == "exit" then
					-- "exit"���Ԃ����΃A�N�^�[�폜
					self:DeleteActor(act)
				elseif ret == false then
					-- �G���[�̏ꍇ
					error("Scheduler:ScheduleActor Routine:resume() call error")
				end
			end
		elseif rt.waitCnt > 0 then
			-- �E�G�C�g����
			rt.waitCnt = rt.waitCnt-1
		end
	end
end

-- �S�ẴA�N�^�[���X�P�W���[������
function Scheduler:Schedule()
	-- �ǉ��E�폜���ꂽ�A�N�^�[�����C���ɔ��f
	self:AddActor_sub(self.addedActors)
	self:DeleteActor_sub()
	ClearTable(self.addedActors)
	
	-- �A�N�^�[��update_order�~���Ń\�[�g
	if self.actorSortFlag then
		self.actorSortFlag = false;
		self:SortActor_sub()
	end
	
	-- �A�N�^�[���X�P�W���[�����s
	local count = 0
	for i,act in ipairs(self.actors) do
		if act ~= false and self.deletedActors[act] == nil then
			self:ScheduleActor(act)
			count = count + 1
		end
	end
	
	-- �������ɒǉ����ꂽ�A�N�^�[������ɃX�P�W���[�����s�A���J��Ԃ�
	-- �i�ǉ��������ɕʂ̃A�N�^�[���ǉ�����邱�Ƃ�����j
	while next(self.addedActors) ~= nil do
		local addedTmp = self.addedActors
		self.addedActors = {}
		for act,v in pairs(addedTmp) do
			-- �폜���X�g�ɓo�^����Ă���Βǉ����~
			if act.isDead then
				addedTmp[act] = false
			end
		end
		self:AddActor_sub(addedTmp)
		self:DeleteActor_sub()
	end
	
	self:ProcessDeletedActors()
end




-- �A�N�^�[���폜����
-- ���ۂɂ́A�폜�p�̗\��e�[�u���ɓo�^���Ă����A
-- �K�؂ȃ^�C�~���O�Ń��C���̃e�[�u������폜����
function Scheduler:DeleteActor(act)
	act.isDead = true
	self.deletedActors[act] = true
end

-- �폜���ꂽ�A�N�^�[���i�Ȃ��Ȃ�܂Łj����
function Scheduler:ProcessDeletedActors()
	-- �폜�e�[�u������ɂȂ�܂ō폜�������J��Ԃ�
	-- �i�폜�������ɕʂ̃A�N�^�[���폜����邱�Ƃ�����j
	while next(self.deletedActors) ~= nil do
		self:DeleteActor_sub()
	end
end


-- �w��A�N�^�[�i�����j���폜����T�u���[�`��
-- �폜����Ƃ��Aactor.funcs.destroy�֐����Ă�
-- �폜���ꂽ�A�N�^�[�ɂ��ẮA�����œn�����e�[�u������L�[�����������B
function Scheduler:DeleteActor_sub()
	-- ���폜�������ɂ���ɍ폜�Ώۂ�������ƃe�[�u�������������A���[�v�����܂�
	-- ���Ȃ����߁A��ɃR�s�[���Ă���
	if next(self.deletedActors) == nil then
		return
	end

	local deletedActors = self.deletedActors
	local deleteTmp = self.deleteTmp
	for act,v in pairs(deletedActors) do
		deleteTmp[act] = v
	end
	ClearTable(self.deletedActors)

	-- �폜���ꂽ�A�N�^�[�ɂ��Ă͌�(false)�ɕύX����
	for act,_ in pairs(deleteTmp) do
		local is_deleted = false
		for i,v in ipairs(self.actors) do
			--if v == act then
			if v == act then
				-- destroy�֐����Ă�
				if act.Dispose ~= nil then
					act:Dispose()
				end
				
				-- �e�[�u���v�f������
				self.actors[i] = false
				
				is_deleted = true
			end
		end
		if not is_deleted then
			-- ��Ԋ֐��̂Ȃ��P�Ȃ�Actor�̏ꍇ�͂����ɂ���
			-- print("not deleted : ", act.classname, tostring(act)) �e����؂藣��
			-- act:delete_internal(self)
			if act.Dispose ~= nil then
				act:Dispose()
			end
		end
	end

	ClearTable(self.deleteTmp)
end


-- �A�N�^�[��ǉ�����
-- ���ۂɂ́A�ǉ��p�̗\��e�[�u���ɓo�^���Ă����A
-- �K�؂ȃ^�C�~���O�Ń��C���̃e�[�u���ɒǉ�����
function Scheduler:AddActor(act)
	self.addedActors[act] = true
end

-- �w��A�N�^�[�i�����j��ǉ�����
function Scheduler:AddActor_sub(addedActors)
	-- �����ɒǉ�
	local nextAct = nil
	local flag = false
	while true do
		nextAct, flag = next(addedActors, nextAct)
		if nextAct == nil then
			return -- added�e�[�u���̏I�[�Ȃ̂ŏI��
		end
		if flag == true and not nextAct.isDead then
			table.insert(self.actors, nextAct)
		end
	end
end


function Scheduler:SortActor()
	self.actorSortFlag = true
end

function Scheduler:SortActor_sub()
	-- �\�[�g�̑O�ɖ����Ȃ�����폜����
	local tmpActors = {}
	for i,v in ipairs(self.actors) do
		if v ~= false then -- flag��true�Ȃ�Α��݁B
			table.insert(tmpActors, v)
		end
	end
	self.actors = tmpActors

	table.sort(self.actors, 
		function(a, b)
 			return (a.updateOrder < b.updateOrder)
		end)
end



-- routine state
-- "end": ����I��������ԁi�֐������ւ��Čp���ł���j
-- "run": �֐����s���i�֐�����ւ����Ȃ��j


class 'Routine'
function Routine:__init(func)
	self.co = nil
	self.func = nil
  self.actor = nil
	self.state = "init"
	self.name = "rt"
	self.waitCnt = 0
	if func ~= nil then
		self:ChangeRoutine(func)
	end
end

function Routine:__tostring(self)
	return("class Routine name="..self.name)
end

-- ���[�`�����ĊJ
function Routine:Resume(actor)
	self.actor = actor

	if self.waitCnt > 0 then
		self.waitCnt= self.waitCnt - 1
		return true
	end
	
	-- �������[�v���Ȃ��悤�A���E�����߂Ă���
	for i=0, 10 do 
		if not self.co then
			return true
		end
		if costatus(self.co) == "dead" then
			return true
		end
		-- �R���[�`���ĊJ
		local res, value, value2 = coresume(self.co, self)
		if not res then
			local stacktrace = debug.traceback(self.co, 10)
			error("\nRoutine:resume() error".."\n"..stacktrace)
		end
		-- yield�̕Ԃ�l�ɂ���ď���
		if value == "exit" then					-- ���[�`���I��
			return "exit"
		elseif value == "restart" then	-- ���[�`���ċN��
			self:Restart()
		elseif value == "goto" then			-- �ʂ̃��[�`���Ɉړ�
			actor:ChangeRoutine(value2)
		elseif value == "wait" then -- ����N���܂ł̃E�G�C�g�ݒ�
			self.waitCnt = value2
			return true
		else
			error("Routine:resume() : unknown yield command from: "..tostring(actor.classname).." return value :"..tostring(value))
		end
	end

	print("Routine:resume() : too many loop on actor :", actor)
	return false
end

-- �R���[�`�����쐬���Ȃ���
function Routine:Restart()
	if self.state == "end" then
		return true -- �R���[�`�����T�C�N���\��Ԃ̂��߁A���Ȃ����K�v���Ȃ�
	end
	
	-- ���func�����ւ�����悤�ɁA�P�i�֐������܂��Ă���
	local function caller(rt)
		if rt ~= self then
			error("rt ~= self")
		end
		local label
		while true do
			if self.func == nil then
				error("attemt to resume empty Routine : ret :"..tostring(ret)..","..tostring(label)
						.." actor class:"..tostring(self.actor.classname) )
			end
			self.state = "run"
			ret, label = self.func(self.actor, rt)
			self.state = "end"
			
			-- restart�̏ꍇ��nil�ɂł��Ȃ�
			if ret ~= "restart" then
				self.func = nil
			end

			coyield(ret, label)
		end
	end

	self.waitCnt = 0
			
	-- �R���[�`���쐬
	self.co = coroutine.create(caller)
	self.state = "end"
	
	return true
end

function Routine:ChangeFunc(func)
	self.func = func
	self:Restart()
end

function Routine:Wait(cnt)
	coyield("wait", cnt or 0)
end











