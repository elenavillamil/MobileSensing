//
//  PulseViewController.m
//  Assignment4
//
//  Created by Tyler Hargett on 3/17/15.
//  Copyright (c) 2015 Elena Villamil. All rights reserved.
//

#import "PulseViewController.h"
#import "SMUGraphHelper.h"
#import "AVFoundation/AVFoundation.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import "CvVideoCameraMod.h"
using namespace cv;

#define N 10 //The number of images which construct a time series for each pixel
#define PI 3.14159

const static int COUNT_MAX = 100;
const static int FPS = 30;
const static int FILTER_ORDER = 5;

typedef struct {
    double r;       // percent
    double g;       // percent
    double b;       // percent
} rgb;

typedef struct {
    double h;       // angle in degrees
    double s;       // percent
    double v;       // percent
} hsv;


@interface PulseViewController () <CvVideoCameraDelegate>

@property (nonatomic) GraphHelper* graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) BOOL torchIsOn;
@property Scalar lastAverage;
@property bool firstTime;
@property bool handFound;
@property Scalar originalValue;
@property  double* r;
@property  double* g;
@property  double* b;
@property NSInteger count;
@property int ignoreFrameCount;
@property int countFrames;
@property int heartRate;

@property double* unfiltered_hues;

@end

@implementation PulseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.graphHelper->SetBounds(-0.9, 0.9, -0.9, 0.9);

//  [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    
    self.r = new double[COUNT_MAX];
    self.g = new double[COUNT_MAX];
    self.b = new double[COUNT_MAX];
    self.unfiltered_hues = new double[COUNT_MAX];
    self.count = 0;
    
    self.firstTime = true;
    self.handFound = false;
    self.ignoreFrameCount = 15;
    self.countFrames = 0;
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera start];
    
    [self setTorchIsOn:NO];

    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTorchIsOn:YES];
}

-(void)dealloc {
    //graph
    self.graphHelper->tearDownGL();
    delete self.graphHelper;
    self.graphHelper = nil;
    //pixels
    delete []self.r;
    delete []self.g;
    delete []self.b;
    delete []self.unfiltered_hues;
}

#pragma mark - Graphing

- (GraphHelper*) graphHelper
{
    // start animating the graph
//    const static int framesPerSecond = 30;// <-- USING CONST FROM ABOVE
    const static int numDataArraysToGraph = 1;
    
    if (!_graphHelper)
    {
        _graphHelper = new GraphHelper(self,
                                       FPS,
                                       numDataArraysToGraph,
                                       PlotStyleSeparated);//drawing starts immediately after call
    }
    
    return _graphHelper;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // FORCE TORCH OFF
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack)
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    
}

- (void)updateGraph {
    const size_t windowSize = 30;
    float* data = (float*)malloc(sizeof(float) * 300);
    
    for (int i = 1; i < 300; i++)
    {
        float x = float(i);
        if (x > 150) {
            x -= (x-150);
        }
        
        data[i] = x+100;
    }
    
    
    self.graphHelper->setGraphData(0, data, windowSize, 0);
    self.graphHelper->update();
    free(data);
    data = nil;

}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw();
}


