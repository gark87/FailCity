#if !(defined __NETWORK_H__)
#define __NETWORK_H__ 1

#include <Client.h>

class Network {
  private:
    const uint8_t * macAddr;
    byte hostIp[4];
  public:
    void setMacAddr(uint8_t * const macAddr);
    byte *getIpAddr(const char * const hostname);
};

extern Network Network;
#endif
