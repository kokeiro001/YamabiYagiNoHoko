#pragma once

class LuaHelper;

/// ゲームフレームワーク
class MyFramework
{
	ICore* m_pCore;
	bool m_isExiting;

	bool OnPowerInit(); ///< ゲーム起動時の初期化を行う
	bool LuaOnPower();  ///< Luaスクリプトの起点となる関数を呼び出す
	bool ReloadLuaScripts(std::string type);  ///< Luaスクリプトを再読込する

  /// Luaが持つプロパティを文字列で取得する
  std::string GetLuaPropertyString(std::string name); 
	
  /// Luaが持つプロパティを整数値で取得する
  int GetLuaPropertyInt(std::string name);

  /// メインループを開始する
	void DoMainLoop();

public:
	MyFramework(void);
	~MyFramework(void);

  /// ゲームを起動する
	void Run();

  /// ゲームを終了する
	void Exit(int code);

  /// Luaの仮想マシンを取得する
	LuaHelper* GetLua();

  /// ダイアログを表示する
  /// @return かならず０を返却する
	int ShowDialog(std::string message);

  /// ウィンドウハンドルを取得する
	HWND GetWindowHandle() { return m_pCore->GetWindow()->GetHandle(); }
};

