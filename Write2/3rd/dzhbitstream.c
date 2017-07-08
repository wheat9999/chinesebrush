#include <stdio.h>
#include "dzhbitstream.h"


// SIMPLEBITCODE
////////////////////////////////////////////////////////////

typedef struct
{
	unsigned char* m_pData;				
	int m_nBitSize;			
	int m_nCurPos;		
	
	int m_nSavedPos;	
	
	const SIMPLEBITCODE* m_pCodes;
	int	m_nNumCode;
	int	m_nStatus;				
}SIMPLEBITSTREAM;


int IsOriginalData(const SIMPLEBITCODE* pBitCode);
int IsBitPos(const SIMPLEBITCODE* pBitCode);

void InitialBitStream(SIMPLEBITSTREAM* pStream, unsigned char* pData,int nSize);
int GetStatus(SIMPLEBITSTREAM* pStream);
void SetStatus(SIMPLEBITSTREAM* pStream, int nStatus);
const char* GetStatusDesc(int nStatus);
int GetCurPos(SIMPLEBITSTREAM* pStream);

unsigned int Get(SIMPLEBITSTREAM* pStream, int nBit);	
int GetNoMove(SIMPLEBITSTREAM*pStream, int nBit,unsigned int* dw);

int Move(SIMPLEBITSTREAM* pStream, int nBit);
int MoveTo(SIMPLEBITSTREAM* pStream, int nPos);	

void SaveCurrentPos(SIMPLEBITSTREAM* pStream);	
int  RestoreToSavedPos(SIMPLEBITSTREAM* pStream);

void SetBitCode(SIMPLEBITSTREAM* pStream, const SIMPLEBITCODE* pCodes,int nNumCode);

unsigned int DecodeData(SIMPLEBITSTREAM* pStream, unsigned int dwLastData, int bReverse);

const SIMPLEBITCODE* DecodeFindMatch(SIMPLEBITSTREAM* pStream, unsigned int* dw);	

#define SETSIMPLEBITCODE(x,y)	SetBitCode(x, y, sizeof(y)/sizeof(y[0]))
/////////////////////////////////////
int IsOriginalData(const SIMPLEBITCODE* pBitCode)
{
	if (pBitCode->m_cCode == 'D' || pBitCode->m_cCode == 'M')
		return 1;
	else 
		return 0;
}

int IsBitPos(const SIMPLEBITCODE* pBitCode)
{
	if (pBitCode->m_cCode == 'P')
		return 1;
	else
		return 0;
}

// SIMPLEBITSTREAM
////////////////////////////////////////////////////////////////////////////////////////////
static char* StatusDesc[] =
{
	"Run successfully",						// 0		-->SBS_EX_SUCCESS
	"Get Bit Len Error",					// 1		-->SBS_GETBITLEN_ERR
	"Get Pos Out of Range",					// 2		-->SBS_GETPOS_OUTRANGE
	"Move To Pos Out of Range",				// 3		-->SBS_MOVETOPOS_OUTRANGE
	"Decode Cannot Find Match",				// 4		-->SBS_DECODE_NOT_MATCH
	"expand min date error",				// 5		-->SBS_EXPAND_MINDATE
	"expand min date error:no data",		// 6		-->SBS_EXPAND_MINDATE_NODATA
	"expand day date error",				// 7		-->SBS_EXPAND_DAYDATE
	"expand day date error:no data"			// 8		-->SBS_EXPAND_DAYDATE_NODATA
};

int GetStatus(SIMPLEBITSTREAM* pStream)
{
	return pStream->m_nStatus;
}

void SetStatus(SIMPLEBITSTREAM* pStream, int nStatus)
{
	pStream->m_nStatus = nStatus;
}

const char* GetStatusDesc(int nStatus)
{
	char *strTmp;

	switch(nStatus)
	{
	case SBS_GETBITLEN_ERR:
		strTmp = StatusDesc[1];
		break;
	case SBS_GETPOS_OUTRANGE:
		strTmp = StatusDesc[2];
		break;
	case SBS_MOVETOPOS_OUTRANGE:
		strTmp = StatusDesc[3];
		break;
	case SBS_DECODE_NOT_MATCH:
		strTmp = StatusDesc[4];
		break;
	case SBS_EXPAND_MINDATE:
		strTmp = StatusDesc[5];
		break;
	case SBS_EXPAND_MINDATE_NODATA:
		strTmp = StatusDesc[6];
		break;
	case SBS_EXPAND_DAYDATE:
		strTmp = StatusDesc[7];
		break;
	case SBS_EXPAND_DAYDATE_NODATA:
		strTmp = StatusDesc[8];
		break;
	default:
		strTmp = StatusDesc[0];
	}

	return strTmp;
}
//////////////////
void InitialBitStream(SIMPLEBITSTREAM* pStream, unsigned char* pData,int nSize)
{
	pStream->m_pData		= pData;
	pStream->m_nBitSize	= nSize*8;
	pStream->m_nCurPos		= 0;

	pStream->m_pCodes		= NULL;
	pStream->m_nNumCode	= 0;
	pStream->m_nStatus	= SBS_EX_SUCCESS;
}

unsigned int Get(SIMPLEBITSTREAM* pStream, int nBit)
{
	unsigned int dw = 0;	
	int nMove = GetNoMove(pStream, nBit,&dw);
	pStream->m_nCurPos += nMove;

	return dw;
}

