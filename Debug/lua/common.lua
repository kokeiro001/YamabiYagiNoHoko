local tremove = table.remove
local rawset = rawset
local tinsert = table.insert
local pi = math.pi

-- テーブルから値をすべて削除する
function ClearTable(t)
	-- 配列要素を削除
	while tremove(t) do end
	-- それ以外の要素を削除
	for k,v in pairs(t) do
		rawset(t, k, nil)
	end
end

-- 配列型のテーブル(t)中に指定値(value)があればそれを削除して詰める。
-- 値が発見されれば元のインデックスを返す。
-- 値がなければnilを返す。
function RemoveValue(t, value)
	for i,v in ipairs(t) do
		if v == value then
			tremove(t,i)
			return i
		end
	end
	return nil
end

function CopyTable(tbl)
	local tmp = {}
	for idx, val in pairs(tbl) do
		tmp[idx] = val
	end
	return tmp
end


function ToRadian(degree)
	return (degree * pi) / 180
end






local pool


class 'List'
function List:__init()
	self.cnt = 0
	self.list = {}
end

function List:PushLeft(value)
	self.cnt = self.cnt + 1
	tinsert(self.list, 1, value)
end

function List:PushRight(value)
	self.cnt = self.cnt + 1
	tinsert(self.list, value)
end

function List:PopLeft()
	assert(self.cnt > 0)
	self.cnt = self.cnt - 1
	local value = self.list[1]
	tremove(self.list, 1)
	return value
end

function List:PopRight()
	assert(self.cnt > 0)
	self.cnt = self.cnt - 1
	local value = self.list[self.cnt]
	tremove(self.list)
	return value
end

function List:Clear()
	self.list = {}
end

function List:Count()
	return self.cnt
end

function List:Clone()
	local clone = List()
	for i = 1, self.cnt do
		clone:PushRight(self.list[i])
	end
	return clone
end

function List:At(idx)
	assert(0 < idx and idx <= self.cnt)
	return self.list[idx]
end

function List:Begin()
	return 1
end

function List:End()
	return self.cnt
end

function List:Last()
	assert(self:Count() ~= 0)
	return self.list[self.cnt]
end

function List:ToPool()
	pool:ReturnToPool(self)
end




class 'ListPool'
function ListPool:__init(cls)
	self.size = 10000
	self.dataList = List()
	for i = 1, self.size do
		self.dataList:PushRight(List())
	end
end

function ListPool:GetInstance()
	if self.dataList:Count() == 0 then
		return List()
	else
		return self.dataList:PopRight()
	end
end

function ListPool:ReturnToPool(list)
	-- todoワンチャン更に
	list:Clear()
	self.dataList.PushRight(list)
end


pool = ListPool()


