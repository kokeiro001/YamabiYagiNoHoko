#pragma once

class LuaHelper;

class MyFramework
{
	ICore* m_pCore;
	bool m_isExiting;


	bool LuaOnPower();
	bool ReloadLuaScripts(std::string type);
	bool OnPowerInit();

	std::string GetLuaPropertyString(std::string name);
	int GetLuaPropertyInt(std::string name);

	void DoMainLoop();

public:
	MyFramework(void);
	~MyFramework(void);

	void Run();
	void Exit(int code);

	LuaHelper* GetLua();

	int ShowDialog(std::string message);

	HWND GetWindowHandle() { return m_pCore->GetWindow()->GetHandle(); }
};

