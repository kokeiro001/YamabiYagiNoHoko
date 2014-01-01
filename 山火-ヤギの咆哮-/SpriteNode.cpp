#include "StdAfx.h"

#include "Color.h"
#include "SpriteNode.hpp"
#include "boost\range\algorithm.hpp"
#include "GraphicsManager.hpp"
#include "boost\foreach.hpp"

Sprite::Sprite()
	: m_mode(SPR_NONE)
	, m_x(0.0f), m_y(0.0f), m_z(0.0f)
	, m_alpha(1.0f)
	, m_width(0.0f), m_height(0.0f), m_drawWidth(0.0f), m_drawHeight(0.0f)
	, m_centerX(0.0f), m_centerY(0.0f)
	, m_rot(0.0f), m_rotOffcetX(0.0f), m_rotOffcetY(0.0f)
	, m_pTexBuf(NULL)
	, m_isDivTex(false)
	, m_pTextRdr(NULL)
	, m_textColor(BLACK)
	, m_posType(DRAWPOS_RELATIVE)
{
}
Sprite::~Sprite()
{
	RemoveFromParent();
}

void Sprite::AddChild(boost::shared_ptr<Sprite> chr)
{
	m_children.push_back(chr);
	chr->SetParent(GetPtr());
}
void Sprite::RemoveChild(boost::shared_ptr<Sprite> chr)
{
	Itr itr = std::find(m_children.begin(), m_children.end(), chr);
	if(itr != m_children.end())
	{
		(*itr)->RemoveFromParentForce();
		m_children.erase(itr);
	}
}
void Sprite::ClearChild()
{
	Itr itr = m_children.begin();
	while(itr != m_children.end())
	{
		(*itr)->RemoveFromParent();
		itr = m_children.begin();
	}
	m_children.clear();
}
void Sprite::RemoveFromParent()
{
	if(m_pParent.lock())
	{
		m_pParent.lock()->RemoveChild(GetPtr());
		m_pParent.reset();
	}
}
void Sprite::RemoveFromParentForce()
{
	if(m_pParent.lock())
	{
		m_pParent.reset();
	}
}

void Sprite::SetAlpha(float alpha)
{ 
	m_alpha = min(max(alpha, 0.0f), 1.0f); 
	switch(m_mode)
	{
	case SPR_TEXTURE:
		m_textureColor.a = alpha;
		break;
	case SPR_TEXT:
		m_textColor.a = alpha;
		break;
	}
}

void Sprite::SetTextureMode(const char* name)
{
	if(m_mode == SPR_TEXT)
	{
		SAFE_RELEASE(m_pTextRdr);
		SimpleHelpers::CharToWChar(m_text, "", MAX_TEXT);
	}

	m_mode = SPR_TEXTURE;
	m_isDraw = true;
	m_isDivTex = false;
	m_pTexBuf = GraphicsManager::GetInst()->GetTexture(name);

	UpdateSize();
}
void Sprite::SetDivTextureMode(const char* name, int xnum, int ynum, int w, int h)
{
	if(m_mode == SPR_TEXT)
	{
		SAFE_RELEASE(m_pTextRdr);
		SimpleHelpers::CharToWChar(m_text, "", MAX_TEXT);
	}

	m_mode = SPR_TEXTURE;
	m_isDraw	= true;
	m_isDivTex		= true;
	m_pTexBuf = GraphicsManager::GetInst()->GetTexture(name);

	m_divDrawTexIdx = 0;
	m_divX = xnum;
	m_divY = ynum;
	m_divW = w;
	m_divH = h;

	m_width		= w;
	m_height	= h;
	UpdateSize();
}
void Sprite::SetTextureColorF(ColorF color)
{
	m_textureColor = color;
}

void Sprite::SetTextMode(const char* text)
{
	if(m_mode == SPR_TEXTURE)
	{
		m_pTexBuf = 0;
	}

	m_mode = SPR_TEXT;
	m_isDraw = true;
	m_fontName = Properties::GetDefFontName();
	m_fontSize = Properties::GetDefFontSize();
	m_pTextRdr = GraphicsManager::GetInst()->GetTextRenderer(m_fontName, m_fontSize);

	SetText(text);
}
void Sprite::SetText(const char* text)
{
	SimpleHelpers::CharToWChar(m_text, text, MAX_TEXT);
	UpdateSize();
}
void Sprite::SetFontSize(int size)
{
	if(m_mode == SPR_TEXT)
	{
		m_fontSize = size;
		m_pTextRdr = GraphicsManager::GetInst()->GetTextRenderer(m_fontName, m_fontSize);
		UpdateSize();
	}
}
void Sprite::SetTextColorF(ColorF color)
{
	m_textColor = color;
}
void Sprite::SetTextColor1(float r, float g, float b)
{
	m_textColor = ColorF(r, g, b, m_alpha);
}
void Sprite::SetTextColor255(int r, int g, int b)
{
	m_textColor = ColorF(r / 255.0f, b / 255.0f, b / 255.0f, m_textColor.a);
}

void Sprite::UpdateSize()
{
	if(m_mode == SPR_TEXTURE)
	{
		if(m_isDivTex)
		{
			m_drawWidth = m_divW;
			m_drawHeight = m_divH;
		}
		else
		{
			Point2DI texSize = m_pTexBuf->GetTextureSize();
			m_width = texSize.x;
			m_height = texSize.y;
			m_drawWidth = texSize.x;
			m_drawHeight = texSize.y;
		}
	}
	else if(m_mode == SPR_TEXT)
	{
		Point2DI size = m_pTextRdr->GetDrawSize(m_text);
		m_width  = size.x;
		m_height = size.y;
		m_drawWidth = size.x;
		m_drawHeight = size.y;
	}
}

