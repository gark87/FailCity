#if !(defined __FLAT_H__ )
#define __FLAT_H__ 1

class Flat {
  private:
    int pin;
  public:
    Flat(int pin);
    ~Flat();
    void ok();
    void fail();
};
#endif
