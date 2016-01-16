#pragma once

enum eMouseButton
{
	MOUSE_LEFT,
	MOUSE_RIGHT
};

/// �L�[�{�[�h�̓��͏����Ǘ�����
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

  /// �C���X�^���X���擾����
  static InputManager* GetInst()
	{
		static InputManager inst;
		return &inst;
	}

  /// �Q�[���N�����̏��������s��
  bool OnPowerInit(Engine::Input::IManager* mgr);

  /// �L�[�{�[�h�̓��͏󋵂��X�V����
	void Update();

	bool IsKeyFree(Engine::Input::eKeyCode key);  ///< �L�[��������Ă��Ȃ�������true
	bool IsKeyHold(Engine::Input::eKeyCode key);  ///< �L�[��������Ă�����true

	bool IsKeyPull(Engine::Input::eKeyCode key);  ///< �L�[�������ꂽ�u�ԂȂ�true
	bool IsKeyPush(Engine::Input::eKeyCode key);  ///< �L�[�������ꂽ�u�ԂȂ�true

	int GetKeyHoldCnt(Engine::Input::eKeyCode key); ///< �L�[����������Ă���p���t���[�����擾����
	int GetKeyFreeCnt(Engine::Input::eKeyCode key); ///< �L�[��������Ă���p���t���[�����擾����


	bool IsMouseFree(eMouseButton btn); ///< �}�E�X�̃{�^����������Ă��Ȃ�������true
	bool IsMouseHold(eMouseButton btn); ///< �}�E�X�̃{�^����������Ă�����true
	bool IsMousePull(eMouseButton btn); ///< �}�E�X�̃{�^���������ꂽ�u�ԂȂ�true
	bool IsMouseClick(eMouseButton btn);  ///< �}�E�X�̃{�^�����N���b�N���ꂽ�u�ԂȂ�true

	int GetMouseHoldCnt(eMouseButton key);  ///< �}�E�X�̃{�^������������Ă���p���t���[�����擾����
	int GetMouseFreeCnt(eMouseButton key);  ///< �}�E�X�̃{�^����������Ă���p���t���[�����擾����

	Point2DI GetMousePos() { return m_mousePos; } ///< �}�E�X�J�[�\���̍��W���擾����

	void InitOnPower();

	/// Lua�Ŏg�p����@�\��o�^����
	static void RegistLua();
};

