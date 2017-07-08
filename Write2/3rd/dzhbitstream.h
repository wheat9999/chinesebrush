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
	unsigned int   m_dwVolume;		//�ɽ���
	unsigned int   m_dwAmount;		//����
}MMINUTE;		//��������

typedef struct
{
	unsigned int	m_time;			//format:HHMM
	unsigned int	m_dwPrice;		//*1000
	unsigned int   m_dwVolume;		//�ɽ���
	unsigned int   m_dwAmount;		//����
	unsigned int   m_dwOpenInterest;	//�ֲ�
	//FUTUREMMINUTE(){m_time=0;m_dwPrice=0;m_dwVolume=0;m_dwAmount=0;m_dwOpenInterest=0;}
}FUTUREMMINUTE;		//��������

typedef struct
{
	unsigned short	m_wOpen;		//����ʱ�䣬HHMM
	unsigned short	m_wEnd;			//����ʱ�䣬HHMM
}TRADETIME;

typedef struct
{
	unsigned short	m_wMarket;	//�г����				
	unsigned short    m_nNum; //���нṹ����Ŀ
	TRADETIME m_TradeTime[1];	
}MARKETTIME;

typedef struct//ѹ���������ݰ�����ͷ
{
	unsigned short m_nCompressNum;//ѹ�������ߵ���Ŀ
	unsigned short m_nUnCompressNum;//δѹ�������ߵ���Ŀ
	unsigned char m_nMinInterval;//���ӵļ��,
	unsigned char m_nExchangeNum;//����ʱ����Ŀ,
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
typedef struct//ѹ��K�����ݰ�����ͷ
{
	unsigned short m_nNum;  //���ݵ���Ŀ
	unsigned char m_nKLType;//��ʾK����������
}KLINECPSHEAD;

typedef struct  MKDATA
{
	unsigned int	m_dwDate;			//����	Format is MMDDHHMM for 5min, Format is YYYYMMDD for day
	unsigned int	m_dwOpen;			// ���̼ۣ�Ԫ��*1000
	unsigned int	m_dwHigh;			// ��߼ۣ�Ԫ��*1000
	unsigned int	m_dwLow;			// ��ͼۣ�Ԫ��*1000
	unsigned int	m_dwClose;			// ���̼ۣ�Ԫ��*1000
	unsigned int	m_dwVolume;			
	unsigned int	m_dwAmount;
}MKDATA;

typedef struct
{
	unsigned int	m_dwDate;			//����	Format is MMDDHHMM for 5min, Format is YYYYMMDD for day
	unsigned int	m_dwOpen;			// ���̼ۣ�Ԫ��*1000
	unsigned int	m_dwHigh;			// ��߼ۣ�Ԫ��*1000
	unsigned int	m_dwLow;			// ��ͼۣ�Ԫ��*1000
	unsigned int	m_dwClose;			// ���̼ۣ�Ԫ��*1000
	unsigned int	m_dwVolume;			
	unsigned int	m_dwAmount;
	unsigned int   m_dwOpenInterest;	//�ֲ�
}FutureMKDATA;

typedef struct	//�����ݺ���K�߶�Ӧ
{
	unsigned char	m_cTag;	//��ǣ�ȡֵ��������ֵ
	unsigned int	udd;	//�۸���ֵ
	unsigned int	upp;	//�۸���ֵ
	unsigned int	ls;		//�۸���ֵ
	unsigned int	hs;		//�۸���ֵ
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
	char   cSparate;//�ָ�����'{', ':'��
	unsigned short   type;
	short  attrs;
	unsigned short   length;
}JAVA_HEAD;

typedef struct	
{
	unsigned int	m_dwPrice;		//
	unsigned int   m_dwVolume;		//�ɽ���
	unsigned int   m_dwAmount;		//����
}CPSMIN;

typedef struct 
{
	unsigned int	m_dwPrice;		//
	unsigned int   m_dwVolume;		//�ɽ���
	unsigned int   m_dwAmount;		//����
	unsigned int   m_dwOpenInterest;	//�ֲ�
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

