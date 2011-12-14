#if !(defined __TEAMCITY_FLAT_H__)
#define __TEAMCITY_FLAT_H__ 1

#include "flat.h"
#include "teamcity.h"

class TeamcityFlat : public Flat {
  public:
    TeamcityFlat(int pin);
    ~TeamcityFlat();

};
#endif
