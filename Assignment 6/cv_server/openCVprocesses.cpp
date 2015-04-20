#include <functional>
#include <thread>
#include <vector>
#include <SDL/SDL.h>

#include "server.hpp"
#include "lodepng.h"
#include "lodepng_util.h"

//Example 1
//Decode from disk to raw pixels with a single function call
void decodeOneStep(const char* filename);

//int show(const std::string& caption, const unsigned char* rgba, unsigned w, unsigned h);
//int showfile(const char* filename);


int main() 
{
	// TEST ABILITY TO OPEN BINARY ENCODED PNG FILE
	//g++ lodepng.cpp example_decode.cpp -ansi -pedantic -Wall -Wextra -O3
	decodeOneStep("squirrel_ping.bin");
	//showfile("squirrel_ping.bin");

	//new std::thread([] () 
  	//{
		auto server = new ev9::server<false>(8080, [](std::vector<char>& input, 						std::vector<char>& output)
      	{
			//output.push_back('h');
		}); // end new server
	//});  // end new thread

   return 0;

}//end main





//Example 1
//Decode from disk to raw pixels with a single function call
void decodeOneStep(const char* filename)
{
	std::vector<unsigned char> image; //the raw pixels
	unsigned width, height;

	//decode
	unsigned error = lodepng::decode(image, width, height, filename);

	//if there's an error, display it
	if(error) std::cout << "decoder error " << error << ": " << lodepng_error_text(error) << std::endl;

//the pixels are now in the vector "image", 4 bytes per pixel, ordered 			RGBARGBA..., use it as texture, draw it, ...
}

/*
int show(const std::string& caption, const unsigned char* rgba, unsigned w, unsigned h)
{
  //avoid too large window size by downscaling large image
  unsigned jump = 1;
  if(w / 1024 >= jump) jump = w / 1024 + 1;
  if(h / 1024 >= jump) jump = h / 1024 + 1;

  //init SDL
  if(SDL_Init(SDL_INIT_VIDEO) < 0)
  {
    std::cout << "error, SDL video init failed" << std::endl;
    return 0;
  }
  SDL_Surface* scr = SDL_SetVideoMode(w / jump, h / jump, 32, SDL_HWSURFACE);
  if(!scr)
  {
    std::cout << "error, no SDL screen" << std::endl;
    return 0;
  }
  SDL_WM_SetCaption(caption.c_str(), NULL); //set window caption

  //plot the pixels of the PNG file
  for(unsigned y = 0; y + jump - 1 < h; y += jump)
  for(unsigned x = 0; x + jump - 1 < w; x += jump)
  {
    //get RGBA components
    Uint32 r = rgba[4 * y * w + 4 * x + 0]; //red
    Uint32 g = rgba[4 * y * w + 4 * x + 1]; //green
    Uint32 b = rgba[4 * y * w + 4 * x + 2]; //blue
    Uint32 a = rgba[4 * y * w + 4 * x + 3]; //alpha

    //make translucency visible by placing checkerboard pattern behind image
    int checkerColor = 191 + 64 * (((x / 16) % 2) == ((y / 16) % 2));
    r = (a * r + (255 - a) * checkerColor) / 255;
    g = (a * g + (255 - a) * checkerColor) / 255;
    b = (a * b + (255 - a) * checkerColor) / 255;

    //give the color value to the pixel of the screenbuffer
    Uint32* bufp;
    bufp = (Uint32 *)scr->pixels + (y * scr->pitch / 4) / jump + (x / jump);
    *bufp = 65536 * r + 256 * g + b;
  }

  //pause until you press escape and meanwhile redraw screen
  SDL_Event event;
  int done = 0;
  while(done == 0)
  {
    while(SDL_PollEvent(&event))
    {
      if(event.type == SDL_QUIT) done = 2;
      else if(SDL_GetKeyState(NULL)[SDLK_ESCAPE]) done = 2;
      else if(event.type == SDL_KEYDOWN) done = 1; //press any other key for next image
    }
    SDL_UpdateRect(scr, 0, 0, 0, 0); //redraw screen
    SDL_Delay(5); //pause 5 ms so it consumes less processing power
  }

  SDL_Quit();
  return done == 2 ? 1 : 0;
}
*/

/*shows image with SDL. Returns 1 if user wants to fully quit, 0 if user wants to see next image.*/
/*
int showfile(const char* filename)
{
  std::cout << "showing " << filename << std::endl;

  std::vector<unsigned char> buffer, image;
  lodepng::load_file(buffer, filename); //load the image file with given filename
  unsigned w, h;
  unsigned error = lodepng::decode(image, w, h, buffer); //decode the png

  //stop if there is an error
  if(error)
  {
    std::cout << "decoder error " << error << ": " << lodepng_error_text(error) << std::endl;
    return 0;
  }

  return show(filename, &image[0], w, h);
}
*/