#pragma mark - Imaging

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
    
    if (!COUNT_MAX) return;
    // Do some OpenCV stuff with the image
    Mat image_copy;
    Mat grayFrame, output;

    // get average pixel intensity
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    Scalar avgPixelIntensity = cv::mean(image_copy);
    
    if (self.count >= COUNT_MAX)
    {
        self.count = 0;
    }
    
    self.b[self.count] = avgPixelIntensity.val[0];
    self.g[self.count] = avgPixelIntensity.val[1];
    self.r[self.count++] = avgPixelIntensity.val[2];  //<-- WHY IS THIS COUNT++
    
    // Ignore first values of when the camera is turn on.
    if (!self.ignoreFrameCount)
    {
        //NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
        //NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
        
        float* graphData = (float *)malloc(sizeof(float) * self.count);
        for (int i = 0; i < self.count; i++) {
            graphData[i] = float(self.r[i]);
        }
        
        self.graphHelper->setGraphData(0, graphData, 30.0, sqrt(30.0));
        self.graphHelper->update();
        
        if (!self.handFound && !self.firstTime && (avgPixelIntensity.val[0] > self.lastAverage.val[0] + 5 || avgPixelIntensity.val[0] < self.lastAverage.val[0] - 5) && (avgPixelIntensity.val[1] > self.lastAverage[1] + 5 || avgPixelIntensity.val[1] < self.lastAverage.val[1] - 5) && (avgPixelIntensity.val[2] > self.lastAverage.val[2] + 5 || avgPixelIntensity.val[2] < self.lastAverage.val[2] - 5))
        {
            //NSLog(@"Finger Found!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
            NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
            self.handFound = true;
            [self setTorchOn:self.torchIsOn];
            self.ignoreFrameCount = 45;
            NSLog(@"Hand Found");
            
            self.originalValue = avgPixelIntensity;
            [self keepRednessFactor:avgPixelIntensity];
            
        }else if (self.handFound && self.countFrames < 450) {
            self.countFrames++;
            
            self.originalValue = avgPixelIntensity;
            [self keepRednessFactor:avgPixelIntensity];
            
        } else if (self.handFound && (avgPixelIntensity.val[0] > self.originalValue.val[0] + 5 || avgPixelIntensity.val[0] < self.originalValue.val[0] - 5) && (avgPixelIntensity.val[1] > self.originalValue[1] + 5 || avgPixelIntensity.val[1] < self.originalValue.val[1] - 5) && (avgPixelIntensity.val[2] > self.originalValue.val[2] + 5 || avgPixelIntensity.val[2] < self.originalValue.val[2] - 5))
        {
            NSLog(@"Old Values: B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
            NSLog(@"New Values: B: %.1f, G: %.1f,R: %.1f", self.lastAverage.val[0], self.lastAverage.val[1], self.lastAverage.val[2]);
            
            self.handFound = false;
            
            NSLog(@"Removed");
            
        }  else
        {
            self.firstTime = false;
        }
        
        self.lastAverage = avgPixelIntensity;
    }
    
    else
    {
        --self.ignoreFrameCount;
    }

}
#endif

- (void)keepRednessFactor: (Scalar) avgBGRvals
{
    //takes avg of RGB values, converts to HSV, grabs and stores hue
    hsv convert = [self rgb2hsv_s:avgBGRvals];
    self.unfiltered_hues[self.count] = convert.h;
    if (self.countFrames > 300) {
        [self butterworthFilter];
        int rate = [self peakDetection:self.unfiltered_hues count:(int) self.count];        
        self.heartRate = rate;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartRateLabel.text = [NSString stringWithFormat:@"%d", self.heartRate];
        });
        
    }
}

// developed from MATLAB found at http://www.ignaciomellado.es/blog/Measuring-heart-rate-with-a-smartphone-camera
- (void)butterworthFilter
{
    static const int BPM_L = 40;                        // Heart rate lower limit [bpm]
    static const int BPM_H = 230;                       // Heart rate higher limit [bpm]
    //static const int FILTER_STABILIZATION_TIME = 1;     // [seconds]
    
    double scaleFactor = [self sf_bwbp :2 :BPM_L/60.0 :BPM_H/60.0];  // divide by 60 to convert to seconds
    // Butterworth frequencies must be in [0, 1], where 1 corresponds to half the sampling rate
    double cornerLow = (BPM_L/60.0)*scaleFactor;
    double cornerHigh = (BPM_H/60.0)*scaleFactor;
    
    //Create the variables for the numerator and denominator coefficients
    double *DenC = 0;
    double *NumC = 0;
    
    // Denominator Coeffs
    DenC = [self ComputeDenCoeffs :FILTER_ORDER :cornerLow :cornerHigh];
    
    //Pass Numerator Coefficients and Denominator Coefficients arrays into function, will return the same
    NumC = [self ComputeNumCoeffs :FILTER_ORDER :cornerLow: cornerHigh :DenC];
    
    //time series of 5
    double y[5];
    double x[5]={1,2,3,4,5};
    [self filter :FILTER_ORDER :DenC :NumC :5 :x :y];
    
}

/**********************************************************************
 sf_bwbp - calculates the scaling factor for a butterworth bandpass filter.
 The scaling factor is what the c coefficients must be multiplied by so
 that the filter response has a maximum value of 1.
 */
// is n the sampling freq?  so 30 fps?

- (double) sf_bwbp :(int) n :(double) f1f :(double) f2f
{
    int k;            // loop variables
    double ctt;       // cotangent of theta
    double sfr, sfi;  // real and imaginary parts of the scaling factor
    double parg;      // pole angle
    double sparg;     // sine of pole angle
    double cparg;     // cosine of pole angle
    double a, b, c;   // workspace variables
    
    ctt = 1.0 / tan(M_PI * (f2f - f1f) / 2.0);
    sfr = 1.0;
    sfi = 0.0;
    
    for( k = 0; k < n; ++k )
    {
        parg = M_PI * (double)(2*k+1)/(double)(2*n);
        sparg = ctt + sin(parg);
        cparg = cos(parg);
        a = (sfr + sfi)*(sparg - cparg);
        b = sfr * sparg;
        c = -sfi * cparg;
        sfr = b - c;
        sfi = a - b - c;
    }
    
    return( 1.0 / sfr );
}

