#include "ldl_dsolve.hpp"
#include <sys/types.h>


typedef union my_union_u
{
    double value;
    /// A byte array large enough to hold the largest of any value in the union.
    uint64_t bytes;
} my_union_t;


void read1(LDL_int n, readType* X, hls::stream<readType>& outXstream){
	read:	for(int i=0; i<n/2; i+=1){
#pragma HLS PIPELINE II=1
#pragma HLS LOOP_TRIPCOUNT min=1 max=550
		outXstream.write(X[i]);
	}
}

void read2(LDL_int n, readType* D, hls::stream<readType>& outDstream){
	read:	for(int i=0; i<n/2; i+=1){
#pragma HLS PIPELINE II=1
#pragma HLS LOOP_TRIPCOUNT min=1 max=550
		outDstream.write(D[i]);
	}
}

void compute(LDL_int n, hls::stream<readType>&inXstream, hls::stream<readType>&inDstream, hls::stream<readType>&outXstream){
	my_union_t w1_a, w1_b, w2_a, w2_b;
    my_union_t tout_a, tout_b;
    double* pdw1_a = reinterpret_cast<double*>(&w1_a);
    double* pdw1_b = reinterpret_cast<double*>(&w1_b);
    double* pdw2_a = reinterpret_cast<double*>(&w2_a);
    double* pdw2_b = reinterpret_cast<double*>(&w2_b);

    uint64_t* puw1_a = reinterpret_cast<uint64_t*>(&w1_a);
    uint64_t* puw1_b = reinterpret_cast<uint64_t*>(&w1_b);
    uint64_t* puw2_a = reinterpret_cast<uint64_t*>(&w2_a);
    uint64_t* puw2_b = reinterpret_cast<uint64_t*>(&w2_b);

    double* pdtout_a = reinterpret_cast<double*>(&tout_a);
    double* pdtout_b = reinterpret_cast<double*>(&tout_b);

    uint64_t* putout_a = reinterpret_cast<uint64_t*>(&tout_a);
    uint64_t* putout_b = reinterpret_cast<uint64_t*>(&tout_b);


    hreadtype outa, outb;


    read_from_stream:	for(int i=0;i<n;i+=2){
#pragma HLS PIPELINE II=1
#pragma HLS LOOP_TRIPCOUNT min=1 max=1100
		readType temp1 = inXstream.read();
		readType temp2 = inDstream.read();
        (*puw1_a) = temp1.range(63, 0);
        (*puw1_b) = temp1.range(127, 64);
        (*puw2_a) = temp2.range(63, 0);
        (*puw2_b) = temp2.range(127, 64);

        *pdtout_a = *pdw1_a / *pdw2_a;
        *pdtout_b = *pdw1_b / *pdw2_b;

        outa = *putout_a;
        outb = *putout_b;



        
        readType writeconcat = outb.concat(outa);
		outXstream.write(writeconcat);

	}
}


void writeout(LDL_int n, hls::stream<readType>&inXstream, readType* X_final){
    readType seks = 0;
    write:	for(int i=0;i<n/2;i++){
#pragma HLS PIPELINE II=1
#pragma HLS LOOP_TRIPCOUNT min=1 max=550
        seks = inXstream.read();
        X_final[i] = seks;
	}
}

extern "C" {
void ldl_dsolve(LDL_int n, readType * X, readType * D, readType * out)
{

#pragma HLS INTERFACE mode=m_axi bundle=gmem0 depth=MAXIDEP port=X offset=slave
#pragma HLS INTERFACE mode=m_axi bundle=gmem1 depth=MAXIDEP port=D offset=slave
#pragma HLS INTERFACE mode=m_axi bundle=gmem2 depth=MAXIDEP port=out offset=slave

#pragma HLS INTERFACE s_axilite port=X bundle=control
#pragma HLS INTERFACE s_axilite port=D bundle=control
#pragma HLS INTERFACE s_axilite port=out bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=n bundle=control



    hls::stream<readType>X_stream;
#pragma HLS STREAM variable=X_stream depth=3 type=fifo
    hls::stream<readType>D_stream;
#pragma HLS STREAM variable=D_stream depth=3 type=fifo
    hls::stream<readType>X2_stream;
#pragma HLS STREAM variable=X2_stream depth=3 type=fifo
#pragma HLS DATAFLOW
    
    read1(n, X, X_stream);
    read2(n, D, D_stream);
    compute(n, X_stream, D_stream, X2_stream);
    writeout(n, X2_stream, out);
}
}