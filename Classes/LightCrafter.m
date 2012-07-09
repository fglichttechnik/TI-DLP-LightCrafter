%AUTHOR: Jan Winter, TU Berlin, FG Lichttechnik j.winter@tu-berlin.de
%LICENSE: free to use at your own risk. Kudos appreciated.

classdef LightCrafter < handle
    properties %(Hidden)
        tcpConnection
    end
    methods
        
        %constructor
        function obj = LightCrafter()
            
        end
        
        function connect( obj )
            obj.tcpConnection = tcpip( '192.168.1.100', 21845 )
            fopen( obj.tcpConnection )
        end
        
        function disconnect( obj )
            fclose( obj.tcpConnection )
        end
        
        function header = createHeader( obj )
            header = uint8( zeros( 6, 1 ) );
        end
        
        function modifiedHeader = appendPayloadLengthToHeaderForPayload( obj, header, payload )
            
            payloadLength = length( payload );
            payloadLengthMSB = floor( payloadLength / 256 )
            payloadLengthLSB = mod( payloadLength, 256 )
            
            header( 5 ) = uint8( payloadLengthLSB ); %payloadLength LSB
            header( 6 ) = uint8( payloadLengthMSB ); %payloadLength MSB

            modifiedHeader = header
        end
        
        function modifiedPacket = appendChecksum( obj, packet )
            checksum = mod( sum( packet ), 256 )
            modifiedPacket = [ packet; checksum ];
        end
        
        function setDisplayModeStatic( obj, connection )
            header = obj.createHeader();
            header( 1 ) = uint8( hex2dec( '02' ) );	%packet type
            header( 2 ) = uint8( hex2dec( '01' ) ); %CMD1
            header( 3 ) = uint8( hex2dec( '01' ) ); %CMD2
            header( 4 ) = uint8( hex2dec( '00' ) ); %flags
            header( 5 ) = uint8( hex2dec( '01' ) ); %payloadLength LSB
            header( 6 ) = uint8( hex2dec( '00' ) ); %payloadLength MSB
            payload = uint8( hex2dec( '00' ) ); %payload
            packet = obj.appendChecksum( [ header; payload ] );
            %packet
            obj.sendData( packet, connection );
        end
        
        function setDisplayModeInternalPattern( obj, connection )
            header = obj.createHeader();
            header( 1 ) = uint8( hex2dec( '02' ) );	%packet type
            header( 2 ) = uint8( hex2dec( '01' ) ); %CMD1
            header( 3 ) = uint8( hex2dec( '01' ) ); %CMD2
            header( 4 ) = uint8( hex2dec( '00' ) ); %flags
            header( 5 ) = uint8( hex2dec( '01' ) ); %payloadLength LSB
            header( 6 ) = uint8( hex2dec( '00' ) ); %payloadLength MSB
            payload = uint8( hex2dec( '01' ) ); %payload
            packet = obj.appendChecksum( [ header; payload ] );
            %packet
            obj.sendData( packet, connection );
        end
        
        function setPattern( obj, pattern, connection )
            
            obj.setDisplayModeInternalPattern( connection );
            
            if ( ~ischar( pattern ) && ( length(pattern) ~= 2 ) )
                disp('pattern must be a 2 digit hex string in range 00 to 0D')
                return;
            end
            
            header = obj.createHeader();
            header( 1 ) = uint8( hex2dec( '02' ) );	%packet type
            header( 2 ) = uint8( hex2dec( '01' ) ); %CMD1
            header( 3 ) = uint8( hex2dec( '03' ) ); %CMD2
            header( 4 ) = uint8( hex2dec( '00' ) ); %flags
            header( 5 ) = uint8( hex2dec( '01' ) ); %payloadLength LSB
            header( 6 ) = uint8( hex2dec( '00' ) ); %payloadLength MSB
            payload = uint8( hex2dec( pattern ) ); %payload
            packet = obj.appendChecksum( [ header; payload ] );
            %packet
            obj.sendData( packet, connection );
        end
        
        function setStaticColor( obj, R, G, B, connection )
            
            obj.setDisplayModeStatic( connection );
            
            if ( ~ischar( R ) && ( length(R) ~= 2 ) )
                disp('R must be a 2 digit hex string in range 00 to FF')
                return;
            end
            if ( ~ischar( G ) && ( length(G) ~= 2 ) )
                disp('G must be a 2 digit hex string in range 00 to FF')
                return;
            end
            if ( ~ischar( B ) && ( length(B) ~= 2 ) )
                disp('B must be a 2 digit hex string in range 00 to FF')
                return;
            end
            
            header = obj.createHeader();
            header( 1 ) = uint8( hex2dec( '02' ) );	%packet type
            header( 2 ) = uint8( hex2dec( '01' ) ); %CMD1
            header( 3 ) = uint8( hex2dec( '06' ) ); %CMD2
            header( 4 ) = uint8( hex2dec( '00' ) ); %flags
            header( 5 ) = uint8( hex2dec( '04' ) ); %payloadLength LSB
            header( 6 ) = uint8( hex2dec( '00' ) ); %payloadLength MSB
            payload = uint8( [ hex2dec( '00' ); hex2dec( R ); hex2dec( G ); hex2dec( B ) ] ); %payload
            packet = obj.appendChecksum( [ header; payload ] );
            %packet
            obj.sendData( packet, connection );
        end
        
        function setBMPImage( obj, imageData, connection )
            
            obj.setDisplayModeStatic( connection );
            
            MAX_PAYLOAD_SIZE = 65535;
            numberOfChunks = ceil( length( imageData ) / 65535 );
            chunkArray = cell( numberOfChunks, 1 );
            for i = 1 : numberOfChunks
                currentLength = length( imageData );
                if( currentLength > MAX_PAYLOAD_SIZE )
                    chunkArray{ i } = imageData( 1 : MAX_PAYLOAD_SIZE );
                    imageData = imageData( MAX_PAYLOAD_SIZE + 1 : end );
                else
                    chunkArray{ i } = imageData( 1 : end );
                end
            end
            
            for currentChunkIndex = 1 : numberOfChunks
                
                currentChunk = chunkArray{ currentChunkIndex };
                
                header = obj.createHeader();
                header( 1 ) = uint8( hex2dec( '02' ) );	%packet type
                header( 2 ) = uint8( hex2dec( '01' ) ); %CMD1
                header( 3 ) = uint8( hex2dec( '05' ) ); %CMD2
                header = obj.appendPayloadLengthToHeaderForPayload( header, currentChunk );
                
                %append flag
                if( numberOfChunks == 1 )
                    header( 4 ) = uint8( hex2dec( '00' ) ); %flags
                else
                    if( currentChunkIndex == 1 )
                        disp('FIRST CHUNK')
                        header( 4 ) = uint8( hex2dec( '01' ) ); %flags
                    elseif( currentChunkIndex == numberOfChunks )
                        disp('LAST CHUNK')
                        header( 4 ) = uint8( hex2dec( '03' ) ); %flags
                    else
                        disp('OTHER CHUNK')
                        header( 4 ) = uint8( hex2dec( '02' ) ); %flags
                    end
                end
                
                
                packet = obj.appendChecksum( [ header; currentChunk ] );
                obj.sendData( packet, connection );
            end  
        end
        
        function sendData( obj, packet, connection )
            %limit packet size
            MAX_SIZE = 512;
            buffer = packet;
            while (~isnan(buffer))
                if( length(buffer) > MAX_SIZE )
                    currentPacket = buffer( 1 : MAX_SIZE );
                    buffer = buffer( MAX_SIZE + 1 : end );
                else
                    currentPacket = buffer( 1 : end );
                    buffer = NaN;
                end
                %fwrite( obj.tcpConnection, currentPacket ) ;
                fwrite( connection, currentPacket ) ;
                disp('wrote some data');
                %disp( currentPacket );
            end
        end
        
    end % methods
end % classdef