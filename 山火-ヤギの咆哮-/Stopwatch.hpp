#pragma once

class Stopwatch
{
	bool m_isRunning;
	int m_elapsedMil;
	int m_elapsedTicks;
	int m_beginTime;
public:
	Stopwatch(void);
	~Stopwatch(void);

	void Start();
	void Stop();
	void Reset();
	void Restart();

	bool IsRunning() const { return m_isRunning; }
	int ElapsedTicks() const { return m_elapsedTicks; }
	int ElapsedMil() const { return m_elapsedMil; }

	static void RegistLua(lua_State* lua);
};


class StopwatchManager
{
	struct Data
	{
		std::string name;
		Stopwatch sw;
	};
	
	static const int OUTPUT_TICK = 10;
	typedef std::pair<std::string, boost::shared_ptr<Data>> Pair ;

	StopwatchManager();

	bool m_runInFrame;
	int m_runCntPerFrame;
	std::vector<boost::shared_ptr<Data>> m_stopwatches;

	boost::shared_ptr<Data> GetData(const std::string& name);
public:
	static StopwatchManager* GetInst()
	{
		static StopwatchManager inst;
		return &inst;
	}

	void Update();

	void Start(const std::string& name);
	void Stop(const std::string& name);
	void ResetAll();
	void RestartAll();
};