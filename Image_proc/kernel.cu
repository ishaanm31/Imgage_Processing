
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include  <time.h>
#include  <stdlib.h>
#include  <stdio.h>
#include <iostream>
#include  <string.h>
#include  <math.h>
#include  <cuda.h>
#include  <ctime>

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image.h"
#include "stb_image_write.h"

using namespace std;
//Global parameters to be set according to the image to be processed
int width, height;
int mask[3][3] = {{1,2,1},
                  {2,3,2},
                  {1,2,1}
                  };

//Masking function for Host
int getPix(unsigned char* arr, int row, int col) {
    int Pix = 0;
    //Traversing all the 9 pixels in the surroundings
    for (int i = -1;i < 2;i++) {
        for (int j = -1;j < 2;j++) {
            Pix += arr[((row + i) * width) + (col + j)] * mask[i+1][j+1];
        }
    }
    //Normalising the weight
    return Pix / 15;
}

//To be called by the Host and run on the host
//Serial computation
void Host_blur(unsigned char* arr, unsigned char* Img) {
    int offset = 2 * width;
    for ( int row = 2;row < height - 2;row++) {
        for ( int col = 2; col < width - 2; col++) {
            Img[offset + col] = getPix(arr, row, col);
        }
        offset += width;
    }
    return;
}

__global__ void Device_blur(unsigned char* arr, unsigned char* Img, int width, int height) {
    int row=blockIdx.x+blockDim.x + threadIdx.x;
    int col= blockIdx.y + blockDim.y + threadIdx.y;
    if ((row < 0) || (col < 0) || (row >= height ) || (col >= width)) {
        return;
    }
    if ((row < 2) || (col < 2) || (row >= height - 2) || (col >= width - 2)) {
        Img[row * width + col] = 'A';
        return;
    }
    
    int mask[3][3] = { {1,2,1},
                  {2,3,2},
                  {1,2,1}};

    int Pix = 0;
    
    for (int i = -1;i < 2;i++) {
        for (int j = -1;j < 2;j++) {
            Pix += arr[((row + i) * width) + (col + j)] * mask[i + 1][j + 1];
        }
    }

    Img[row * width + col] = Pix / 15;
}

int main(int argc, char** argv) {
    //Array pointers
    unsigned char  *Host_Raw=NULL   ,* Device_Raw=NULL, *Host_Final_Img;

    //Fetching the images
    int channels;
    unsigned char *A = stbi_load("Kakashi.png", &width, &height, &channels, 0);

    Host_Raw = (unsigned char*) malloc(width * height);
    Host_Final_Img = (unsigned char*)malloc(width * height);

    for (int i = 0;i < width * height;i++) {
        Host_Raw[i] = (A[i * channels] + A[i * channels + 1] + A[i * channels + 2])/3;
    }

    int ImageSize = sizeof(unsigned char) * width * height;

    //Host_Final_Img = (unsigned char*)malloc(ImageSize);
    stbi_write_png("kaka_gray.png", width, height, 1, Host_Raw, width );

    //return 0;
//    cudaMalloc((void**)&Device_Raw, ImageSize);
//    cudaMalloc((void**)&Device_Final_Img, ImageSize);

    //************// Setup Work //**************************//
    
    //*********// Host //******************//
    clock_t starttime, endtime, diff;
    starttime = clock();
    Host_blur(Host_Raw, Host_Final_Img);
    endtime = clock();
    diff = endtime - starttime;
    double interval = diff / ((double)CLOCKS_PER_SEC);
    cout << "CPU executed in milisec: " << interval*1000<<endl;

    stbi_write_png("kaka_proc.png", width, height, 1, Host_Final_Img, width);


    //cutSavePGMub(Host_Res_Path, Host_Final_Img, width, height);
   //****// End of host processing //*************//
   
    int x;
    cout << "end!";
    cin >> x;
}



