AUTHOR: Jan Winter, TU Berlin, FG Lichttechnik, j.winter@tu-berlin.de
LICENSE: free to use at your own risk. Kudos appreciated.

This is a framework for MATLAB to make communication with a Texas Instruments DLP LightCrafter easy.

The current state enables you to send BMP images to the device.

This is how you use the code:

%create / load simple image
im1 = zeros( 684, 608, 3 );
im1 (300:380, 300:380, :) = 255;
imwrite( im1, 'im1.bmp' );
imFile1 = fopen( 'im1.bmp' );
imData1 = fread( imFile1, inf, 'uchar' );
fclose( imFile1 );

%connect to the device
tcpObject = tcpip('192.168.1.100',21845)
fopen(tcpObject)

%talk to the device
L=LightCrafter()

%various implemented commands
L.setBMPImage( imData1, tcpObject )
L.setStaticColor( 'FF', 'FF', 'FF', tcpObject )
L.setPattern('0A', tcpObject)