-(double*) ComputeLP :(int)FilterOrder
{
    double *NumCoeffs;
    int m;
    int i;
    
    NumCoeffs = (double *)calloc( FilterOrder+1, sizeof(double) );
    if( NumCoeffs == NULL ) return( NULL );
    
    NumCoeffs[0] = 1;
    NumCoeffs[1] = FilterOrder;
    m = FilterOrder/2;
    for( i=2; i <= m; ++i)
    {
        NumCoeffs[i] =(double) (FilterOrder-i+1)*NumCoeffs[i-1]/i;
        NumCoeffs[FilterOrder-i]= NumCoeffs[i];
    }
    NumCoeffs[FilterOrder-1] = FilterOrder;
    NumCoeffs[FilterOrder] = 1;
    
    return NumCoeffs;
}


-(double*) ComputeHP :(int)FilterOrder
{
    double* NumCoeffs;
    
    NumCoeffs = [self ComputeLP:FilterOrder];
    if(NumCoeffs == NULL ) return( NULL );
    
    for(int i = 0; i <= FilterOrder; ++i)
        if( i % 2 ) NumCoeffs[i] = -NumCoeffs[i];
    
    return NumCoeffs;
}

- (double*) TrinomialMultiply :(int) FilterOrder :(double*) b :(double*) c
{
    int i, j;
    double *RetVal;
    
    RetVal = (double *)calloc( 4 * FilterOrder, sizeof(double) );
    if( RetVal == NULL ) return( NULL );
    
    RetVal[2] = c[0];
    RetVal[3] = c[1];
    RetVal[0] = b[0];
    RetVal[1] = b[1];
    
    for( i = 1; i < FilterOrder; ++i )
    {
        RetVal[2*(2*i+1)]   += c[2*i] * RetVal[2*(2*i-1)]   - c[2*i+1] * RetVal[2*(2*i-1)+1];
        RetVal[2*(2*i+1)+1] += c[2*i] * RetVal[2*(2*i-1)+1] + c[2*i+1] * RetVal[2*(2*i-1)];
        
        for( j = 2*i; j > 1; --j )
        {
            RetVal[2*j]   += b[2*i] * RetVal[2*(j-1)]   - b[2*i+1] * RetVal[2*(j-1)+1] +
            c[2*i] * RetVal[2*(j-2)]   - c[2*i+1] * RetVal[2*(j-2)+1];
            RetVal[2*j+1] += b[2*i] * RetVal[2*(j-1)+1] + b[2*i+1] * RetVal[2*(j-1)] +
            c[2*i] * RetVal[2*(j-2)+1] + c[2*i+1] * RetVal[2*(j-2)];
        }
        
        RetVal[2] += b[2*i] * RetVal[0] - b[2*i+1] * RetVal[1] + c[2*i];
        RetVal[3] += b[2*i] * RetVal[1] + b[2*i+1] * RetVal[0] + c[2*i+1];
        RetVal[0] += b[2*i];
        RetVal[1] += b[2*i+1];
    }
    
    return RetVal;
}

- (double*) ComputeNumCoeffs :(int)FilterOrder :(double)Lcutoff :(double)Ucutoff :(double*)DenC
{
    double *TCoeffs;
    double *NumCoeffs;
    std::complex<double> *NormalizedKernel;
    double Numbers[11]={0,1,2,3,4,5,6,7,8,9,10};
    int i;
    
    NumCoeffs = (double *)calloc( 2*FilterOrder+1, sizeof(double) );
    if( NumCoeffs == NULL ) return( NULL );
    
    NormalizedKernel = (std::complex<double> *)calloc( 2*FilterOrder+1, sizeof(std::complex<double>) );
    if( NormalizedKernel == NULL ) return( NULL );
    
    TCoeffs = [self ComputeHP:FilterOrder];
    if( TCoeffs == NULL ) return( NULL );
    
    for( i = 0; i < FilterOrder; ++i)
    {
        NumCoeffs[2*i] = TCoeffs[i];
        NumCoeffs[2*i+1] = 0.0;
    }
    NumCoeffs[2*FilterOrder] = TCoeffs[FilterOrder];
    double cp[2];
    double Bw, Wn;
    cp[0] = 2*2.0*tan(PI * Lcutoff/ 2.0);
    cp[1] = 2*2.0*tan(PI * Ucutoff / 2.0);
    
    Bw = cp[1] - cp[0];
    //center frequency
    Wn = sqrt(cp[0]*cp[1]);
    Wn = 2*atan2(Wn,4);
    //double kern;
    const std::complex<double> result = std::complex<double>(-1,0);
    
    for(int k = 0; k<11; k++)
    {
        NormalizedKernel[k] = std::exp(-sqrt(result)*Wn*Numbers[k]);
    }
    double b=0;
    double den=0;
    for(int d = 0; d<11; d++)
    {
        b+=real(NormalizedKernel[d]*NumCoeffs[d]);
        den+=real(NormalizedKernel[d]*DenC[d]);
    }
    for(int c = 0; c<11; c++)
    {
        NumCoeffs[c]=(NumCoeffs[c]*den)/b;
    }
    
    free(TCoeffs);
    return NumCoeffs;
}

