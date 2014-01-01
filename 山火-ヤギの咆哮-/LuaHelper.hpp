#pragma once

class MyFramework;

class LuaHelper
{
	char m_err[4048];
	lua_State* m_pLua;
	lua_CFunction m_pGetStackTraceFunc;

protected:
	void ClearErr();
	void AddErr(const std::string message);
	void SetErr(const std::string message);
	void SetErr(const std::string location, const std::string message);
	void AnalyzeError(int resCall, const std::string location);

	void RegistLua();
public:
	LuaHelper();
	~LuaHelper();

	static LuaHelper* GetInst()
	{
		static LuaHelper inst;
		return &inst; 
	}
	lua_State* GetLua() { return m_pLua; }

	bool Initialize();
	bool ReloadLuaFiles(MyFramework* appli, const std::string reloadType);
	//bool ReloadLuaFiles(const std::string reloadType, luabind::error e);

	bool DoFile(const std::string path);

	void Close();

	int ErrorCallback();
	std::string GetErr() { return std::string(m_err); }
	bool ShowErrorReloadDialog(MyFramework* appli, luabind::error e);


	static int LuaPrintToDebugWindows(lua_State* L);
};




