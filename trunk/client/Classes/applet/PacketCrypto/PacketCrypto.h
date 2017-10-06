#ifndef _PACKET_CRYPTO_H_
#define _PACKET_CRYPTO_H_

#ifdef __cplusplus
extern "C"
{
#endif

extern char* PacketCryptoEncode(const char* data, unsigned int dataLen, unsigned int* destLen, unsigned long xorKey, unsigned long shiftKey, unsigned char encodeCount);
extern char* PacketCryptoDecode(char* data, unsigned int dataLen, unsigned int* destLen, unsigned long xorKey, unsigned long shiftKey, unsigned char* encodeCount);

#ifdef __cplusplus
}
#endif

#endif	// _PACKET_CRYPTO_H_

