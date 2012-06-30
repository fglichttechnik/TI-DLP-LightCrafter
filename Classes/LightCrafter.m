classdef LightCrafter < handle
   properties (Hidden)
   	tcpConnection;
   end
   % The following properties can be set only by class methods
   properties (SetAccess = private)

   end
   % Define an event called InsufficientFunds
   events
   end
   methods
   
      function obj = LightCrafter(AccountNumber,InitialBalance)
         %BA.AccountNumber = AccountNumber;
        % BA.AccountBalance = InitialBalance;
         % Calling a static method requires the class name
         % addAccount registers the InsufficientFunds listener on this instance
        % AccountManager.addAccount(BA);
      end
      
      function connect( obj )
		obj.tcpConnection =  = tcpip( '192.168.1.100', 21845 )
		fopen( obj.tcpConnection )
      end
      
      function disconnect( obj )
		fclose( obj.tcpConnection )
      end
      
      function header = createHeader( obj )
		return uint8( zeros( 6, 1 ) )
      end
      
      function packet = appendPayloadLengthToHeaderForPayload( obj, header, payload )
      	
      	payloadLength = length( payload );
		payloadLengthMSB = floor( payloadLength / 256 )
		payloadLengthLSB = mod( payloadLength, 256 )
      	
      	header( 5 ) = uint8( payloadLengthLSB ); %payloadLength LSB
      	header( 6 ) = uint8( payloadLengthMSB ); %payloadLength MSB
      	
		return header;
      end
      
      function packet = appendChecksum( obj, packet )
      	checksum = mod( sum( packet ), 256 );
		return [ packet; checksum ];
      end

	function setDisplayModeStatic( obj )
      	header = obj.createHeader();
      	header( 1 ) = uint8( hex2dec( '02' ) );	%packet type
      	header( 2 ) = uint8( hex2dec( '01' ) ); %CMD1
      	header( 3 ) = uint8( hex2dec( '01' ) ); %CMD2
      	header( 4 ) = uint8( hex2dec( '00' ) ); %flags
      	header( 5 ) = uint8( hex2dec( '01' ) ); %payloadLength LSB
      	header( 6 ) = uint8( hex2dec( '00' ) ); %payloadLength MSB
      	payload = uint8( hex2dec( '00' ) ); %payload
      	packet = obj.appendChecksum( [ header; payload ] );
      	obj.sendData( packet );
      end
      
      function sendBMPImageData( obj, imageData )
      	MAX_PAYLOAD_SIZE = 65535;
      	numberOfChunks = length( imageData ) / 65535;
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
      		obj.appendPayloadLengthToHeaderForPayload( header, currentChunk );
      		
      		%append flag
      		if( numberOfChunks == 1 )
      			header( 4 ) = uint8( hex2dec( '00' ) ); %flags
      		else
      			if( currentChunkIndex == 1 )
      				header( 4 ) = uint8( hex2dec( '01' ) ); %flags
      			elseif( currentChunkIndex == numberOfChunks )
      				header( 4 ) = uint8( hex2dec( '03' ) ); %flags
      			else
      				header( 4 ) = uint8( hex2dec( '02' ) ); %flags
      			end
      		end
      		
      		packet = obj.appendChecksum( [ header; currentChunk ] );
      		obj.sendData( packet );
      	end
      	
      	

      
      
      end

	function sendData( obj, packet )
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
    fwrite( obj.tcpConnection, currentPacket) ;
    disp('wrote some data')
end
	end

   end % methods
end % classdef 