int GetNoMove(SIMPLEBITSTREAM* pStream, int nBit,unsigned int* dw)
{
	int nRet = -1;	
	*dw = 0;

	if (pStream->m_nBitSize <= pStream->m_nCurPos )
	{
		// Get Pos Out of Range
		SetStatus(pStream, SBS_GETPOS_OUTRANGE);
		return nRet;
	}

	if (nBit < 0 || nBit > 32) 
	{
		// Bit Len Error
		SetStatus(pStream, SBS_GETBITLEN_ERR);
	}
	else if ( nBit > 0)
	{
		int nGet;
		int nLeft;
		int nPos;
		if(nBit>pStream->m_nBitSize-pStream->m_nCurPos)
			nBit = pStream->m_nBitSize-pStream->m_nCurPos;
		nPos = pStream->m_nCurPos/8;
		if (pStream->m_nCurPos%8)
		{
			*dw = pStream->m_pData[nPos++];
			nGet = 8 - (pStream->m_nCurPos%8);
			*dw >>= 8-nGet;
			nLeft = nBit-nGet;
		}
		else
		{
			nGet = 0;
			nLeft = nBit;
		}
		if (nLeft>0)
		{
			unsigned int nValue;
			do
			{
				nValue = pStream->m_pData[nPos++];
				*dw |= nValue << nGet;
				nGet += 8;
				nLeft -= 8;
			}while(nLeft>0);
		}
		*dw &= 0xFFFFFFFF >> (32-nBit);
		nRet = nBit;
	}
	return nRet;
}

int GetCurPos(SIMPLEBITSTREAM* pStream)
{ 
	int nRet = -1;
	nRet = pStream->m_nCurPos;
	return nRet;
}

int MoveTo(SIMPLEBITSTREAM* pStream, int nPos)
{
	pStream->m_nCurPos = nPos;
	if(pStream->m_nCurPos < 0 || pStream->m_nCurPos > pStream->m_nBitSize)
	{
		// Move To Pos Out of Range
		SetStatus(pStream, SBS_MOVETOPOS_OUTRANGE);
	}
	return pStream->m_nCurPos;
}

int Move(SIMPLEBITSTREAM* pStream, int nBit)
{
	return MoveTo(pStream, pStream->m_nCurPos+nBit);
}	

void SaveCurrentPos(SIMPLEBITSTREAM* pStream)
{
	pStream->m_nSavedPos = pStream->m_nCurPos;
}

int  RestoreToSavedPos(SIMPLEBITSTREAM* pStream)
{
	return MoveTo(pStream, pStream->m_nSavedPos);
}

void SetBitCode(SIMPLEBITSTREAM* pStream, const SIMPLEBITCODE* pCodes,int nNumCode)
{
	pStream->m_pCodes = pCodes;
	pStream->m_nNumCode = nNumCode;
}

const SIMPLEBITCODE* DecodeFindMatch(SIMPLEBITSTREAM* pStream, unsigned int* dw)
{
	const SIMPLEBITCODE* pCode = NULL;
	*dw = 0;

	if(pStream && pStream->m_pCodes)
	{
		int i;
		unsigned int dwNextCode = 0;
		GetNoMove(pStream, 16, &dwNextCode);
		// Check the GetNoMove() status
		if (SBS_EX_SUCCESS != GetStatus(pStream))
			return NULL;

		for(i=0; i < pStream->m_nNumCode; i++)
		{
			const SIMPLEBITCODE* pCur = pStream->m_pCodes + i;
			if(pCur->m_wCodeBits == (dwNextCode & (0xFFFFFFFF>>(32-pCur->m_nCodeLen))))	//那a??角﹢
			{
				pCode = pCur;
				break;
			}
		}

		if(pCode)
		{
			Move(pStream, pCode->m_nCodeLen);
			// Check the Move() status
			if (SBS_EX_SUCCESS != GetStatus(pStream))
				return NULL;

			if(pCode->m_nDataLen)
			{
				*dw = Get(pStream, pCode->m_nDataLen);
				if (SBS_EX_SUCCESS != GetStatus(pStream))
					return NULL;
			}

			switch(pCode->m_cCode)
			{
			case 'B':
			case 'D':
			case 'M':
			case 's':
				break;
			case 'b':
				if((pCode->m_nDataLen-1) >= 0 && (*dw & (1 << (pCode->m_nDataLen-1))))	//?ㄓ邦那?﹢
					*dw |= (0xFFFFFFFF << pCode->m_nDataLen);
				break;
			case 'm':
				*dw |= (0xFFFFFFFF << pCode->m_nDataLen);
				break;
			case 'S':
				*dw <<= (unsigned short)(((pCode->m_dwCodeData) >> 16) & 0xFFFF);
				break;
			case 'E':
				*dw = pCode->m_dwCodeData;
				break;
			case 'Z':
				{
					int nExp = *dw&3;
					*dw >>= 2;
					*dw += pCode->m_dwDataBias;
					for(i=0;i<=nExp;i++)
						*dw *= 10;
				}
				break;
			case 'P':
				*dw = (1 << *dw);
				break;
			default:
				break;
			}
			if(((*dw & 0x80000000) && (pCode->m_cCode=='b')) || pCode->m_cCode=='m')
				*dw -= pCode->m_dwDataBias;
			//else if(!pCode->IsOriginalData() && pCode->m_cCode!='Z' && pCode->m_cCode!='s')
			else if (!IsOriginalData(pCode) && pCode->m_cCode!='Z' && pCode->m_cCode!='s')
				*dw += pCode->m_dwDataBias;
		}
		else
		{
			// Decode Cannot Find Match
			SetStatus(pStream, SBS_DECODE_NOT_MATCH);
			return NULL;
		}
	}
	return pCode;
}


