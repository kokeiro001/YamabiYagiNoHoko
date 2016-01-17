local tremove = table.remove
local rawset = rawset
local tinsert = table.insert
local pi = math.pi

-- �e�[�u������l�����ׂč폜����
function ClearTable(t)
	-- �z��v�f���폜
	while tremove(t) do end
	-- ����ȊO�̗v�f���폜
	for k,v in pairs(t) do
		rawset(t, k, nil)
	end
end

-- �z��^�̃e�[�u��(t)���Ɏw��l(value)������΂�����폜���ċl�߂�B
-- �l�����������Ό��̃C���f�b�N�X��Ԃ��B
-- �l���Ȃ����nil��Ԃ��B
function RemoveValue(t, value)
	for i,v in ipairs(t) do
		if v == value then
			tremove(t,i)
			return i
		end
	end
	return nil
end

-- �e�[�u���̒�����w�肳�ꂽ�l�������Aindex��Ԃ�
function FindValue(t, val)
	for i, v in ipairs(t) do
		if val == v then return i end
	end
	return nil
end

-- �e�[�u�����V�����[�R�s�[����
function CopyTable(tbl)
	local tmp = {}
	for idx, val in pairs(tbl) do
		tmp[idx] = val
	end
	return tmp
end

-- �֐����Ăяo��
function TryCall(func, params)
	if func ~= nil then
		if params ~= nil then
			func(unpack(params))
		else
			func(params)
		end
	end
end


-- List�̃v�[���BList�𐶐�����̂͏d�������߁A�v�[�����O���Ă���
class 'ListPool'
function ListPool:__init()
	self.size = 10000
	self.dataList = List()
	for i = 1, self.size do
		self.dataList:PushRight(List())
	end
end

-- �g�p�\�ȃ��X�g���擾����
function ListPool:GetInstance()
	-- �󂫂̃��X�g���Ȃ���΁A�V�������X�g��ԋp����
	if self.dataList:Count() == 0 then
		return List()
	else
		return self.dataList:PopRight()
	end
end

-- �g�p���I��������X�g���v�[���ɕԋp����
function ListPool:ReturnToPool(list)
	-- �ꉞ���������Ă���
	list:Clear()
	self.dataList.PushRight(list)
end