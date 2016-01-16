#pragma once

class MyFramework;

/// Luaを便利に利用するための機能を提供する
class LuaHelper
{
	char m_err[4048];
	lua_State* m_pLua;
	lua_CFunction m_pGetStackTraceFunc;

protected:

	void ClearErr();  ///< 内部で保持しているエラーメッセージを削除する
	void AddErr(const std::string message); ///< エラーメッセージを追加する
	void SetErr(const std::string message); ///< エラーメッセージを設定する
	void SetErr(const std::string location, const std::string message); ///< エラーが発生した箇所付きで、エラーメッセージを設定する
	void AnalyzeError(int resCall, const std::string location); ///< 整数値のエラーコードを適当なエラーメッセージに変換する

	/// Luaで使用する機能を登録する
	void RegistLua();

public:

	LuaHelper();
	~LuaHelper();

  /// インスタンスを取得する
	static LuaHelper* GetInst()
	{
		static LuaHelper inst;
		return &inst; 
	}
	lua_State* GetLua() { return m_pLua; }

	bool Initialize();  ///< Luaを使用するための初期化を行う
	void Close(); ///< 指定したLuaスクリプトを実行する

  /// Luaスクリプトを読み込み直す
	bool ReloadLuaFiles(MyFramework* appli, const std::string reloadType);

  /// 指定したLuaスクリプトを実行する
	bool DoFile(const std::string path);

  /// Luaスクリプトの実行中にエラーが発生した場合に呼び出される
	int ErrorCallback();

  /// 内部で保持しているエラーメッセージを取得する
	std::string GetErr() { return std::string(m_err); }

  /// エラーが発生した祭、スクリプトを再読込するかどうかのダイアログを表示する
  /// @return trueならLuaスクリプトを再読込する
	bool ShowErrorReloadDialog(MyFramework* appli, luabind::error e);

  /// Luaスクリプトから、VisualStudioのデバッグウィンドウに文字列を出力する
	static int LuaPrintToDebugWindows(lua_State* L);
};




