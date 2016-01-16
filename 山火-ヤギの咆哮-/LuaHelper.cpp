#include "StdAfx.h"
#include "LuaHelper.hpp"
#include "MyFramework.hpp"

LuaHelper::LuaHelper(void)
{
}

LuaHelper::~LuaHelper(void)
{
	Close();
}

int callbackHelper(lua_State* lua)
{
	return LuaHelper::GetInst()->ErrorCallback();
}

int LuaHelper::ErrorCallback()
{
	lua_Debug d = {};
	std::stringstream msg;

	std::string err = lua_tostring(m_pLua, -1);
	msg << "ERROR: " << err << "\n\nBacktrace:" << std::endl;

  // �X�^�b�N�g���[�X���擾����
	for (int stack_depth = 1; lua_getstack(m_pLua, stack_depth, &d); ++stack_depth)
	{
    // �擾�ł�������ς�ł���

		lua_getinfo(m_pLua, "Sln", &d);
		msg << "#" << stack_depth << " ";

    // �G���[��
		if (d.name) msg << "<" << d.namewhat << "> \"" << d.name << "\"";
		else msg << "--";
		msg << " (called";

    // �s�ԍ�
		if (d.currentline > 0) msg << " at line " << d.currentline;
		msg << " in ";

    // �֐���
		if (d.linedefined > 0) msg << "function block between line " << d.linedefined << ".." << d.lastlinedefined << " of ";
		msg << d.short_src << ")" << std::endl;
	}

	// �X�^�b�N�ɐς܂�Ă���G���[���b�Z�[�W���A�V����������ɒu������B
	lua_pop(m_pLua, 1);
	lua_pushstring(m_pLua, msg.str().c_str());

  // �G���[���b�Z�[�W�Ƃ��Ēǉ�����
	AddErr(msg.str().c_str());

	return 1;
}

bool LuaHelper::Initialize()
{
	ClearErr();

  // Lua�̉��z�}�V�����N������
	m_pLua = lua_open();

  // Lua�̕W�����C�u������ǂݍ���
	luaL_openlibs(m_pLua);

  // �f�o�b�O�@�\���X�^�b�N�ɐς�
	int top = lua_gettop(m_pLua);
	lua_getglobal(m_pLua, "debug");

  // 
	if(!lua_isnil(m_pLua, -1))
	{
		lua_getfield(m_pLua, -1, "traceback");
		m_pGetStackTraceFunc = lua_tocfunction(m_pLua, -1);
	}
	lua_settop(m_pLua, top);

	// initPrintFunc
	lua_register(m_pLua, "print", LuaHelper::LuaPrintToDebugWindows);
	lua_atpanic(m_pLua, LuaHelper::LuaPrintToDebugWindows);

	// init luabind
	luabind::open(m_pLua);
	luabind::set_pcall_callback(&callbackHelper);

	RegistLua();

	return true;
}

bool LuaHelper::ReloadLuaFiles(MyFramework* appli, const std::string arg)
{
	try
	{
		if(DoFile("lua/reload.lua") && 
			luabind::call_function<bool>(m_pLua, "Reload", appli, arg))
		{
			return true;
		}
		else
		{
			if(MessageBox(appli->GetWindowHandle(), GetErr().c_str(), "Reload OK?", MB_YESNO) != IDYES)
			{
				appli->Exit(0);
			}
			else
			{
				return false;
			}
		}
	}
	catch(luabind::error& e)
	{
		ShowErrorReloadDialog(appli, e);
		return false;
	}
	return true;
}

//bool LuaHelper::ReloadLuaFiles(const std::string reloadType, luabind::error e)
//{
//	ShowErrorReloadDialog(e);
//	return ReloadLuaFiles(reloadType);
//}
//

bool LuaHelper::ShowErrorReloadDialog(MyFramework* appli, luabind::error e)
{
	bool res = MessageBox(appli->GetWindowHandle(), GetErr().c_str(), "Reload OK?", MB_YESNO) != IDYES;
	ClearErr();
	if(res)
	{
		appli->Exit(0);
		return false;
	}
	return true;
}

void LuaHelper::Close()
{
	if(m_pLua) lua_close(m_pLua);
	m_pLua = NULL;
}

int LuaHelper::LuaPrintToDebugWindows(lua_State *L)
{
	int cnt = lua_gettop(L);
	lua_getglobal(L, "tostring");
	for(int i=0; i<cnt; i++)
	{
		lua_pushvalue(L, -1);
		lua_pushvalue(L, i+1);
		lua_call(L, 1, 1);
		const char* str = lua_tostring(L, -1);
		OutputDebugString((str) ? str : "");
		if(i != 0) OutputDebugString("\t");
		lua_pop(L, 1);
	}
	OutputDebugString("\n");
	return 0;
}

void LuaHelper::AnalyzeError(int resCall, const std::string location)
{
  // �G���[�R�[�h�𕶎���ɕϊ�����
	const char* reason = "";
	switch(resCall)
	{
	case LUA_ERRRUN: reason = "SCRIPT RUNTIME ERROR"; break;
	case LUA_ERRSYNTAX: reason = "SCRIPT SYNTAX ERROR"; break;
	case LUA_ERRMEM: reason = "SCRIPT MEMORY ERROR"; break;
	case LUA_ERRFILE: reason = "SCRIPT FILE ERROR"; break;
	default: break;
	}

  // TODO �G���[���N�����Ă݂�B���e�X�g
	const char* message = lua_tostring(m_pLua, -1);
	char errMes[1000];
	sprintf_s(errMes, "reason=%s\n%s : %s", reason, location.c_str(), message);
	SetErr(location, errMes);
}

void LuaHelper::ClearErr()
{
	sprintf_s(m_err, "");
}

void LuaHelper::AddErr(const std::string message)
{
	strcat(m_err, message.c_str());
}

void LuaHelper::SetErr(const std::string message)
{
	sprintf_s(m_err, "%s", message.c_str());
}

void LuaHelper::SetErr(const std::string location, const std::string message)
{
	sprintf_s(m_err, "%s : %s", location.c_str(), message.c_str());
}

bool LuaHelper::DoFile(const std::string path)
{
  // �X�^�b�N�g���[�X�����邽�߂̊֐����d����
	int top = lua_gettop(m_pLua);
	lua_pushcfunction(m_pLua, m_pGetStackTraceFunc);

  // Lua�X�N���v�g��ǂݍ���
	int resLoad = luaL_loadfile(m_pLua, path.c_str());
	if(resLoad != 0)
	{
    // �J���Ȃ�������
		char location[300] = "";
		sprintf_s(location, "loading file<%s>", path.c_str());
		AnalyzeError(resLoad, location);
		lua_settop(m_pLua, top);
		return false;
	}

  // ���s���ʂ��擾����
	int resCall = lua_pcall(m_pLua, 0, 0, top + 1);

	// �G���[����
	if(resCall != 0)
	{
		char location[300] = "";
		sprintf_s(location, "executing file<%s>", path.c_str());
		AnalyzeError(resCall, location);
		lua_settop(m_pLua, top);
		return false;
	}

  // �X�^�b�N���t�@�C�����s�O�̏�Ԃɖ߂�
	lua_settop(m_pLua, top);
	return true;
}

void LuaHelper::RegistLua()
{
	luabind::module(m_pLua)
	[
		luabind::class_<LuaHelper>("LuaHelper")
		.def("DoFile", &LuaHelper::DoFile)
		.def("GetError", &LuaHelper::GetErr)
	];
}
