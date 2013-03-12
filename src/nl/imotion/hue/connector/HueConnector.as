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

    import nl.imotion.delegates.AsyncDelegate;
    import nl.imotion.delegates.events.AsyncDelegateEvent;

    import spark.primitives.Path;


    /**
     * @author Pieter van de Sluis
     */

    public class HueConnector
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES


        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueConnector( ipAddress:String = null, userName:String = null )
        {
            this.ipAddress = ipAddress;
            this.userName = userName;
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        // Common

        public function discoverBridge( resultCallback:Function = null, faultCallback:Function = null ):BridgeDiscoveryDelegate
        {
            return storeAndExecute( new BridgeDiscoveryDelegate( [resultCallback ], [ faultCallback ] ) ) as BridgeDiscoveryDelegate;
        }


        public function doRequest( path:String = "", data:Object = null, method:String = URLRequestMethod.GET, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var stringifiedData:String;

            if ( data )
            {
                stringifiedData = JSON.stringify( data );
            }

            return storeAndExecute( new HueDelegate( path, stringifiedData, method, [ resultCallback ], [ faultCallback ] ) ) as HueDelegate;
        }


        public function getConfig( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/config", null, resultCallback, faultCallback );
        }


        public function setConfig( data:Object,  resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/config", data, resultCallback, faultCallback );
        }


        public function getFullState( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "", null, resultCallback, faultCallback );
        }

        // Registration

        public function addUser( deviceType:String, userName:String = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "devicetype": deviceType,
                "username": userName
            };

            return doRequest( "", data, URLRequestMethod.POST, resultCallback, faultCallback );
        }


        public function removeUser( userName:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doDelete( "/config/whitelist/" + userName, null, resultCallback, faultCallback );
        }

        // Lights

        public function doLightRequest( id:String, data:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/lights/" + id + "/state", data, resultCallback, faultCallback );
        }


        public function getNewLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights/new", null, resultCallback, faultCallback );
        }


        public function searchNewLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPost( "/lights", null, resultCallback, faultCallback );
        }

        public function getLight( lightID:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights/" + lightID, null, resultCallback, faultCallback );
        }

        public function getLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights", null, resultCallback, faultCallback );
        }

        public function changeLightName( lightID:String, name:String, state:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "name": name
            };

            return doPut(  "/lights/" + lightID, data, resultCallback, faultCallback );
        }

        public function setLightState( id:String, state:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doLightRequest( id, state, resultCallback, faultCallback );
        }

        public function setLightHSB( id:String, hue:Number = 0, saturation:Number = 0.75, brightness:Number = 1, transitionTime:Number = 10, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                hue:hue,
                sat:saturation,
                bri:brightness,
                transitiontime:transitionTime
            };

            return setLightState( id, data, resultCallback, faultCallback );
        }

        public function toggleLight( id:String, isSwitchedOn:Boolean, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "on": isSwitchedOn
            };

            return doLightRequest( id, data, resultCallback, faultCallback );
        }

        public function alert( id:String, isLongSelect:Boolean = false, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var alertMethod:String = isLongSelect ? "lselect" : "select";

            var data:Object =
            {
                "alert":alertMethod
            };

            return doLightRequest( id, data, resultCallback, faultCallback );
        }

        // Groups

        public function getGroups( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/groups", null, resultCallback, faultCallback );
        }

        public function getGroup( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/groups/" + id, null, resultCallback, faultCallback );
        }

        public function setGroupName( id:String, newName:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                name: newName
            };

            return doPut( "/groups/" + id, data, resultCallback, faultCallback );
        }

        public function setGroupLights( id:String, lightIDs:Array, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                lights: lightIDs
            };

            return doPut( "/groups/" + id, data, resultCallback, faultCallback );
        }

        public function setGroupState( id:String, data:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/groups/" + id + "/action", data, resultCallback, faultCallback );
        }

        public function setGroupHSB( id:String, hue:Number = 0, saturation:Number = 0.75, brightness:Number = 1, transitionTime:Number = 10, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                hue:hue,
                sat:saturation,
                bri:brightness,
                transitiontime:transitionTime
            };

            return setGroupState( id, data, onResult, onFault );
        }


        private function toggleGroup( id:String, isSwitchedOn:Boolean, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "on": isSwitchedOn
            }

            return setGroupState( id, data, resultCallback, faultCallback );
        }

        // NOT SUPPORTED RIGHT NOW

        /*public function addGroup( name:String, lightIDs:Array, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
         {
         var data:Object =
         {
         "name":name,
         "lights":lightIDs
         };

         return doPost( "/groups", data, resultCallback, faultCallback );
         }


         public function removeGroup( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
         {
         return doDelete( "/groups/" + id, null, resultCallback, faultCallback );
         }*/


        // Schedules

        public function getSchedules( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/schedules", null, resultCallback, faultCallback );
        }


        public function getSchedule( scheduleID:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/schedules/" + scheduleID, null, resultCallback, faultCallback );
        }


        public function addSchedule( schedule:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            schedule.command.address = schedule.command.address.split( "{userName}" ).join( HueDelegate.userName );

            return doPost( "/schedules", schedule, resultCallback, faultCallback );
        }


        public function changeSchedule( scheduleID:String, schedule:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            schedule.command.address = schedule.command.address.split( "{userName}" ).join( HueDelegate.userName );

            return doPut( "/schedules/" + scheduleID, schedule, resultCallback, faultCallback );
        }


        public function removeSchedule( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doDelete( "/schedules/" + id, null, resultCallback, faultCallback );
        }


        // ____________________________________________________________________________________________________
        // PRIVATE

        private function storeAndExecute( delegate:AsyncDelegate ):AsyncDelegate
        {
            delegate.addEventListener( AsyncDelegateEvent.RESULT, handleDelegateResult );
            delegate.addEventListener( AsyncDelegateEvent.FAULT, handleDelegateFault );
            delegate.execute();

            return delegate;
        }


        private function doGet( path:String = "", data:Object = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.GET, resultCallback, faultCallback );
        }


        private function doPut( path:String = "", data:Object = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.PUT, resultCallback, faultCallback );
        }


        private function doPost( path:String = "", data:Object = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doRequest( path, data, URLRequestMethod.POST, resultCallback, faultCallback );
        }


        private function doDelete( path:String = "", data:Object = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
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