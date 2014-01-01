#include "Stopwatch.hpp"

#define NO_OUTPUT


Stopwatch::Stopwatch(void)
{
	Reset();
}


Stopwatch::~Stopwatch(void)
{
}

void Stopwatch::Start()
{
	assert(!m_isRunning);
	m_isRunning = true;
	timeBeginPeriod(1);
	m_beginTime = timeGetTime();
}

void Stopwatch::Stop()
{
	assert(m_isRunning);
	m_isRunning = false;
	m_elapsedTicks++;
	m_elapsedMil += timeGetTime() - m_beginTime;
}

void Stopwatch::Reset()
{
	m_isRunning = false;
	m_elapsedMil = 0;
	m_elapsedTicks = 0;
}

void Stopwatch::Restart()
{
	Reset();
	Start();
}

void Stopwatch::RegistLua(lua_State* lua)
{
	luabind::module(lua)
	[
		luabind::class_<Stopwatch>("Stopwatch")
		.def(luabind::constructor<>())
		.def("IsRunning", &IsRunning)
		.def("ElapsedTicks", &ElapsedTicks)
		.def("ElapsedMil", &ElapsedMil)

		.def("Start", &Start)
		.def("Stop", &Stop)
		.def("Reset", &Reset)
		.def("Restart", &Restart)
	];
}

StopwatchManager::StopwatchManager()
	: m_runInFrame(false)
	, m_runCntPerFrame(0)
{
}

void StopwatchManager::Update()
{
	if(m_runInFrame) m_runCntPerFrame++;
	m_runInFrame = false;

	if(m_runCntPerFrame >= OUTPUT_TICK)
	{
#ifndef NO_OUTPUT
		m_runCntPerFrame = 0;
		OutputDebugString("StopwatchManager\n");
		foreach(boost::shared_ptr<Data> data, m_stopwatches)
		{
			Stopwatch& sw = data->sw;
			char str[256];
			int msec = sw.ElapsedMil();
			double ave = msec / (double)OUTPUT_TICK;
			sprintf_s(str, "  name:%s msec:%d ave:%lf\n", data->name.c_str(), msec, ave);
			sw.Reset();
			OutputDebugString(str);
		}
		OutputDebugString("_StopwatchManager\n");
#endif
	}
}

void StopwatchManager::Start(const std::string& name)
{
	m_runInFrame = true;
	GetData(name)->sw.Start();
	//m_stopwatches[name]->Start();
}

void StopwatchManager::Stop(const std::string& name)
{
	GetData(name)->sw.Stop();
	//m_stopwatches[name]->Stop();
}

void StopwatchManager::ResetAll()
{
	foreach(boost::shared_ptr<Data> data, m_stopwatches)
	{
		data->sw.Reset();
		//pair.second->Reset();
	}
}

void StopwatchManager::RestartAll()
{
	foreach(boost::shared_ptr<Data> data, m_stopwatches)
	{
		data->sw.Restart();
	}
}

boost::shared_ptr<StopwatchManager::Data> StopwatchManager::GetData(const std::string& name)
{
	foreach(boost::shared_ptr<Data> data, m_stopwatches)
	{
		if(data->name == name)
		{
			return data;
		}
	}

	boost::shared_ptr<Data> tmp = boost::shared_ptr<Data>(new Data());
	tmp->name = name;
	m_stopwatches.push_back(tmp);
	return tmp;
}
