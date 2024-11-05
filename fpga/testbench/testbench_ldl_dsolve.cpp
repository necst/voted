#include "../ldl_dsolve.hpp"
#include <cstdint>
#include <iostream>


//number of elements to apply ldl_dsolve
#define N 25826
#define REPETITIONS 3

typedef union my_union_u
{
    double value;
    /// A byte array large enough to hold the largest of any value in the union.
    uint64_t bytes;
} my_union_t;

void generate_random_array(size_t n, double min_value, double max_value, unsigned seed, double* array) {
    for (size_t i = 0; i < n; ++i) {
        double scale = rand() / (double) RAND_MAX; // Generate a random number between 0 and 1
        array[i] = min_value + scale * (max_value - min_value); // Scale to the desired range
        std::cout << array[i] << " ";
    }
    std::cout << std::endl;

}

int main() {

    unsigned int seed = 1234;
    srand(seed);

    // double X[] = {61.5, 60.0, 60.0, 60.0, 60.0, 60.0};
    // double D[] = {2.0, 4.0, 6.0, 8.0, 10.0, 12.0};
    // double temp = X[0];
    double X[N], Xunmod[N], D[N], temp;
    double min = -100.0;
    double max = 100.0;
    readType Xout[N/2];
    my_union_t Xfinal[N];
    my_union_t t2;
    my_union_t t1;
    my_union_t z2;
    my_union_t z1;
    readType Xr[N/2], Dr[N/2];

    for(int reps=0; reps < REPETITIONS; reps++){

        std::cout << "*********************" << std::endl;
        std::cout << "Starting rep " << reps << std::endl;
        std::cout << "*********************" << std::endl;
        generate_random_array(N, min, max, seed, X);
        memcpy(Xunmod,X,sizeof(double)* N);
        generate_random_array(N, min, max, seed, D);

        std::cout << "Showing the values " << std::endl;

        for(int i = 0; i < N; i+= 2) {
            t1.value = X[i+1];
            t2.value = X[i];
            z1.value = D[i+1];
            z2.value = D[i];
            std::cout << Xunmod[i] << " " << Xunmod[i+1] << std::endl;
            std::cout << X[i] << " " << X[i+1] << std::endl;
            std::cout << D[i] << " " << D[i+1] << std::endl;
            hreadtype t1b = t1.bytes;
            hreadtype t2b = t2.bytes;
            hreadtype z1b = z1.bytes;
            hreadtype z2b = z2.bytes;
            readType temp1 = t1b.concat(t2b);
            readType temp2 = z1b.concat(z2b);
            Xr[i/2] = temp1;
            Dr[i/2] = temp2;
        }
    

        memset(Xout, 0, sizeof(Xout)); 
        memset(Xfinal, 0, sizeof(Xfinal));
        ldl_dsolve(N, Xr, Dr, Xout);
        std::cout << "Hw ended" << std::endl;
        
        my_union_t a, b;

        for(int i = 0; i < N; i += 2) {
            a.bytes = Xout[i/2].range(63, 0);
            b.bytes = Xout[i/2].range(127, 64);
            Xfinal[i].bytes = a.bytes;
            Xfinal[i+1].bytes = b.bytes;
        }
        std::cout << "Hw read back" << std::endl;
        std::cout << "Going to cmp hw vs sw" << std::endl;

        
        int ok=1;
        for (int i = 0; i < N; i++) {
            double out = Xunmod[i] / D[i];
            std::cout << Xfinal[i].value << " vs " << out << std::endl;
            if(Xfinal[i].value != out)
		        ok=0;
        }

        printf("\nfinal results is ok = %d at rep=%d \n", ok, reps);

        // std::cout << std::endl;
        memset(Xr,0, sizeof(Xr));
        memset(Dr,0, sizeof(Dr));
        memset(X,0, sizeof(X));
        memset(D,0, sizeof(D));
        std::cout << std::endl;

    }
    

    return 0;
}

