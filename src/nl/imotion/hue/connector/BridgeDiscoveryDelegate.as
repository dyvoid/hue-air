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
    public class BridgeDiscoveryDelegate extends AsyncDelegate
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _loader:URLLoader;

        private var _nupnpURL:String = "https://www.meethue.com/api/nupnp";

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function BridgeDiscoveryDelegate(resultCallbacks:/*Function*/Array = null, faultCallbacks:/*Function*/Array = null )
        {
            super( null, null, resultCallbacks, faultCallbacks );

            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        override public function execute():void
        {
            super.execute();

            addListeners();

            var request:URLRequest;
            request = new URLRequest( _nupnpURL );
            request.method = URLRequestMethod.GET;

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



        // ____________________________________________________________________________________________________
        // EVENT HANDLERS

        private function handleComplete( e:Event ):void
        {
            removeListeners();

            try
            {
                var result:Object = JSON.parse( _loader.data );
            }
            catch ( error:Error )
            {
                handleFault( e );
                return;
            }

            if ( result is Array && result.length > 0 && result[ 0 ].internalipaddress )
            {
                onResult( result[ 0 ].internalipaddress );
            }
            else
            {
                onResult( null );
            }
        }

        private function handleFault( e:Event ):void
        {
            removeListeners();
            onFault( e );
        }


    }
}