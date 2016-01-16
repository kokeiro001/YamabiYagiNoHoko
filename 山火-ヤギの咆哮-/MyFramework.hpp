#pragma once

class LuaHelper;

/// �Q�[���t���[�����[�N
class MyFramework
{
	ICore* m_pCore;
	bool m_isExiting;

	bool OnPowerInit(); ///< �Q�[���N�����̏��������s��
	bool LuaOnPower();  ///< Lua�X�N���v�g�̋N�_�ƂȂ�֐����Ăяo��
	bool ReloadLuaScripts(std::string type);  ///< Lua�X�N���v�g���ēǍ�����

  /// Lua�����v���p�e�B�𕶎���Ŏ擾����
  std::string GetLuaPropertyString(std::string name); 
	
  /// Lua�����v���p�e�B�𐮐��l�Ŏ擾����
  int GetLuaPropertyInt(std::string name);

  /// ���C�����[�v���J�n����
	void DoMainLoop();

public:
	MyFramework(void);
	~MyFramework(void);

  /// �Q�[�����N������
	void Run();

  /// �Q�[�����I������
	void Exit(int code);

  /// Lua�̉��z�}�V�����擾����
	LuaHelper* GetLua();

  /// �_�C�A���O��\������
  /// @return ���Ȃ炸�O��ԋp����
	int ShowDialog(std::string message);

  /// �E�B���h�E�n���h�����擾����
	HWND GetWindowHandle() { return m_pCore->GetWindow()->GetHandle(); }
};