- (double*)ComputeDenCoeffs :(int)FilterOrder :(double)Lcutoff :(double) Ucutoff
{
    int k;            // loop variables
    double theta;     // PI * (Ucutoff - Lcutoff) / 2.0
    double cp;        // cosine of phi
    double st;        // sine of theta
    double ct;        // cosine of theta
    double s2t;       // sine of 2*theta
    double c2t;       // cosine 0f 2*theta
    double *RCoeffs;     // z^-2 coefficients
    double *TCoeffs;     // z^-1 coefficients
    double *DenomCoeffs;     // dk coefficients
    double PoleAngle;      // pole angle
    double SinPoleAngle;     // sine of pole angle
    double CosPoleAngle;     // cosine of pole angle
    double a;         // workspace variables
    
    cp = cos(PI * (Ucutoff + Lcutoff) / 2.0);
    theta = PI * (Ucutoff - Lcutoff) / 2.0;
    st = sin(theta);
    ct = cos(theta);
    s2t = 2.0*st*ct;        // sine of 2*theta
    c2t = 2.0*ct*ct - 1.0;  // cosine of 2*theta
    
    RCoeffs = (double *)calloc( 2 * FilterOrder, sizeof(double) );
    TCoeffs = (double *)calloc( 2 * FilterOrder, sizeof(double) );
    
    for( k = 0; k < FilterOrder; ++k )
    {
        PoleAngle = PI * (double)(2*k+1)/(double)(2*FilterOrder);
        SinPoleAngle = sin(PoleAngle);
        CosPoleAngle = cos(PoleAngle);
        a = 1.0 + s2t*SinPoleAngle;
        RCoeffs[2*k] = c2t/a;
        RCoeffs[2*k+1] = s2t*CosPoleAngle/a;
        TCoeffs[2*k] = -2.0*cp*(ct+st*SinPoleAngle)/a;
        TCoeffs[2*k+1] = -2.0*cp*st*CosPoleAngle/a;
    }
    
    DenomCoeffs = [self TrinomialMultiply:FilterOrder :TCoeffs :RCoeffs];
    free(TCoeffs);
    free(RCoeffs);
    
    DenomCoeffs[1] = DenomCoeffs[0];
    DenomCoeffs[0] = 1.0;
    for( k = 3; k <= 2*FilterOrder; ++k )
        DenomCoeffs[k] = DenomCoeffs[2*k-2];
    
    
    return DenomCoeffs;
}

- (void) filter :(int) ord :(double*)a :(double*)b :(int) np :(double*)x :(double*)y
{
    int i,j;
    y[0]=b[0] * x[0];
    for (i=1;i<ord+1;i++)
    {
        y[i]=0.0;
        for (j=0;j<i+1;j++)
            y[i]=y[i]+b[j]*x[i-j];
        for (j=0;j<i;j++)
            y[i]=y[i]-a[j+1]*y[i-j-1];
    }
    for (i=ord+1;i<np+1;i++)
    {
        y[i]=0.0;
        for (j=0;j<ord+1;j++)
            y[i]=y[i]+b[j]*x[i-j];
        for (j=0;j<ord;j++)
            y[i]=y[i]-a[j+1]*y[i-j-1];
    }
}

- (hsv) rgb2hsv_s :(Scalar) BGRcolor
{
    rgb nColor;
    nColor.b = BGRcolor[2];
    nColor.g = BGRcolor[1];
    nColor.r = BGRcolor[0];

    return [self rgb2hsv :nColor];
}

-(hsv) rgb2hsv :(double) nr :(double) ng :(double) nb
{
    rgb nColor;
    nColor.b = nb;
    nColor.g = ng;
    nColor.r = nr;
    
    return [self rgb2hsv :nColor];
}

