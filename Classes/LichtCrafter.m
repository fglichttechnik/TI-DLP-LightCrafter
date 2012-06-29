tcpObject = tcpip('192.168.1.100',21845)
 
fopen(tcpObject)
 
fwrite(tcpObject,uint8(hex2dec(['02';'01';'01';'00';'01';'00';'00';'05'])));%switch display mode to static

% fwrite(tcpObject,uint8(hex2dec(['02';'01';'01';'00';'01';'00';'01';'06'])));%siwtch display mode to internal
% fwrite(tcpObject,uint8(hex2dec(['02';'01';'03';'00';'01';'00';'00';'07'])));%switch to internal pattern: checkboard
% fwrite(tcpObject,uint8(hex2dec(['02';'01';'03';'00';'01';'00';'0A';'11'])));%switch to internal pattern: diagonal
% fwrite(tcpObject,uint8(hex2dec(['02';'01';'03';'00';'01';'00';'0C';'13'])));%switch to internal pattern: ramp

%create simple image
im = zeros( 30,30);
im (3:8, 3:8) = 1;
imwrite( im, 'im.bmp' );
imFile = fopen( 'im.bmp' );
imData = fread( imFile, inf, 'uchar' );
fclose( imFile );

lenData = length( imData );
lenDataMSB = floor( lenData / 256 )
lenDataLSB = mod( lenData, 256 )

%604, 684 );
%im (300:350, 300:350) = 1;

%Byte0      packet type
%0x02 host write command
%Byte1      CMD1
%Byte2      CMD2
%Byte3      flags
%0x00 packet payload contains complete data
%0x01 packet payload contains beginning data
%0x02 packet payload contains intermediate data
%0x03 packet payload contains last data
%Byte4      payload length LSB
%Byte5      payload length MSB
%Byte6..N   data payload max 65535 bytes
%ByteN+1    checksum sum(bytes) mod 0x100





%uint8(hex2dec(
%cmdArray = ['02';'01';'05';'00'; int2str(dec2hex(lenDataLSB)); int2str(dec2hex(lenDataMSB))];
%cmdArray = [cmdArray; uint8(imData')];

%send header
header = uint8(hex2dec(['02';'01';'05';'00'; dec2hex( lenDataLSB, 2 ); dec2hex( lenDataMSB, 2 )]));%static image
fwrite(tcpObject,header);

%header = uint8(hex2dec(['02';'04';'01';'00'; dec2hex( int2str( lenDataLSB ) ); dec2hex( int2str( lenDataMSB ) )]));%pattern definition
%data = [1;uint8(imData)];

%fwrite(tcpObject,data);

%send data
data = uint8(imData);
%limit packet size
MAX_SIZE = 512;
buffer = data;
while (~isnan(buffer))
    if( length(buffer) > MAX_SIZE )
        currentPacket = buffer( 1 : MAX_SIZE);
        buffer = buffer( MAX_SIZE + 1 : end );
    else
        currentPacket = buffer( 1 : end);
        buffer = NaN;
    end
    fwrite(tcpObject,currentPacket);
    disp('wrote some data')
end



%send checksum
checksum = mod( sum(header) + sum(data), 256 );
fwrite(tcpObject,checksum);


%fwrite(tcpObject,cmdArray);

fclose( tcpObject );