unsigned int DecodeData(SIMPLEBITSTREAM* pStream, unsigned int dwLastData, int bReverse)
{
	unsigned int dw = 0;

	const SIMPLEBITCODE* pCode = DecodeFindMatch(pStream, &dw);
	if(pCode)
	{
		//if(!pCode->IsOriginalData() && dwLastData)
		if (!IsOriginalData(pCode) && dwLastData)
		{
			if(bReverse)
				dw = dwLastData - dw;
			else
				dw += dwLastData;
		}
	}
	return dw;
}

static SIMPLEBITCODE ZSpriceCode[] = 
{
	{0		,	1,	0,'E',		0, 0},			//0		
	{1		,	2,	2,'b',		2, 0},			//01
	{3		,	3,	4,'b',		4, 1},			//011
	{7	    ,	4,	8,'b',		8, 9},			//0111
	{0xF	,	5, 16,'b',	   16,137},			//01111 
	{0x1F	,	5, 32,'D',		0, 0},			//11111 
};

static SIMPLEBITCODE ZSvolumeCode[] = 
{
	{1		,	2,  4,'B',	    4, 0},			//01
	{0		,	1,  8,'B',	    8, 16},			//0	
	{3		,	3, 12,'B',	   12,272},			//011
	{7   	,	4, 16,'B',	   16,4368},		//0111
	{0xF	,	5, 24,'B',	   24,69904},		//01111
	{0x1F	,	5, 32,'D',	    0, 0},			//11111
};

static const MMINUTE constMINData;
static const FUTUREMMINUTE constFutureMINData;

static unsigned int GetZsTime (unsigned short pos, const MARKETTIME* pMarketTime, unsigned short* pTimePos)
{
	unsigned short i;
	unsigned int nRetTime = 0;
	for (i = 0; i < pMarketTime->m_nNum; i++)
	{
		if (pos < pTimePos[i])
		{
			if (i)
			{
				pos -= pTimePos[i-1];
				pos++;
			}
			nRetTime = (pMarketTime->m_TradeTime[i].m_wOpen%100+pos%60)/60;
			nRetTime = (pMarketTime->m_TradeTime[i].m_wOpen/100+nRetTime+pos/60)%24*100+(pMarketTime->m_TradeTime[i].m_wOpen%100+pos%60)%60;

			break;
		}
	}
	return nRetTime;
}


