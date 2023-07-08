/** 
* compile command : 
* arm-linux-gnueabihf-gcc --static -march=armv7-a -mfloat-abi=hard -mfpu=vfpv3 emulateme_vfp.arm32.c -o emulateme_vfp.arm32
*/

#include <stdio.h>

int main(int argc, char **argv) {
        float a, b;
        a = 5.4;
        b = 0.000008;
        double c = a - b + a * b;
        printf("a = %f b = %f c = %e\n", a, b, c);
        return 0;
}

