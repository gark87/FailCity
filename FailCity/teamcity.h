#if !(defined __TEAMCITY_H__ )
#define __TEAMCITY_H__ 1

class RunConfigurationList {
  private:
    const char * const name;
    const char * const responsible;
    const RunConfigurationList * const next;
    const bool success;
  public:
    RunConfigurationList();
    ~RunConfigurationList();
};

class ProjectConfiguration {
  private:
    const char * const name;
    const RunConfigurationList* run;
  public:
    ProjectConfiguration();
    ~ProjectConfiguration();

};

#endif
