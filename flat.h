#if !(defined __FLAT_H__ )
#define __FLAT_H__ 1

class Flat {
  private:
    int okPin;
    int failPin;
    void ok();
    void fail();
  public:
    Flat(int okPin, int failPin);
    ~Flat();
};
#endif