// following taken from http://stackoverflow.com/questions/3018313/algorithm-to-convert-rgb-to-hsv-and-hsv-to-rgb-in-range-0-255-for-both
-(hsv) rgb2hsv :(rgb)nCol
{
    hsv         oCol;
    double      min, max, delta;
    
    min = nCol.r < nCol.g ? nCol.r : nCol.g;
    min = min  < nCol.b ? min  : nCol.b;
    
    max = nCol.r > nCol.g ? nCol.r : nCol.g;
    max = max  > nCol.b ? max  : nCol.b;
    
    oCol.v = max;                                // v
    delta = max - min;
    if( max > 0.0 ) { // NOTE: if Max is == 0, this divide would cause a crash
        oCol.s = (delta / max);                  // s
    } else {
        // if max is 0, then r = g = b = 0
        // s = 0, v is undefined
        oCol.s = 0.0;
        oCol.h = NAN;                            // its now undefined
        return oCol;
    }
    if( nCol.r >= max )                           // > is bogus, just keeps compilor happy
        oCol.h = ( nCol.g - nCol.b ) / delta;        // between yellow & magenta
    else
        if( nCol.g >= max )
            oCol.h = 2.0 + ( nCol.b - nCol.r ) / delta;  // between cyan & yellow
        else
            oCol.h = 4.0 + ( nCol.r - nCol.g ) / delta;  // between magenta & cyan
    
    oCol.h *= 60.0;                              // degrees
    
    if( oCol.h < 0.0 )
        oCol.h += 360.0;
    
    return oCol;
}

-(rgb) hsv2rgb :(double) nh :(double) ns :(double) nv
{
    hsv nColor;
    nColor.h = nh;
    nColor.s = ns;
    nColor.v = nv;
    
    return [self hsv2rgb :nColor];
}

-(rgb) hsv2rgb :(hsv) nCol
{
    double      hh, p, q, t, ff;
    long        i;
    rgb         oCol;
    
    if(nCol.s <= 0.0) {       // < is bogus, just shuts up warnings
        oCol.r = nCol.v;
        oCol.g = nCol.v;
        oCol.b = nCol.v;
        return oCol;
    }
    hh = nCol.h;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = nCol.v * (1.0 - nCol.s);
    q = nCol.v * (1.0 - (nCol.s * ff));
    t = nCol.v * (1.0 - (nCol.s * (1.0 - ff)));
    
    switch(i) {
        case 0:
            oCol.r = nCol.v;
            oCol.g = t;
            oCol.b = p;
            break;
        case 1:
            oCol.r = q;
            oCol.g = nCol.v;
            oCol.b = p;
            break;
        case 2:
            oCol.r = p;
            oCol.g = nCol.v;
            oCol.b = t;
            break;
            
        case 3:
            oCol.r = p;
            oCol.g = q;
            oCol.b = nCol.v;
            break;
        case 4:
            oCol.r = t;
            oCol.g = p;
            oCol.b = nCol.v;
            break;
        case 5:
        default:
            oCol.r = nCol.v;
            oCol.g = p;
            oCol.b = q;
            break;
    }
    return oCol;
}

- (int)peakDetection:(double*) points count:( int) numOfPoints {
    static int window = 16;
    
    int numOfPeaks = 0;
    double* peaks = (double*)malloc(sizeof(double) * numOfPoints);
    
    
    for (int index  = 0 ; index < numOfPoints; ++index) {
        double sPoint = points[index];
        double max = sPoint;
        int tempMaxPostion = 0;
        
        for (int start = index+1; start < numOfPoints && start < window; ++start) {
            if (max < points[start]) {
                max = points[start];
                tempMaxPostion = start - index;
                
            }
        }
        
        if (tempMaxPostion == window/2 ) {
            peaks[numOfPeaks] = index;
            numOfPeaks++;
        }
    }
    
    int heartBeat = 0;
    
    for (int index = 1; index < numOfPeaks; index++) {
        heartBeat += peaks[index] - peaks[index-1];
    }
    heartBeat /= numOfPeaks*2;
    
    return heartBeat;
}

#pragma mark Hardware - torch & camera

- (IBAction)toggleTorch:(id)sender {
    // you will need to fix the problem of video stopping when the torch is applied in this method
    self.torchIsOn = !self.torchIsOn;
    [self setTorchOn:self.torchIsOn];
}


- (IBAction)switchCamera:(id)sender {
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack)
    {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    else
    {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    }
    [self.videoCamera start];
}

- (void)setTorchOn: (BOOL) onOff
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack)
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
    
}

- (void)setTorchOff: (BOOL) onOff
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
