%create simple image
im1 = zeros( 684, 608, 3 );
im1 (300:380, 300:380, :) = 255;
imwrite( im1, 'im1.bmp' );
imFile1 = fopen( 'im1.bmp' );
imData1 = fread( imFile1, inf, 'uchar' );
fclose( imFile1 );

im2 = zeros( 684, 608, 1 );
im2 (300:380, 300:380, :) = 255;
imwrite( im2, 'im2.bmp' );
imFile2 = fopen( 'im2.bmp' );
imData2 = fread( imFile2, inf, 'uchar' );
fclose( imFile2 );

im3 = zeros( 684, 608, 3 );
im3 (300:380, 300:380, :) = 1;
imwrite( im3, 'im3.bmp' );
imFile3 = fopen( 'im3.bmp' );
imData3 = fread( imFile3, inf, 'uchar' );
fclose( imFile3 );

%load file
% imFile = fopen( 'im.bmp' );
% imData = fread( imFile, inf, 'uchar' );
% fclose( imFile );

%test light crafter
L=LightCrafter()
%L.connect()
tcpObject = tcpip('192.168.1.100',21845)
tcpObject.BytesAvailableFcn = @instrcallback
tcpObject.BytesAvailableFcnCount = 7;
tcpObject.BytesAvailableFcnMode = 'byte';
fopen(tcpObject)
%L.setBMPImage( imData1, tcpObject )
%L.setStaticColor( 'FF', 'FF', 'FF', tcpObject )
L.setPattern('0A', tcpObject)

%data = fread(tcpObject,tcpObject.BytesAvailable);

