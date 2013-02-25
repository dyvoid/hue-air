package
{
    import flash.net.URLRequestMethod;

    import nl.imotion.delegates.events.AsyncDelegateEvent;


    /**
     * @author Pieter van de Sluis
     */

    public class HueApi
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES




        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueApi()
        {
            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function register( username:String, deviceType:String, resultCallback:Function = null, faultCallback:Function = null  ):HueDelegate
        {
            var data:String = '{"username": "'+ username +'", "devicetype": "'+ deviceType +'"}';

            return doRequest( "register", data, URLRequestMethod.POST, resultCallback, faultCallback );
        }


        public function getInfo( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "", null, resultCallback, faultCallback );
        }


        public function getLightInfo( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights", null, resultCallback, faultCallback );
        }


        public function doLightRequest( id:String, data:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/lights/"+id+"/state", data, resultCallback, faultCallback );
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
            return doPut( "/groups/" + id + "/action", JSON.stringify( action ), resultCallback, faultCallback );
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

        /* private function toggleGroup( groupNr:uint = 0, isSwitchedOn:Boolean = true ):void
         {
         var data:String = JSON.stringify (
         {
         "on": isSwitchedOn
         }
         );

         doLightRequest( 1, data );
         }*/


        public function alert( id:String, continuous:Boolean = true, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var alertMethod:String = continuous ? "lselect" : "select";

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
            schedule.command.address = schedule.command.address.split( "{userName}" ).join( HueDelegate.hash );

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


        public function addGroup( name:String, lights:Array, resultCallback:Function = null, faultCallback:Function = null):HueDelegate
        {
            var data:String = JSON.stringify (
                    {
                        "name": name,
                        "lights": lights
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

        private function init():void
        {

//            addEventListener( Event.ENTER_FRAME, enterFrameHandler );
//            getInfo();
//            addSchedule();
//            getSchedules();
//            removeSchedule(1)
//            toggleLight(false);
//            getGroup(2);
//            removeGroup(1);
//            getGroups();
//            addGroup();

//            trace(0.25*0xffff);
//            changeGroup( 0, 0.75, 1, 1, 0 );
//            changeGroup( 0, 0.25, 1, 0.25, 2 );
//            addSchedule();

            /*changeLightColor( 0.8, 0.5, 0, 2 );
            setTimeout(step1, 1000);
            setTimeout(step2, 1500);*/

        }

        /* private function step1():void
         {
         changeLightColor( 0.5, 1, 1, 1 );
         }


         private function step2():void
         {
         changeLightColor( Math.random(), 0.5, 0.15, 10 );
         }*/


        private function doRequest( path:String = "", data:String = null, method:String = URLRequestMethod.GET, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var delegate:HueDelegate = new HueDelegate( path, data, method, [ resultCallback ], [ faultCallback ] );
            delegate.addEventListener( AsyncDelegateEvent.RESULT, handleDelegateResult );
            delegate.addEventListener( AsyncDelegateEvent.FAULT, handleDelegateFault );
            delegate.execute();

            return delegate;
        }


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