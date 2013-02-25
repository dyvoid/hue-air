package
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

        private static var _hash:String = "c7a514b2b5a681399ecfb86e1265c49c";
        private static var _appName:String = "HueTest";

        private var _baseURL:String = "http://192.168.1.10/api";
        private var _appURL:String = _baseURL + "/" + _hash;

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
            super.execute();

            addListeners();

            var request:URLRequest;

            if ( operationName == "register" )
            {
                request = new URLRequest( _baseURL );
            }
            else
            {
                request = new URLRequest( _appURL + operationName );
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

        public static function get hash():String
        {
            return _hash;
        }
        public static function set hash( value:String ):void
        {
            _hash = value;
        }


        public static function get appName():String
        {
            return _appName;
        }
        public static function set appName( value:String ):void
        {
            _appName = value;
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