void Sprite::DrawThis(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY)
{
	float revX = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseX;
	float revY = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseY;
	if(m_mode == SPR_TEXTURE)
	{
		RectF src;
		if(m_isDivTex)
		{
			int xidx = m_divDrawTexIdx % m_divX;
			int yidx = m_divDrawTexIdx / m_divX;
			src = RectF(xidx * m_divW, yidx * m_divH, m_divW, m_divH);
		}
		else
		{
			Point2DI texSize = m_pTexBuf->GetTextureSize();
			src =	RectF((float)0, (float)0, (float)texSize.x, (float)texSize.y);
		}
		pSpr->CacheReset();

		pSpr->SquareRequest(
			RectF(m_x - m_centerX + revX, m_y - m_centerY + revY, m_drawWidth, m_drawHeight),
			0,
			m_textureColor,
			src,
			m_pTexBuf,
			false,
			false,
			Engine::Graphics::State::AB_BLEND,
			m_rot,
			Point2DF(m_rotOffcetX, m_rotOffcetY));
		pSpr->CacheDraw();
	}
	else if(m_mode == SPR_TEXT)
	{
		m_pTextRdr->CacheReset();
		m_pTextRdr->DrawRequest(Point2DI(m_x  - m_centerX + revX, m_y  - m_centerY + revY), m_textColor, m_text);
		m_pTextRdr->CacheDraw();
	}

}

void Sprite::Draw(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY, int level)
{
	if(!m_isDraw) return;

	float revX = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseX;
	float revY = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseY;


	static boost::shared_ptr<Sprite> damy(new Sprite());

	if(m_children.empty())
	{
		DrawThis(pSpr, baseX, baseY);
	}
	else
	{
		m_children.push_back(damy);
		SortZ();
		foreach(boost::shared_ptr<Sprite> chr, m_children)
		{
			if(chr == damy)
			{
				DrawThis(pSpr, baseX, baseY);
			}
			else
			{
				chr->Draw(pSpr, m_x + revX, m_y + revY, level + 1);
			}
		}
		m_children.remove(damy);
	}
}

void Sprite::SortZ()
{
	m_children.sort([](boost::shared_ptr<Sprite> a, boost::shared_ptr<Sprite> b) -> bool { return a->GetZ() > b->GetZ(); });
	foreach(boost::shared_ptr<Sprite> chr, m_children)
	{
		chr->SortZ();
	}
}


void Sprite::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<Sprite, boost::shared_ptr<Sprite>>("Sprite")
		.def(luabind::constructor<>())
		.def("IsDraw", &IsDraw)
		.def("Show", &Show)
		.def("Hide", &Hide)

		.def("SetTextureMode", &SetTextureMode)
		.def("SetDivTextureMode", &SetDivTextureMode)
		.def("SetTextureColorF", &SetTextureColorF)

		.def("SetDrawPosAbsolute", &SetDrawPosAbsolute)
		.def("SetDrawPosRelative", &SetDrawPosRelative)

		.def("SetTextMode", &SetTextMode)
		.def("SetText", &SetText)
		.def("SetFontSize", &SetFontSize)
		.def("SetTextColor1", &SetTextColor1)
		.def("SetTextColorF", &SetTextColorF)
		.def("SetTextColor255", &SetTextColor255)

		.def("AddChild", &AddChild)
		.def("RemoveChild", &RemoveChild)
		.def("RemoveFromParent", &RemoveFromParent)
		.def("ClearChild", &ClearChild)
		.def("SetPos", &SetPos)
		.def("SortZ", &SortZ)

		.def("GetBounds", &GetBounds)

		.property("name", &GetName, &SetName)
		.property("alpha", &GetAlpha, &SetAlpha)
		.property("x", &GetX, &SetX)
		.property("y", &GetY, &SetY)
		.property("z", &GetZ, &SetZ)
		.def_readonly("width", &GetWidth)
		.def_readonly("height", &GetHeight)
		.property("drawWidth", &GetDrawWidth, &SetDrawWidth)
		.property("drawHeight", &GetDrawHeight, &SetDrawHeight)
		.property("cx", &GetCenterX, &SetCenterX)
		.property("cy", &GetCenterY, &SetCenterY)
		.property("rot", &GetRot, &SetRot)
		.property("rotX", &GetRotOffcetX, &SetRotOffcetX)
		.property("rotY", &GetRotOffcetY, &SetRotOffcetY)
		.property("divTexIdx", &GetDivDrawTexIdx, &SetDivDrawTexIdx)
	];
}



bool DrawSystem::OnPowerInit()
{
	m_baseSprite.reset(new Sprite());
	m_baseSprite->Show();
	RegistLua();
	return true;
}

void DrawSystem::Dispose()
{
	m_baseSprite.reset();
}

void DrawSystem::AddSprite(boost::shared_ptr<Sprite> spr)
{
	m_baseSprite->AddChild(spr);
}

void DrawSystem::RemoveSprite(boost::shared_ptr<Sprite> spr)
{
	m_baseSprite->RemoveChild(spr);
}

void DrawSystem::ClearSprite()
{
	m_baseSprite->ClearChild();
}

boost::shared_ptr<Sprite> DrawSystem::GetSprite()
{
	return boost::shared_ptr<Sprite>(new Sprite());
}

void DrawSystem::Draw()
{
	m_baseSprite->Draw(GraphicsManager::GetInst()->GetSprite(), 0, 0, 0);
}

void DrawSystem::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<DrawSystem>("DrawSystem")
		.def("GetSprite", &GetSprite)
		.def("AddSprite", &AddSprite)
		.def("RemoveSprite", &RemoveSprite)
		.def("ClearSprite", &ClearSprite)
		.scope[
			luabind::def("GetInst", &GetInst)
		]
		
	];
}



