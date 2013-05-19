/*
 * Licensed under the MIT license
 *
 * Copyright (c) 2009-2013 Pieter van de Sluis
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://code.google.com/p/imotionproductions/
 */

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

        public static const DISCOVER    :String = "discover";

        private static const NUPNP_URL  :String = "https://www.meethue.com/api/nupnp";

        private var _loader:URLLoader;

        private static var _ipAddress:String;
        private static var _userName:String;

        private var _method:String;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueDelegate( path:String = null, requestData:String = null, method:String = URLRequestMethod.GET, resultCallbacks:/*Function*/Array = null, faultCallbacks:/*Function*/Array = null )
        {
            super( path, requestData, resultCallbacks, faultCallbacks );

            _method = method;

            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        override public function execute():void
        {
            var request:URLRequest;

            if ( operationName == DISCOVER )
            {
                request = new URLRequest( NUPNP_URL );
            }
            else
            {
                if ( !_ipAddress )
                    throw new Error( "Hue Bridge IP address is not set" );

                if ( requestData && ( requestData.indexOf( "devicetype" ) != -1 ) )
                {
                    request = new URLRequest( baseURL );
                }
                else
                {
                    if ( !_userName )
                        throw new Error( "User name is not set" );

                    request = new URLRequest( appURL + operationName );
                }
            }

            super.execute();

            request.data = requestData;
            request.method = _method;

            addListeners();

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
            trace( _loader.data );

            var result:Object;

            try
            {
                result = JSON.parse( _loader.data );
            }
            catch ( error:Error )
            {
                handleFault( e );
                return;
            }

            onResult( result );

            if ( operationName == DISCOVER )
            {
                if ( result is Array && result.length > 0 && result[ 0 ].internalipaddress )
                {
                    onResult( result[ 0 ].internalipaddress );
                }
                else
                {
                    onResult( null );
                }
            }
            else
            {

            }
        }

        private function handleFault( e:Event ):void
        {
            removeListeners();
            onFault( e );
        }

    }
}