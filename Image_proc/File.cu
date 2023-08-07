
#include <stdio.h>
#include<vector>
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image.h"
#include "stb_image_write.h"
using namespace std;

int width, height;

int main(int argc, char** argv) {

    int channels;
    unsigned char* image_data = stbi_load("Kakashi.png", &width, &height, &channels, 0);

    if (image_data == NULL) {
        // Error handling for image loading
        printf("Error loading the image.\n");
        return 1;
    }

    // Convert the image to grayscale
    if (channels == 3) {
        for (int i = 0; i < width * height; i++) {
            unsigned char r = image_data[i * channels];
            unsigned char g = image_data[i * channels + 1];
            unsigned char b = image_data[i * channels + 2];
            unsigned char gray = (unsigned char)((r + g + b) / 3);
            image_data[i * channels] = gray;
            image_data[i * channels + 1] = gray ;
            image_data[i * channels + 2] = gray ;
        }
    }

    // Save the grayscale image
    stbi_write_png("kakashi_gray.png", width, height, channels, image_data, width * channels);

    // Free the loaded image data
    stbi_image_free(image_data);

    return 0;
}

