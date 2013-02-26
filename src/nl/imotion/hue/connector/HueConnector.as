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
    import flash.net.URLRequestMethod;

    import nl.imotion.delegates.events.AsyncDelegateEvent;


    /**
     * @author Pieter van de Sluis
     */

    public class HueConnector
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES




        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueConnector( ipAddress:String, userName:String = null )
        {
            this.ipAddress = ipAddress;
            this.userName = userName;
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function doRequest( path:String = "", data:String = null, method:String = URLRequestMethod.GET, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var delegate:HueDelegate = new HueDelegate( path, data, method, [ resultCallback ], [ faultCallback ] );
            delegate.addEventListener( AsyncDelegateEvent.RESULT, handleDelegateResult );
            delegate.addEventListener( AsyncDelegateEvent.FAULT, handleDelegateFault );
            delegate.execute();

            return delegate;
        }


        public function register( userName:String, deviceType:String, resultCallback:Function = null, faultCallback:Function = null  ):HueDelegate
        {
            var data:String = JSON.stringify (
                {
                    "username": userName,
                    "devicetype": deviceType
                }
            );

            return doRequest( "register", data, URLRequestMethod.POST, resultCallback, faultCallback );
        }


        public function getInfo( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "", null, resultCallback, faultCallback );
        }


        public function getLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights", null, resultCallback, faultCallback );
        }


        public function doLightRequest( id:String, data:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/lights/"+id+"/state", data, resultCallback, faultCallback );
        }


        public function doGroupRequest( id:String, data:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/groups/"+id+"/action", data, resultCallback, faultCallback );
        }


        public function changeLight( id:String, hue:Number = 0, saturation:Number = 0.75, brightness:Number = 1, isOn:Boolean = true, transitionTime:Number = 10, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                hue: hue,
                sat: saturation,
                bri: brightness,
                on: isOn,
                transitiontime: transitionTime
            };

            return updateLight( id, data, resultCallback, faultCallback );
        }


        public function updateLight( id:String, state:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doLightRequest( id, JSON.stringify( state ), resultCallback, faultCallback );
        }


        public function changeGroup( id:String, hue:Number = 0, saturation:Number = 0.75, brightness:Number = 1, isOn:Boolean = true, transitionTime:Number = 10, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                hue: hue,
                sat: saturation,
                bri: brightness,
                on: isOn,
                transitiontime: transitionTime
            };

            return updateGroup( id, data, onResult, onFault );
        }

        public function updateGroup( id:String, action:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGroupRequest( id, JSON.stringify( action ), resultCallback, faultCallback );
        }

        public function toggleLight( id:String, isSwitchedOn:Boolean, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:String = JSON.stringify (
                {
                    "on": isSwitchedOn
                }
            );

            return doLightRequest( id, data, resultCallback, faultCallback );
        }

         private function toggleGroup( id:String, isSwitchedOn:Boolean, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
         {
             var data:String = JSON.stringify (
                     {
                         "on": isSwitchedOn
                     }
             );

             return doGroupRequest( id, data, resultCallback, faultCallback );
         }


        public function alert( id:String, isLongSelect:Boolean = false, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var alertMethod:String = isLongSelect ? "lselect" : "select";

            var data:String = JSON.stringify (
                    {
                        "alert": alertMethod
                    }
            );

            return doLightRequest( id, data, resultCallback, faultCallback );
        }


        public function getSchedules( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/schedules", null, resultCallback, faultCallback );
        }


        public function addSchedule( schedule:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            schedule.command.address = schedule.command.address.split( "{userName}" ).join( HueDelegate.userName );

            return doPost( "/schedules", JSON.stringify( schedule ), resultCallback, faultCallback );
        }


        public function removeSchedule( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doDelete( "/schedules/" + id, null, resultCallback, faultCallback );
        }


        public function getGroups( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/groups", null, resultCallback, faultCallback );
        }


        public function getGroup( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/groups/" + id, null, resultCallback, faultCallback );
        }


        public function addGroup( name:String, lightIDs:Array, resultCallback:Function = null, faultCallback:Function = null):HueDelegate
        {
            var data:String = JSON.stringify (
                    {
                        "name": name,
                        "lights": lightIDs
                    }
            );

            return doPost( "/groups", data, resultCallback, faultCallback );
        }


        public function removeGroup( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doDelete( "/groups/" + id, null, resultCallback, faultCallback );
        }

        // ____________________________________________________________________________________________________
        // PRIVATE

        private function doGet( path:String = "", data:String = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.GET, resultCallback, faultCallback );
        }


        private function doPut( path:String = "", data:String = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.PUT, resultCallback, faultCallback );
        }


        private function doPost( path:String = "", data:String = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.POST, resultCallback, faultCallback );
        }


        private function doDelete( path:String = "", data:String = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.DELETE, resultCallback, faultCallback );
        }

        // ____________________________________________________________________________________________________
        // PROTECTED

        protected function onResult( data:* ):void
        {
            // Placeholder for subclass
        }


        protected function onFault( data:* ):void
        {
            // Placeholder for subclass
        }

        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get ipAddress():String
        {
            return HueDelegate.ipAddress;
        }
        public function set ipAddress( value:String ):void
        {
            HueDelegate.ipAddress = value;
        }


        public function get userName():String
        {
            return HueDelegate.userName;
        }
        public function set userName( value:String ):void
        {
            HueDelegate.userName = value;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS

        private function handleDelegateResult( e:AsyncDelegateEvent ):void
        {
            e.target.removeEventListener( AsyncDelegateEvent.RESULT, handleDelegateResult );
            e.target.removeEventListener( AsyncDelegateEvent.FAULT, handleDelegateResult );
            onResult( e.data );
        }


        private function handleDelegateFault( e:AsyncDelegateEvent ):void
        {
            e.target.removeEventListener( AsyncDelegateEvent.RESULT, handleDelegateResult );
            e.target.removeEventListener( AsyncDelegateEvent.FAULT, handleDelegateResult );
            onFault( e.data );
        }

    }
}