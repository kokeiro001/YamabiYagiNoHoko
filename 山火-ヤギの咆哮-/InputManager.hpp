#pragma once

enum eMouseButton
{
	MOUSE_LEFT,
	MOUSE_RIGHT
};

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
	bool OnPowerInit(Engine::Input::IManager* mgr);

	static InputManager* GetInst()
	{
		static InputManager inst;
		return &inst;
	}

	void Update();

	bool IsKeyFree(Engine::Input::eKeyCode key);
	bool IsKeyHold(Engine::Input::eKeyCode key);
	bool IsKeyPull(Engine::Input::eKeyCode key);
	bool IsKeyPush(Engine::Input::eKeyCode key);

	int GetKeyHoldCnt(Engine::Input::eKeyCode key);
	int GetKeyFreeCnt(Engine::Input::eKeyCode key);

	bool IsMouseFree(eMouseButton btn);
	bool IsMouseHold(eMouseButton btn);
	bool IsMousePull(eMouseButton btn);
	bool IsMouseClick(eMouseButton btn);

	int GetMouseHoldCnt(eMouseButton key);
	int GetMouseFreeCnt(eMouseButton key);

	Point2DI GetMousePos() { return m_mousePos; }

	void InitOnPower();

	static void RegistLua();
};

