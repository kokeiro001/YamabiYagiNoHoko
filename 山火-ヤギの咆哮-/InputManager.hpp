#pragma once

enum eMouseButton
{
	MOUSE_LEFT,
	MOUSE_RIGHT
};

/// キーボードの入力情報を管理する
class InputManager
{
	struct KeyCntData
	{
		int holdCnt;
		int freeCnt;
	};
	struct MouseCntData
	{
		int holdCnt;
		int freeCnt;
	};

	Input::IManager* m_pIManager;
	std::map<Engine::Input::eKeyCode, KeyCntData> m_keyCounts;
	std::map<eMouseButton, MouseCntData> m_mouseCounts;
	Point2DI m_mousePos;

	void AddUseKeyCode(Selene::Engine::Input::eKeyCode key);
	void AddAllKeys();

	InputManager();
	~InputManager(void);

public:

  /// インスタンスを取得する
  static InputManager* GetInst()
	{
		static InputManager inst;
		return &inst;
	}

  /// ゲーム起動時の初期化を行う
  bool OnPowerInit(Engine::Input::IManager* mgr);

  /// キーボードの入力状況を更新する
	void Update();

	bool IsKeyFree(Engine::Input::eKeyCode key);  ///< キーが押されていなかったらtrue
	bool IsKeyHold(Engine::Input::eKeyCode key);  ///< キーが押されていたらtrue

	bool IsKeyPull(Engine::Input::eKeyCode key);  ///< キーが離された瞬間ならtrue
	bool IsKeyPush(Engine::Input::eKeyCode key);  ///< キーが押された瞬間ならtrue

	int GetKeyHoldCnt(Engine::Input::eKeyCode key); ///< キーが押下されている継続フレームを取得する
	int GetKeyFreeCnt(Engine::Input::eKeyCode key); ///< キーが離されている継続フレームを取得する


	bool IsMouseFree(eMouseButton btn); ///< マウスのボタンが押されていなかったらtrue
	bool IsMouseHold(eMouseButton btn); ///< マウスのボタンが押されていたらtrue
	bool IsMousePull(eMouseButton btn); ///< マウスのボタンが離された瞬間ならtrue
	bool IsMouseClick(eMouseButton btn);  ///< マウスのボタンがクリックされた瞬間ならtrue

	int GetMouseHoldCnt(eMouseButton key);  ///< マウスのボタンが押下されている継続フレームを取得する
	int GetMouseFreeCnt(eMouseButton key);  ///< マウスのボタンが離されている継続フレームを取得する

	Point2DI GetMousePos() { return m_mousePos; } ///< マウスカーソルの座標を取得する

	void InitOnPower();

	/// Luaで使用する機能を登録する
	static void RegistLua();
};

