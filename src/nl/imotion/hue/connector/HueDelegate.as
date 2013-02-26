package nl.imotion.hue.connector
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;

    import nl.imotion.delegates.AsyncDelegate;


    /**
     * @author Pieter van de Sluis
     */
    public class HueDelegate extends AsyncDelegate
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _loader:URLLoader;

        private static var _ipAddress:String;
        private static var _userName:String;

        private var _method:String;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueDelegate( operationName:String = null, requestData:String = null, method:String = URLRequestMethod.GET, resultCallbacks:/*Function*/Array = null, faultCallbacks:/*Function*/Array = null )
        {
            super( operationName, requestData, resultCallbacks, faultCallbacks );

            _method = method;

            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        override public function execute():void
        {
            if ( !_ipAddress )
                throw new Error( "Hue Bridge IP address is not set" );

            if ( !_userName )
                throw new Error( "User name is not set" );

            super.execute();

            addListeners();

            var request:URLRequest;

            if ( operationName == "register" )
            {
                request = new URLRequest( baseURL );
            }
            else
            {
                request = new URLRequest( appURL + operationName );
            }

            request.data = requestData;
            request.method = _method;

            _loader.load( request );
        }

        // ____________________________________________________________________________________________________
        // PRIVATE

        private function init():void
        {
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.TEXT;
        }


        private function addListeners():void
        {
            _loader.addEventListener( Event.COMPLETE, handleComplete );
            _loader.addEventListener( IOErrorEvent.IO_ERROR, handleFault );
            _loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleFault );
        }


        private function removeListeners():void
        {
            _loader.removeEventListener( Event.COMPLETE, handleComplete );
            _loader.removeEventListener( IOErrorEvent.IO_ERROR, handleFault );
            _loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, handleFault );
        }

        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        private function get baseURL():String
        {
            return "http://" + _ipAddress + "/api";
        }


        private function get appURL():String
        {
            return baseURL + "/" + _userName;
        }


        public static function get userName():String
        {
            return _userName;
        }
        public static function set userName( value:String ):void
        {
            _userName = value;
        }


        public static function get ipAddress():String
        {
            return _ipAddress;
        }
        public static function set ipAddress( value:String ):void
        {
            _ipAddress = value;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS

        private function handleComplete( e:Event ):void
        {
            removeListeners();
            onResult( _loader.data );
        }

        private function handleFault( e:Event ):void
        {
            removeListeners();
            onFault( e );
        }


    }
}