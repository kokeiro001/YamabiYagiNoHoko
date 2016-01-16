#pragma once

class MyFramework;

/// Lua��֗��ɗ��p���邽�߂̋@�\��񋟂���
class LuaHelper
{
	char m_err[4048];
	lua_State* m_pLua;
	lua_CFunction m_pGetStackTraceFunc;

protected:

	void ClearErr();  ///< �����ŕێ����Ă���G���[���b�Z�[�W���폜����
	void AddErr(const std::string message); ///< �G���[���b�Z�[�W��ǉ�����
	void SetErr(const std::string message); ///< �G���[���b�Z�[�W��ݒ肷��
	void SetErr(const std::string location, const std::string message); ///< �G���[�����������ӏ��t���ŁA�G���[���b�Z�[�W��ݒ肷��
	void AnalyzeError(int resCall, const std::string location); ///< �����l�̃G���[�R�[�h��K���ȃG���[���b�Z�[�W�ɕϊ�����

	/// Lua�Ŏg�p����@�\��o�^����
	void RegistLua();

public:

	LuaHelper();
	~LuaHelper();

  /// �C���X�^���X���擾����
	static LuaHelper* GetInst()
	{
		static LuaHelper inst;
		return &inst; 
	}
	lua_State* GetLua() { return m_pLua; }

	bool Initialize();  ///< Lua���g�p���邽�߂̏��������s��
	void Close(); ///< �w�肵��Lua�X�N���v�g�����s����

  /// Lua�X�N���v�g��ǂݍ��ݒ���
	bool ReloadLuaFiles(MyFramework* appli, const std::string reloadType);

  /// �w�肵��Lua�X�N���v�g�����s����
	bool DoFile(const std::string path);

  /// Lua�X�N���v�g�̎��s���ɃG���[�����������ꍇ�ɌĂяo�����
	int ErrorCallback();

  /// �����ŕێ����Ă���G���[���b�Z�[�W���擾����
	std::string GetErr() { return std::string(m_err); }

  /// �G���[�����������ՁA�X�N���v�g���ēǍ����邩�ǂ����̃_�C�A���O��\������
  /// @return true�Ȃ�Lua�X�N���v�g���ēǍ�����
	bool ShowErrorReloadDialog(MyFramework* appli, luabind::error e);

  /// Lua�X�N���v�g����AVisualStudio�̃f�o�b�O�E�B���h�E�ɕ�������o�͂���
	static int LuaPrintToDebugWindows(lua_State* L);
};




