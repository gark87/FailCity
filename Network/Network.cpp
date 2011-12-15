#if defined(ARDUINO) && ARDUINO > 18
#include <SPI.h>
#endif
#include <EthernetDHCP.h>
#include <Ethernet.h>
#include <EthernetDNS.h>

#include "HardwareSerial.h"
#include "Network.h"
#include "config.h"
#include "options.h"

static const char* ip_to_str(const uint8_t* const ipAddr);

class Network Network;

void Network::setMacAddr(uint8_t * const macAddr) {
  this->macAddr = macAddr;
  LOG("Attempting to obtain a DHCP lease...");
  EthernetDHCP.begin(macAddr);

  uint8_t* myIp = (uint8_t*)EthernetDHCP.ipAddress();
  uint8_t* gatewayIp = (uint8_t*)EthernetDHCP.gatewayIpAddress();
  const byte* dnsIp = EthernetDHCP.dnsIpAddress();

  LOG("A DHCP lease has been obtained.");

  LOG("My IP address is ");
  LOG(ip_to_str(myIp));

  LOG("is ");
  LOG(ip_to_str(gatewayIp));

  LOG("DNS IP address is ");
  LOG(ip_to_str((uint8_t *)dnsIp));
  
  Ethernet.begin(macAddr, myIp, gatewayIp);
  EthernetDNS.setDNSServer(dnsIp);
}

byte *Network::getIpAddr(const char * const hostname) {
    EthernetDHCP.maintain();
    LOG("Resolving");
    LOG(hostname);

    DNSError err = EthernetDNS.resolveHostName(hostname, hostIp);
    if (DNSSuccess == err) {
      LOG("The IP address is "); 
      LOG(ip_to_str(hostIp));
      return hostIp;
    } else if (DNSTimedOut == err) {
      LOG("Timed out.");
    } else if (DNSNotFound == err) {
      LOG("Does not exist.");
    } else {
      LOG("Failed with error code "); 
      LOG((int)err);
    }
    return 0;
}

static const char* ip_to_str(const uint8_t* const ip) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ip[0], ip[1], ip[2], ip[3]);
  return buf;
}
