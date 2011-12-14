#if defined(ARDUINO) && ARDUINO > 18
#include <SPI.h>
#endif
#include <EthernetDHCP.h>
#include <Ethernet.h>
#include <EthernetDNS.h>

#include "connect.h"
#include "config.h"
#include "options.h"

uint8_t mac[] = MAC;
const char * const hostname = "google.com";

static const char* ip_to_str(const uint8_t* const);

void connect_setup()
{
  LOG("Attempting to obtain a DHCP lease...");
  EthernetDHCP.begin(mac);

  uint8_t* myIp = (uint8_t*)EthernetDHCP.ipAddress();
  const byte* gatewayIp = EthernetDHCP.gatewayIpAddress();
  const byte* dnsIp = EthernetDHCP.dnsIpAddress();

  LOG("A DHCP lease has been obtained.");

  LOG("My IP address is ");
  LOG(ip_to_str(myIp));

  LOG("Gateway IP address is ");
  LOG(ip_to_str(gatewayIp));

  LOG("DNS IP address is ");
  LOG(ip_to_str(dnsIp));
  
  Ethernet.begin(mac, myIp);
  const byte a[] = { 0x08,0x08,0x08,0x08};
  EthernetDNS.setDNSServer(a);
}

void connect_loop()
{
    EthernetDHCP.maintain();
    LOG("Resolving");
    LOG(hostname);

    byte teamcityIp[] = {0,0,0,0};
    DNSError err = EthernetDNS.resolveHostName(hostname, teamcityIp);
    if (DNSSuccess == err) {
      LOG("The IP address is "); 
      LOG(ip_to_str(teamcityIp));
    } else if (DNSTimedOut == err) {
      LOG("Timed out.");
      LOG(ip_to_str(teamcityIp));
    } else if (DNSNotFound == err) {
      LOG("Does not exist.");
      LOG(ip_to_str(teamcityIp));
    } else {
      LOG("Failed with error code "); 
      LOG((int)err);
    }
}

static const char* ip_to_str(const uint8_t* const ipAddr)
{
    static char buf[16];
      sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
        return buf;
}