unsigned short ExpandMinData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize, unsigned short *minTotalNum)
{
	unsigned short nRet = 0;	
	unsigned short nSum = 0;

	if (pCmdHead->type==2201 && (pCmdHead->attrs&0x0002) && pCmdHead->length > sizeof(JAVA_ZSHEADDATA)+sizeof(MINCPSHEAD)+sizeof(MARKETTIME))
	{
		JAVA_ZSHEADDATA* pZsHead = (JAVA_ZSHEADDATA*)(pCmdHead+1);
		MINCPSHEAD* pCpsHead = (MINCPSHEAD*)(pZsHead+1);
		MARKETTIME* pMarketTime = (MARKETTIME*)(pCpsHead+1);
		char*	pData = (char*)pZsHead+sizeof(JAVA_ZSHEADDATA)+sizeof(MINCPSHEAD)+pCpsHead->m_nExchangeNum;
		int		nDataLen = pCmdHead->length-sizeof(JAVA_ZSHEADDATA)-sizeof(MINCPSHEAD)-pCpsHead->m_nExchangeNum;

		if (*nBufSize >= sizeof(JAVA_HEAD)+sizeof(JAVA_ZSHEADDATA)+sizeof(MMINUTE)*(pCpsHead->m_nCompressNum+pCpsHead->m_nUnCompressNum))
		{
			unsigned short i;
			unsigned int dwTmpVal;
			SIMPLEBITSTREAM stream;		
			unsigned short  pTimePos[8];//㏑÷∫那辰足那車?豕車ㄓ那?米㏑﹊?㏑o???????㏑﹊?			for (i = 0; i < pMarketTime->m_nNum && i < 8; i++)//
			int nStatus = 0;
			const MMINUTE* pOldData = &constMINData;			
			JAVA_ZSHEADDATA* pResZsHead = (JAVA_ZSHEADDATA*)(pResultHead+1);
			MMINUTE*	pMinBuf = (MMINUTE*)(pResZsHead+1);

			InitialBitStream(&stream, (unsigned char*)pData, nDataLen);

			pResultHead->cSparate = pCmdHead->cSparate;
			pResultHead->type = pCmdHead->type;
			pResultHead->attrs = 0;
			pResultHead->length = sizeof(JAVA_ZSHEADDATA)+sizeof(MMINUTE)*(pCpsHead->m_nCompressNum+pCpsHead->m_nUnCompressNum);
			*pResZsHead = *pZsHead;

			for (i = 0; i < pMarketTime->m_nNum && i < 8; i++)//
			{
				if (pMarketTime->m_TradeTime[i].m_wEnd < pMarketTime->m_TradeTime[i].m_wOpen)//那≡?那?豕???那?迆那辰??﹉??∫?㏑÷邦豕?㏒㏑羽角???4?﹢豕那車?
				{
					pTimePos[i] = (pMarketTime->m_TradeTime[i].m_wEnd/100+24-pMarketTime->m_TradeTime[i].m_wOpen/100)*60+pMarketTime->m_TradeTime[i].m_wEnd%100-pMarketTime->m_TradeTime[i].m_wOpen%100;
				}
				else
				{
					pTimePos[i] = (pMarketTime->m_TradeTime[i].m_wEnd/100-pMarketTime->m_TradeTime[i].m_wOpen/100)*60+pMarketTime->m_TradeTime[i].m_wEnd%100-pMarketTime->m_TradeTime[i].m_wOpen%100;
				}
				nSum += pTimePos[i] / pCpsHead->m_nMinInterval;
				if (i)
				{
					pTimePos[i] += pTimePos[i-1];
				}
				else
				{
					pTimePos[i]++;
				}
			}	
			
			*minTotalNum = nSum+1;
			/////////////
			for(i=0; i<pCpsHead->m_nCompressNum; i++, pMinBuf++)
			{
				pMinBuf->m_time = GetZsTime (i*pCpsHead->m_nMinInterval, pMarketTime, pTimePos);

				SETSIMPLEBITCODE(&stream, ZSpriceCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwPrice, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pMinBuf->m_dwPrice = dwTmpVal;

				SETSIMPLEBITCODE(&stream, ZSvolumeCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwVolume, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pMinBuf->m_dwVolume = dwTmpVal;

				SETSIMPLEBITCODE(&stream, ZSpriceCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwAmount, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
					//printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pMinBuf->m_dwAmount = dwTmpVal;

				pOldData = pMinBuf;
				nRet++;
			}

			if (pCpsHead->m_nUnCompressNum && (GetCurPos(&stream)+7)/8+sizeof(unsigned int)*pCpsHead->m_nUnCompressNum*3 <= nDataLen)
			{
				unsigned int	nValue;
				unsigned char*	pByte = (unsigned char*)&nValue;
				unsigned char* pUnData = (unsigned char*)(pData+nDataLen-sizeof(unsigned int)*pCpsHead->m_nUnCompressNum*3);
				for (i = 0; i < pCpsHead->m_nUnCompressNum; i++, pMinBuf++)
				{
					pMinBuf->m_time = GetZsTime ((pCpsHead->m_nCompressNum+i)*pCpsHead->m_nMinInterval, pMarketTime, pTimePos);
					*(pByte) = *pUnData++;
					*(pByte+1) = *pUnData++;
					*(pByte+2) = *pUnData++;
					*(pByte+3) = *pUnData++;
					pMinBuf->m_dwPrice = nValue;
					*(pByte) = *pUnData++;
					*(pByte+1) = *pUnData++;
					*(pByte+2) = *pUnData++;
					*(pByte+3) = *pUnData++;
					pMinBuf->m_dwVolume = nValue;
					*(pByte) = *pUnData++;
					*(pByte+1) = *pUnData++;
					*(pByte+2) = *pUnData++;
					*(pByte+3) = *pUnData++;
					pMinBuf->m_dwAmount = nValue;

					nRet++;
				}
			}

		}
		else
		{
			*nBufSize = sizeof(JAVA_HEAD)+sizeof(JAVA_ZSHEADDATA)+sizeof(MMINUTE)*(pCpsHead->m_nCompressNum+pCpsHead->m_nUnCompressNum);
		}
	}

	return nRet;
}


unsigned short NewExpandMinData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize, unsigned short *minTotalNum)
{
	unsigned short nRet = 0;	
	unsigned short nSum = 0;

	if (pCmdHead->type==2942 && (pCmdHead->attrs&0x0002) && pCmdHead->length > sizeof(JAVA_NEWZSHEADDATA)+sizeof(MINCPSHEAD)+sizeof(MARKETTIME))
	{
		JAVA_NEWZSHEADDATA* pZsHead = (JAVA_NEWZSHEADDATA*)(pCmdHead+1);
		MINCPSHEAD* pCpsHead = (MINCPSHEAD*)(pZsHead+1);
		MARKETTIME* pMarketTime = (MARKETTIME*)(pCpsHead+1);
		char*	pData = (char*)pZsHead+sizeof(JAVA_NEWZSHEADDATA)+sizeof(MINCPSHEAD)+pCpsHead->m_nExchangeNum;
		int		nDataLen = pCmdHead->length-sizeof(JAVA_NEWZSHEADDATA)-sizeof(MINCPSHEAD)-pCpsHead->m_nExchangeNum;

		int	nCellLen = pZsHead->m_nTag?sizeof(FUTUREMMINUTE):sizeof(MMINUTE);
		if (*nBufSize >= sizeof(JAVA_HEAD)+sizeof(JAVA_NEWZSHEADDATA)+nCellLen*(pCpsHead->m_nCompressNum+pCpsHead->m_nUnCompressNum))
		{
			unsigned int dwTmpVal;
			unsigned short i;
			SIMPLEBITSTREAM stream;
			unsigned short  pTimePos[8];//㏑÷∫那辰足那車?豕車ㄓ那?米㏑﹊?㏑o???????㏑﹊?			for (i = 0; i < pMarketTime->m_nNum && i < 8; i++)//
			int nStatus = 0;

			JAVA_NEWZSHEADDATA* pResZsHead = (JAVA_NEWZSHEADDATA*)(pResultHead+1);
			/////////////
			const FUTUREMMINUTE* pOldData = &constFutureMINData;
			FUTUREMMINUTE* pMinBuf = (FUTUREMMINUTE*)(pResZsHead+1);

			InitialBitStream(&stream, (unsigned char*)pData, nDataLen);

			pResultHead->type = pCmdHead->type;
			pResultHead->attrs = 0;
			pResultHead->length = sizeof(JAVA_NEWZSHEADDATA)+nCellLen*(pCpsHead->m_nCompressNum+pCpsHead->m_nUnCompressNum);
			*pResZsHead = *pZsHead;

			for (i = 0; i < pMarketTime->m_nNum && i < 8; i++)//
			{
				if (pMarketTime->m_TradeTime[i].m_wEnd < pMarketTime->m_TradeTime[i].m_wOpen)//那≡?那?豕???那?迆那辰??﹉??∫?㏑÷邦豕?㏒㏑羽角???4?﹢豕那車?
				{
					pTimePos[i] = (pMarketTime->m_TradeTime[i].m_wEnd/100+24-pMarketTime->m_TradeTime[i].m_wOpen/100)*60+pMarketTime->m_TradeTime[i].m_wEnd%100-pMarketTime->m_TradeTime[i].m_wOpen%100;
				}
				else
				{
					pTimePos[i] = (pMarketTime->m_TradeTime[i].m_wEnd/100-pMarketTime->m_TradeTime[i].m_wOpen/100)*60+pMarketTime->m_TradeTime[i].m_wEnd%100-pMarketTime->m_TradeTime[i].m_wOpen%100;
				}
				nSum += pTimePos[i] / pCpsHead->m_nMinInterval;
				if (i)
				{
					pTimePos[i] += pTimePos[i-1];
				}
				else
				{
					pTimePos[i]++;
				}
			}
			*minTotalNum = nSum+1;
			
			for(i=0; i<pCpsHead->m_nCompressNum; i++)
			{
				pMinBuf->m_time = GetZsTime (i*pCpsHead->m_nMinInterval, pMarketTime, pTimePos);

				SETSIMPLEBITCODE(&stream, ZSpriceCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwPrice, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pMinBuf->m_dwPrice = dwTmpVal;

				SETSIMPLEBITCODE(&stream, ZSvolumeCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwVolume, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pMinBuf->m_dwVolume = dwTmpVal;

				SETSIMPLEBITCODE(&stream, ZSpriceCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwAmount, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pMinBuf->m_dwAmount = dwTmpVal;

				if(pZsHead->m_nTag)
				{
					dwTmpVal = DecodeData(&stream, pOldData->m_dwOpenInterest, 0);
					if ((nStatus = GetStatus(&stream)))
					{
					//	printLog_IF("%s", GetStatusDesc(nStatus));
						return 0;
					}
					pMinBuf->m_dwOpenInterest = dwTmpVal;
					pOldData = pMinBuf++;
				}
				else
				{
					pOldData = pMinBuf;
					pMinBuf = (FUTUREMMINUTE*)((char*)pMinBuf+sizeof(MMINUTE));
				}

				nRet++;
			}

			if (pCpsHead->m_nUnCompressNum && (GetCurPos(&stream)+7)/8 + (nCellLen-sizeof(unsigned int))*pCpsHead->m_nUnCompressNum <= nDataLen)
			{
				CPSMIN* pUnData = (CPSMIN*)(pData+nDataLen-(nCellLen-sizeof(unsigned int))*pCpsHead->m_nUnCompressNum);
				for (i = 0; i < pCpsHead->m_nUnCompressNum; i++)
				{
					pMinBuf->m_time = GetZsTime ((pCpsHead->m_nCompressNum+i)*pCpsHead->m_nMinInterval, pMarketTime, pTimePos);
					pMinBuf->m_dwPrice = pUnData->m_dwPrice;
					pMinBuf->m_dwVolume = pUnData->m_dwVolume;
					pMinBuf->m_dwAmount = pUnData->m_dwAmount;
					if(pZsHead->m_nTag)
					{
						CPSFUTUREMIN* pFutureUnData = (CPSFUTUREMIN*)pUnData;
						pMinBuf->m_dwOpenInterest = pFutureUnData->m_dwOpenInterest;
						pMinBuf++;
						pUnData = (CPSMIN*)((char*)pFutureUnData+sizeof(CPSFUTUREMIN));
					}
					else
					{
						pMinBuf = (FUTUREMMINUTE*)((char*)pMinBuf+sizeof(MMINUTE));
						pUnData++;
					}

					nRet++;
				}
			}

			//nRet = nNum;
		}
		else
		{
			*nBufSize = sizeof(JAVA_HEAD)+sizeof(JAVA_NEWZSHEADDATA)+nCellLen*(pCpsHead->m_nCompressNum+pCpsHead->m_nUnCompressNum);
		}
	}

	return nRet;
}



static SIMPLEBITCODE KLineOpenpriceCode[] =
{
	{1		,	2,	8,'b',		8,	0},			//01
	{0		,	1, 16,'b',	   16,128},			//0	
	{0x3	,	3, 24,'b',	   24,32896},		//011
	{0x7	,	3, 32,'D',	   0,	0},			//111
};

static SIMPLEBITCODE KLinepriceCode[] =
{
	{1		,	2,	8,'B',		8,	0},			//01
	{0		,	1, 16,'B',	   16,256},			//0	
	{0x3	,	3, 24,'B',	   24,65792},		//011	
	{0x7	,	3, 32,'D',	   0,	0},			//111
};

static SIMPLEBITCODE KLinevolCode[] =
{
	{0x1	,	2, 12,'b',	   12,	0},			// 01
	{0x0	,	1, 16,'b',	   16,2048},		// 0
	{0x3	,	3, 24,'b',	   24,34816},		// 011
	{0x7	,	3, 32,'D',	    0,	0},			// 111
};


static SIMPLEBITCODE KLamountCode[] =	
{
	{0x3	,	3, 12,'b',	   12,	0},			// 011
	{0x1	,	2, 16,'b',	   16,2048},		// 01	
	{0x0	,	1, 24,'b',	   24,34816},		// 0
	{0x7	,	3, 32,'D',	   0,	0},			// 111
};

static const MKDATA constKLineData;
static const FutureMKDATA constFutureKLine;

static unsigned int ExpandMinKLDate(SIMPLEBITSTREAM* stream, const unsigned int lastdate, const unsigned int nCircle)//??
{
	unsigned int     data;
	MinKLTime nNow;
	unsigned int* pIntnNow = (unsigned int*)&nNow;

	*pIntnNow = 0;

	GetNoMove(stream, 16, &data);
	if (SBS_EX_SUCCESS == GetStatus(stream))
	{
		if ((data&0x00000001) == 0)//
		{
			unsigned int minvalue  = nNow.m_nMin+nCircle;
			*pIntnNow = lastdate;
			
			
			if (minvalue >= 60)
			{
				nNow.m_nMin = minvalue-60;
				nNow.m_nHour++;
			}
			else
			{
				nNow.m_nMin = minvalue;
			}
			Move(stream, 1);
			
		}
		else if ((data&0x00000003) == 3)
		{
			Move(stream, 2);
			data = Get(stream, 32);

			if (SBS_EX_SUCCESS == GetStatus(stream))
				*pIntnNow = data;
		}
		else
		{
			// Expand min date error
			SetStatus(stream, SBS_EXPAND_MINDATE);
		}
	}
	else
	{
		//expand min date error:no data
		SetStatus(stream, SBS_EXPAND_MINDATE_NODATA);
	}

	return *pIntnNow;
}

static unsigned int ExpandDayKLDate(SIMPLEBITSTREAM* stream, const unsigned int lastdate, const unsigned int nCircle)
{
	unsigned int data;
	unsigned int date = 0;

	if (!stream) return 0;		// stream is null pointer

	GetNoMove(stream, 16, &data);
	if (SBS_EX_SUCCESS == GetStatus(stream))
	{
		if ((data&0x00000001) == 0)//?﹉邦㏑﹊?㏑﹊?那車?那迆邦?豕??﹉?㏑﹊?㏑﹊????那迆?	
		{
			Move(stream, 1);
			date = lastdate+nCircle;

		}
		else if ((data&0x0000003) == 1)//
		{
			Move(stream, 7);
			data >>= 2;
			date = (lastdate/100+1)*100+(data&0x0000001F);
		}
		else if ((data&0x0000003) == 3)//
		{
			Move(stream, 2);
			data = Get(stream, 32);
			if (SBS_EX_SUCCESS == GetStatus(stream))
				date = data;
		}
	}
	else
	{
		// Expand day date error: no data
		SetStatus(stream, SBS_EXPAND_DAYDATE_NODATA);
	}

	return date;
}


unsigned short ExpandKLineData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize)
{
	unsigned short nRet = 0;	
	if (pCmdHead->type==2934 && pCmdHead->length > sizeof(KLINECPSHEAD)+sizeof(unsigned short) && (pCmdHead->attrs&0x0002))
	{
		unsigned short	nDataLen = pCmdHead->length-sizeof(unsigned short);
		unsigned char*	pData = (unsigned char*)((char*)pCmdHead+sizeof(JAVA_HEAD)+sizeof(unsigned short));
		KLINECPSHEAD* pHead = (KLINECPSHEAD*)pData;
		MKDATA* pKLineBuf = (MKDATA*)((char*)pResultHead+sizeof(JAVA_HEAD)+sizeof(unsigned short));

		if (sizeof(JAVA_HEAD)+sizeof(unsigned short)+pHead->m_nNum*sizeof(MKDATA) <= *nBufSize)
		{
			unsigned short  i;
			SIMPLEBITSTREAM stream;
			unsigned int nCircle = 0;
			unsigned int dwTmpVal = 0;
			int nStatus = 0;
			const MKDATA* pOldData = &constKLineData;
			InitialBitStream(&stream, (unsigned char*)(pData+sizeof(KLINECPSHEAD)), nDataLen-sizeof(KLINECPSHEAD));

			switch (pHead->m_nKLType)
			{
			case ktypeMin1:
				nCircle = 1;
				break;
			case ktypeMin5:
				nCircle = 5;
				break;
			case ktypeMin15:
				nCircle = 15;
				break;
			case ktypeMin30:
				nCircle = 30;
				break;
			case ktypeMin60:
				nCircle = 60;
				break;
			case ktypeDay:
				nCircle = 1;
				break;
			case ktypeWeek:
				nCircle = 7;
				break;
			case ktypeMonth:
				nCircle = 100;
				break;
			default:
				break;
			}


			for(i=0; i<pHead->m_nNum; i++, pKLineBuf++)
			{
				//??㏒?谷?那車?那迆邦
				if (pHead->m_nKLType <= ktypeMin60)
				{
					// pKLineBuf->m_dwDate = ExpandMinKLDate(stream, pOldData->m_dwDate, nCircle);
					dwTmpVal = ExpandMinKLDate(&stream, pOldData->m_dwDate, nCircle);
					if (!(nStatus = GetStatus(&stream))) 
					{
						pKLineBuf->m_dwDate = dwTmpVal;
					}
					else
					{
					//	printLog_IF("%s", GetStatusDesc(nStatus));
						return 0;
					}
				}
				else
				{					
					dwTmpVal = ExpandDayKLDate(&stream, pOldData->m_dwDate, nCircle);
					if (!(nStatus = GetStatus(&stream)))
					{
						pKLineBuf->m_dwDate = dwTmpVal;
					}
					else
					{
					//	printLog_IF("%s", GetStatusDesc(nStatus));
						return 0;
					}
				}
				//??㏒?谷?K那?﹢那??芍??㏑a﹉那??			
				SETSIMPLEBITCODE(&stream, KLineOpenpriceCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwClose, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwOpen = dwTmpVal;

				SETSIMPLEBITCODE(&stream, KLinepriceCode);
				dwTmpVal = DecodeData(&stream, pKLineBuf->m_dwOpen, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwHigh = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pKLineBuf->m_dwOpen, 1);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwLow = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pKLineBuf->m_dwLow, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwClose = dwTmpVal;

				//??㏒?谷?K那?﹢那??芍??那角那㏑÷∫豕芍豕
				SETSIMPLEBITCODE(&stream, KLinevolCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwVolume, 0);
				if ((nStatus = GetStatus(&stream)))
				{
					//printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwVolume = dwTmpVal;

				//??㏒?谷?K那?﹢那??芍??那角那㏑÷∫豕⊿迄
				SETSIMPLEBITCODE(&stream, KLamountCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwAmount, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwAmount = dwTmpVal;

				pOldData = pKLineBuf;
				nRet++;
			}

			pResultHead->type = pCmdHead->type;
			pResultHead->attrs = 0;
			pResultHead->length = sizeof(unsigned short)+sizeof(MKDATA)*nRet;
			*((unsigned char*)pResultHead+sizeof(JAVA_HEAD)) = *(unsigned char*)&nRet;
			*((unsigned char*)pResultHead+sizeof(JAVA_HEAD)+1) = *((unsigned char*)&nRet+1);
		}
		else
		{
			nRet = 0xffff;
			*nBufSize = sizeof(JAVA_HEAD)+sizeof(unsigned short)+pHead->m_nNum*sizeof(MKDATA);
		}
	}

	return nRet;
}


unsigned short NewExpandKLineData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize)
{
	unsigned short nRet = 0;	
	if (pCmdHead->type==2944 && pCmdHead->length > sizeof(char)+sizeof(unsigned short)+sizeof(KLINECPSHEAD) && (pCmdHead->attrs&0x0002))
	{
		unsigned short	nDataLen = pCmdHead->length-sizeof(char)-sizeof(unsigned short);
		unsigned char*	pData = (unsigned char*)((char*)pCmdHead+sizeof(JAVA_HEAD)+sizeof(char)+sizeof(unsigned short));
		char	tag = *(char*)(pCmdHead+1);
		KLINECPSHEAD* pHead = (KLINECPSHEAD*)pData;
		FutureMKDATA* pKLineBuf = (FutureMKDATA*)((char*)pResultHead+sizeof(JAVA_HEAD)+sizeof(char)+sizeof(unsigned short));

		int	nCellLen = tag?sizeof(FutureMKDATA):sizeof(MKDATA);
		if (sizeof(JAVA_HEAD)+sizeof(char)+sizeof(unsigned short)+pHead->m_nNum*nCellLen <= *nBufSize)
		{
			unsigned int nCircle = 0;
			unsigned short  i;
			SIMPLEBITSTREAM stream;
			unsigned int dwTmpVal = 0;
			int nStatus = 0;
			const FutureMKDATA* pOldData = &constFutureKLine;
			InitialBitStream(&stream, (unsigned char*)(pData+sizeof(KLINECPSHEAD)), nDataLen-sizeof(KLINECPSHEAD));
			switch (pHead->m_nKLType)
			{
			case ktypeMin1:
				nCircle = 1;
				break;
			case ktypeMin5:
				nCircle = 5;
				break;
			case ktypeMin15:
				nCircle = 15;
				break;
			case ktypeMin30:
				nCircle = 30;
				break;
			case ktypeMin60:
				nCircle = 60;
				break;
			case ktypeDay:
				nCircle = 1;
				break;
			case ktypeWeek:
				nCircle = 7;
				break;
			case ktypeMonth:
				nCircle = 100;
				break;
			default:
				break;
			}

			
			for(i=0; i<pHead->m_nNum; i++)
			{
				//??㏒?谷?那車?那迆邦
				if (pHead->m_nKLType <= ktypeMin60)
				{
					dwTmpVal = ExpandMinKLDate(&stream, pOldData->m_dwDate, nCircle);
					if ((nStatus = GetStatus(&stream)))
					{
					//	printLog_IF("%s", GetStatusDesc(nStatus));
						return 0;
					}
					pKLineBuf->m_dwDate = dwTmpVal;
				}
				else
				{					
					dwTmpVal = ExpandDayKLDate(&stream, pOldData->m_dwDate, nCircle);
					if ((nStatus = GetStatus(&stream)))
					{
						//printLog_IF("%s", GetStatusDesc(nStatus));
						return 0;
					}
					pKLineBuf->m_dwDate = dwTmpVal;
				}
				//??㏒?谷?K那?﹢那??芍??㏑a﹉那??			
				SETSIMPLEBITCODE(&stream, KLineOpenpriceCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwClose, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwOpen = dwTmpVal;

				SETSIMPLEBITCODE(&stream, KLinepriceCode);

				dwTmpVal = DecodeData(&stream, pKLineBuf->m_dwOpen, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s",  GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwHigh = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pKLineBuf->m_dwOpen, 1);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwLow = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pKLineBuf->m_dwLow, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwClose = dwTmpVal;

				//??㏒?谷?K那?﹢那??芍??那角那㏑÷∫豕芍豕
				//stream.SETSIMPLEBITCODE(KLinevolCode);
				SETSIMPLEBITCODE(&stream, KLinevolCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwVolume, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwVolume = dwTmpVal;

				//??㏒?谷?K那?﹢那??芍??那角那㏑÷∫豕⊿迄
				SETSIMPLEBITCODE(&stream, KLamountCode);
				dwTmpVal = DecodeData(&stream, pOldData->m_dwAmount, 0);
				if ((nStatus = GetStatus(&stream)))
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pKLineBuf->m_dwAmount = dwTmpVal;

				if(tag)
				{
					dwTmpVal = DecodeData(&stream, pOldData->m_dwOpenInterest, 0);
					if ((nStatus = GetStatus(&stream)))
					{
					//	printLog_IF("%s", GetStatusDesc(nStatus));
						return nRet;
					}
					pKLineBuf->m_dwOpenInterest = dwTmpVal;
					pOldData = pKLineBuf++;
				}
				else
				{
					pOldData = pKLineBuf;
					pKLineBuf = (FutureMKDATA*)((char*)pKLineBuf+sizeof(MKDATA));
				}

				nRet++;
			}
			
			pResultHead->type = pCmdHead->type;
			pResultHead->attrs = 0;
			pResultHead->length = sizeof(char)+sizeof(unsigned short)+nCellLen*nRet;
			*((char*)pResultHead+sizeof(JAVA_HEAD)) = tag;
			*((unsigned char*)pResultHead+sizeof(JAVA_HEAD)+1) = *(unsigned char*)&nRet;
			*((unsigned char*)pResultHead+sizeof(JAVA_HEAD)+2) = *((unsigned char*)&nRet+1);
		}
		else
		{
			*nBufSize = sizeof(JAVA_HEAD)+sizeof(char)+sizeof(unsigned short)+pHead->m_nNum*nCellLen;
		}
	}

	return nRet;
}


static SIMPLEBITCODE BSpriceCode[] = 
{
	{0		,	1,	4,'b',		4, 0},			//0				= ?邦÷?芍邦
	{1		,	2,	8,'b',		8, 8},			//01			= ?邦÷?芍邦+8Bit+8
	{3		,	3,	12,'b',		12, 136},		//011	+4Bit	= ?邦÷?芍邦+12Bit+128+8
	{7		,	4,	16,'b',		16, 2184},		//0111	+4Bit	= ?邦÷?芍邦+16Bit+2048+128+8
	{0xF	,	4,  32,'D',		0, 0},			//1111 +32Bit	= unsigned int
};

static const BSDATA constBSData;
unsigned short ExpandBSData(const JAVA_HEAD* pCmdHead, JAVA_HEAD* pResultHead, unsigned short* nBufSize)
{
	unsigned short nRet = 0;	

	if ((pCmdHead->attrs&0x0002) && pCmdHead->length>sizeof(unsigned short))
	{
		unsigned short num;
		BSDATA*	pData;
		unsigned char* pNum = (unsigned char*)&num;
		*pNum = *((unsigned char*)pCmdHead+sizeof(JAVA_HEAD));
		*(pNum+1) = *((unsigned char*)pCmdHead+sizeof(JAVA_HEAD)+sizeof(unsigned char));
		pData = (BSDATA*)((char*)pResultHead+sizeof(JAVA_HEAD)+sizeof(unsigned short));

		if (num && num <= *nBufSize)
		{
			SIMPLEBITSTREAM stream;

			unsigned int dwTmpVal;
			unsigned short i;
			int nStatus = 0;

			const BSDATA* pOldData = &constBSData;
			
			InitialBitStream(&stream, (unsigned char*)(pCmdHead+1)+sizeof(unsigned short), pCmdHead->length-sizeof(unsigned short));
			
			SETSIMPLEBITCODE(&stream, BSpriceCode);

			for (i = 0; i < num; i++, pData++)
			{
				dwTmpVal = Get(&stream, 3);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pData->m_cTag = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pOldData->udd, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pData->udd = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pOldData->upp, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pData->upp = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pOldData->ls, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
					//printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pData->ls = dwTmpVal;

				dwTmpVal = DecodeData(&stream, pOldData->hs, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
					//printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pData->hs = dwTmpVal;

				dwTmpVal = DecodeData(&stream, 0, 0);
				if ((nStatus = GetStatus(&stream)) > 0)
				{
				//	printLog_IF("%s", GetStatusDesc(nStatus));
					return 0;
				}
				pData->d3 = dwTmpVal;

				pOldData = pData;
				nRet++;
			}
			pResultHead->cSparate = pCmdHead->cSparate;
			pResultHead->attrs = 0;
			pResultHead->type = pCmdHead->type;
			pResultHead->length = sizeof(unsigned short)+sizeof(BSDATA)*num;
			*((unsigned char*)pResultHead+sizeof(JAVA_HEAD)) = *pNum;
			*((unsigned char*)pResultHead+sizeof(JAVA_HEAD)+sizeof(unsigned char)) = *(pNum+sizeof(unsigned char));
		}
		else
		{
			*nBufSize = num;
		}
	}

	return nRet;
}

