/*
 *  dzhbitstream.h
 *  Created by dzh on 10-4-13.
 *  Copyright 2010 DZH. All rights reserved.
 *
 */

#ifndef _SIMPLEBITSTREAM_H_INCLUDE
#define _SIMPLEBITSTREAM_H_INCLUDE

#pragma pack(1)

#define SBS_EX_SUCCESS						0					// Run successfully

#define SBS_GETBITLEN_ERR					1					// Get Bit Len Error
#define SBS_GETPOS_OUTRANGE				2					// Get Pos Out of Range
#define SBS_MOVETOPOS_OUTRANGE			3					// Move To Pos Out of Range
#define SBS_DECODE_NOT_MATCH			4					// Decode Cannot Find Match
#define SBS_EXPAND_MINDATE				5					// expand min date error
#define SBS_EXPAND_MINDATE_NODATA		6					// expand min date error:no data
#define SBS_EXPAND_DAYDATE				7					// expand day date error
#define SBS_EXPAND_DAYDATE_NODATA		8					// expand day date error:no data

typedef struct
{
	unsigned char	m_wCodeBits;	
	unsigned char	m_nCodeLen;		
	unsigned char	m_nDataLen;		
	unsigned char	m_cCode;		
	unsigned int	m_dwCodeData;	
	unsigned int	m_dwDataBias;

}SIMPLEBITCODE;

typedef struct
{
	unsigned int	m_time;			//format:HHMM
	unsigned int	m_dwPrice;		//*1000
	unsigned int   m_dwVolume;		//成交量
	unsigned int   m_dwAmount;		//均价
}MMINUTE;		//走势数据

typedef struct
{
	unsigned int	m_time;			//format:HHMM
	unsigned int	m_dwPrice;		//*1000
	unsigned int   m_dwVolume;		//成交量
	unsigned int   m_dwAmount;		//均价
	unsigned int   m_dwOpenInterest;	//持仓
	//FUTUREMMINUTE(){m_time=0;m_dwPrice=0;m_dwVolume=0;m_dwAmount=0;m_dwOpenInterest=0;}
}FUTUREMMINUTE;		//走势数据

typedef struct
{
	unsigned short	m_wOpen;		//开盘时间，HHMM
	unsigned short	m_wEnd;			//收盘时间，HHMM
}TRADETIME;

typedef struct
{
	unsigned short	m_wMarket;	//市场类别				
	unsigned short    m_nNum; //下列结构的数目
	TRADETIME m_TradeTime[1];	
}MARKETTIME;

typedef struct//压缩走势数据包含的头
{
	unsigned short m_nCompressNum;//压缩分钟线的数目
	unsigned short m_nUnCompressNum;//未压缩分钟线的数目
	unsigned char m_nMinInterval;//分钟的间隔,
	unsigned char m_nExchangeNum;//交易时间数目,
}MINCPSHEAD;

/////////////
typedef struct
{
	unsigned int    m_dwLastClose;
	unsigned int    m_dwVolume;
	unsigned int    m_dwAmount;
	unsigned char	m_nInfo;
	unsigned char	m_nLevel;
	unsigned int	m_nPos;
	unsigned short	m_nNum;
}JAVA_ZSHEADDATA;

typedef struct
{
	unsigned char     m_nTag;
	unsigned char     m_nInfos;
	unsigned char     m_nLevel;
	unsigned short     m_nPos;
	unsigned short     m_nNum;
}JAVA_NEWZSHEADDATA;
/////////////////
typedef struct//压缩K线数据包含的头
{
	unsigned short m_nNum;  //数据的数目
	unsigned char m_nKLType;//表示K线周期类型
}KLINECPSHEAD;

typedef struct  MKDATA
{
	unsigned int	m_dwDate;			//日期	Format is MMDDHHMM for 5min, Format is YYYYMMDD for day
	unsigned int	m_dwOpen;			// 开盘价（元）*1000
	unsigned int	m_dwHigh;			// 最高价（元）*1000
	unsigned int	m_dwLow;			// 最低价（元）*1000
	unsigned int	m_dwClose;			// 收盘价（元）*1000
	unsigned int	m_dwVolume;			
	unsigned int	m_dwAmount;
}MKDATA;

typedef struct
{
	unsigned int	m_dwDate;			//日期	Format is MMDDHHMM for 5min, Format is YYYYMMDD for day
	unsigned int	m_dwOpen;			// 开盘价（元）*1000
	unsigned int	m_dwHigh;			// 最高价（元）*1000
	unsigned int	m_dwLow;			// 最低价（元）*1000
	unsigned int	m_dwClose;			// 收盘价（元）*1000
	unsigned int	m_dwVolume;			
	unsigned int	m_dwAmount;
	unsigned int   m_dwOpenInterest;	//持仓
}FutureMKDATA;

typedef struct	//该数据和日K线对应
{
	unsigned char	m_cTag;	//标记，取值见上面数值
	unsigned int	udd;	//价格数值
	unsigned int	upp;	//价格数值
	unsigned int	ls;		//价格数值
	unsigned int	hs;		//价格数值
	//unsigned short	d2;		//*100
	short			d3;		//*100
}BSDATA;

enum KTypes 
{
	ktypeNone		=	0x00,
	ktypeMin		=	0x01,
	ktypeMin1		=	0x01,
	ktypeMin5		=	0x02,
	ktypeMin15		=	0x03,
	ktypeMin30		=	0x04,
	ktypeMin60		=	0x05,
	ktypeMin240		=	0x06,
	ktypeDay		=	0x07,
	ktypeWeek		=	0x08,
	ktypeMonth		=	0x09,
	ktypeMax		=	0x09,
	ktypeSeason		=	0x0A,
	ktypeHalfYear	=	0x0B,
	ktypeYear		=	0x0C,
};

typedef struct
{
	unsigned int m_nMin:6;
	unsigned int m_nHour:5;
	unsigned int m_nDay:5;
	unsigned int m_nMonth:4;
	unsigned int m_nYear:12;

}MinKLTime; 

typedef struct
{
	char   cSparate;//分隔符号'{', ':'等
	unsigned short   type;
	short  attrs;
	unsigned short   length;
}JAVA_HEAD;

typedef struct	
{
	unsigned int	m_dwPrice;		//
	unsigned int   m_dwVolume;		//成交量
	unsigned int   m_dwAmount;		//均价
}CPSMIN;

typedef struct 
{
	unsigned int	m_dwPrice;		//
	unsigned int   m_dwVolume;		//成交量
	unsigned int   m_dwAmount;		//均价
	unsigned int   m_dwOpenInterest;	//持仓
}CPSFUTUREMIN;	

typedef struct
{
	unsigned int	m_dwPrice;		//
}CPSPOOLMIN;

#pragma pack()

unsigned short ExpandMinData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize, unsigned short *minTotalNum);
unsigned short NewExpandMinData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize, unsigned short *minTotalNum);

unsigned short ExpandKLineData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize);
unsigned short NewExpandKLineData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize);
unsigned short ExpandBSData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize);

#endif //_BITSTREAM_H_INCLUDE

