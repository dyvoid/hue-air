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
    import flash.geom.Point;
    import flash.net.URLRequestMethod;

    import nl.imotion.delegates.AsyncDelegate;
    import nl.imotion.delegates.events.AsyncDelegateEvent;
    import nl.imotion.utils.range.Range;

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

        /**
         * Makes a request to the Hue Bridge
         *
         * @param path                  the path of the request
         * @param data                  the data to be send
         * @param urlRequestMethod      the <code>UrlRequestMethod</code> to be used
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function doRequest( path:String = "", data:Object = null, urlRequestMethod:String = URLRequestMethod.GET, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var stringifiedData:String;

            if ( data )
            {
                stringifiedData = JSON.stringify( data );
            }

            return storeAndExecute( new HueDelegate( path, stringifiedData, urlRequestMethod, [ resultCallback ], [ faultCallback ] ) ) as HueDelegate;
        }

        // --- Configuration

        /**
         * Returns a list of all configuration elements in the bridge.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getConfig( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/config", null, resultCallback, faultCallback );
        }


        /**
         * Allows the user to set configuration values.
         *
         * @param data                  an object containing the configuration values
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setConfig( data:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/config", data, resultCallback, faultCallback );
        }


        /**
         * Creates a new user.
         *
         * @param deviceType            description of the type of device associated with this username
         * @param userName              the user name
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function createUser( deviceType:String, userName:String = null, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "devicetype": deviceType,
                "username": userName
            };

            return doRequest( "", data, URLRequestMethod.POST, resultCallback, faultCallback );
        }


        /**
         * Deletes the specified user from the whitelist.
         *
         * @param userName              the user name of the user that is to be deleted
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function deleteUser( userName:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doDelete( "/config/whitelist/" + userName, null, resultCallback, faultCallback );
        }


        /**
         * Fetches the entire datastore from the device, including settings and state information for lights, groups, schedules and configuration.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getFullState( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "", null, resultCallback, faultCallback );
        }

        // ---

        // --- Portal

        /**
         * Attempts to discover the Bridge through the Hue Portal
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function discoverBridgeThroughPortal( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( HueDelegate.DISCOVER, null, resultCallback, faultCallback );
        }

        // ---

        // --- Lights

        /**
         * Gets the attributes and state of a given light.
         *
         * @param lightID               the ID of the light
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getLight( lightID:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights/" + lightID, null, resultCallback, faultCallback );
        }


        /**
         * Gets a list of all lights that have been discovered by the bridge.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getAllLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights", null, resultCallback, faultCallback );
        }


        /**
         * Gets a list of lights that were discovered the last time a search for new lights was performed. The list of new lights is always deleted when a new search is started.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getNewLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/lights/new", null, resultCallback, faultCallback );
        }


        /**
         * Starts a search for new lights.
         * <p>
         * The bridge will search for 1 minute and will add a maximum of 15 new lights. To add further lights, the command needs to be sent again after the search has completed. If a search is already active, it will be aborted and a new search will start.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function searchNewLights( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPost( "/lights", null, resultCallback, faultCallback );
        }

        /**
         * Allows the user to turn the light on and off, modify the hue and effects.
         *
         * @param lightID               the ID of the light
         * @param state                 an <code>Object</code> containing the new state of the light
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setLightState( lightID:String, state:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/lights/" + lightID + "/state", state, resultCallback, faultCallback );
        }


        /**
         * Used to rename lights. A light can have its name changed when in any state, including when it is unreachable or off.
         *
         * @param lightID               the id of the light
         * @param name                  the new name
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function renameLight( lightID:String, name:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "name": name
            };

            return doPut(  "/lights/" + lightID, data, resultCallback, faultCallback );
        }


        /**
         * Sets the hue, saturation and brightness of a light
         *
         * @param lightID               the ID of the light
         * @param hue                   hue of the light. This is a wrapping value between 0 and 65535.
         * @param saturation            saturation of the light. 255 is the most saturated (colored) and 0 is the least saturated (white).
         * @param brightness            brightness of the light. This is a scale from the minimum brightness the light is capable of, 0, to the maximum capable brightness, 255.
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setLightHSB( lightID:String, hue:Number = 0, saturation:Number = 0.75, brightness:Number = 1, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var state:Object =
            {
                hue:hue,
                sat:saturation,
                bri:brightness,
                transitiontime:transitionTime
            };

            return setLightState( lightID, state, resultCallback, faultCallback );
        }


        /**
         * Sets the mired color temperature of a light
         * @param lightID               the ID of the light
         * @param ct                    the mired color temperature. Should be a value between 153 and 500.
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setLightCT( lightID:String, ct:Number = 153, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var ctRange:Range = new Range( 153, 500 );

            var state:Object =
            {
                ct: ctRange.constrain( ct ),
                transitiontime:transitionTime
            };

            return setLightState( lightID, state, resultCallback, faultCallback );
        }

        /**
         * Sets the mired color temperature of a light
         * @param lightID               the ID of the light
         * @param xy                    The x and y coordinates of a color in CIE color space. Both x and y must be between 0 and 1.
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setLightXY( lightID:String, xy:Point, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var range:Range = new Range( 0, 1 );
            var xyArr:Array = [ range.constrain( xy.x ), range.constrain( xy.y ) ];

            var state:Object =
            {
                xy: xyArr,
                transitiontime:transitionTime
            };

            return setLightState( lightID, state, resultCallback, faultCallback );
        }


        /**
         * Sets the dynamic effect of a light
         *
         * @param lightID               the ID of the light
         * @param effect                the dynamic effect of the light
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setLightEffect( lightID:String, effect:String, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var state:Object =
            {
                effect: effect,
                transitiontime: transitionTime
            };

            return setLightState( lightID, state, resultCallback, faultCallback );
        }


        /**
         * Switches a particular light on or off.
         *
         * @param lightID               the ID of the light
         * @param isSwitchedOn          whether the light should be switched on or not
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function toggleLight( lightID:String, isSwitchedOn:Boolean, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                "on": isSwitchedOn
            };

            return setLightState( lightID, data, resultCallback, faultCallback );
        }


        /**
         * Sets the alert state for a particular light
         *
         * @param lightID               the ID of the light
         * @param useBreathCycle        controls whether a single flash or a breath cycle is used
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function alertLight( lightID:String, useBreathCycle:Boolean = false, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var alertMethod:String = useBreathCycle ? "lselect" : "select";

            var data:Object =
            {
                "alert":alertMethod
            };

            return setLightState( lightID, data, resultCallback, faultCallback );
        }

        // ---

        // --- Groups

        /**
         * Gets a list of all groups that have been added to the bridge.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getAllGroups( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/groups", null, resultCallback, faultCallback );
        }


        /**
         * Gets the name, light membership and last command for a given group.
         *
         * @param groupID               the ID of the group
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getGroup( groupID:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/groups/" + groupID, null, resultCallback, faultCallback );
        }


        /**
         * Allows the user to modify the name and light membership of a group.
         *
         * @param groupID               the ID of the group
         * @param name                  the new name of the group
         * @param lightIDs              the ID of the lights
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupAttributes( groupID:String, name:String, lightIDs:Array, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                name: name,
                lights: lightIDs
            };

            return doPut( "/groups/" + groupID, data, resultCallback, faultCallback );
        }

        /**
         * Changes the name of a given group
         *
         * @param groupID               the ID of the group
         * @param name                  the new name of the group
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function renameGroup( groupID:String, name:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                name: name
            };

            return doPut( "/groups/" + groupID, data, resultCallback, faultCallback );
        }


        /**
         * Changes the light membership of a given group
         *
         * @param groupID               the ID of the group
         * @param lightIDs              the ID of the lights
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupLights( groupID:String, lightIDs:Array, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var data:Object =
            {
                lights: lightIDs
            };

            return doPut( "/groups/" + groupID, data, resultCallback, faultCallback );
        }


        /**
         * Modifies the state of all lights in a group.
         * <p>
         * User created groups will have an ID of 1 or higher; however a special group with an ID of 0 also exists containing all the lamps known by the bridge.
         *
         * @param groupID               the ID of the group
         * @param state                 an <code>Object</code> containing the new state of the group
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupState( groupID:String, state:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doPut( "/groups/" + groupID + "/action", state, resultCallback, faultCallback );
        }


        /**
         * Sets the hue, saturation and brightness of a group
         *
         * @param groupID               the ID of the group
         * @param hue                   hue of the light. This is a wrapping value between 0 and 65535.
         * @param saturation            saturation of the light. 255 is the most saturated (colored) and 0 is the least saturated (white).
         * @param brightness            brightness of the light. This is a scale from the minimum brightness the light is capable of, 0, to the maximum capable brightness, 255.
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupHSB( groupID:String, hue:Number = 0, saturation:Number = 0.75, brightness:Number = 1, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var state:Object =
            {
                hue: hue,
                sat: saturation,
                bri: brightness,
                transitiontime: transitionTime
            };

            return setGroupState( groupID, state, resultCallback, faultCallback );
        }


        /**
         * Sets the mired color temperature of a group
         * @param groupID               the ID of the group
         * @param ct                    the mired color temperature. Should be a value between 153 and 500.
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupCT( groupID:String, ct:Number = 153, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var ctRange:Range = new Range( 153, 500 );

            var state:Object =
            {
                ct: ctRange.constrain( ct ),
                transitiontime: transitionTime
            };

            return setGroupState( groupID, state, resultCallback, faultCallback );
        }


        /**
         * Sets the mired color temperature of a group
         * @param groupID               the ID of the group
         * @param xy                    The x and y coordinates of a color in CIE color space. Both x and y must be between 0 and 1.
         * @param transitionTime        The duration of the transition from the current to the new state.
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupXY( groupID:String, xy:Point, transitionTime:Number = 4, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var range:Range = new Range( 0, 1 );
            var xyArr:Array = [ range.constrain( xy.x ), range.constrain( xy.y ) ];

            var state:Object =
            {
                xy: xyArr,
                transitiontime:transitionTime
            };

            return setGroupState( groupID, state, resultCallback, faultCallback );
        }


        /**
         * Sets the dynamic effect of a group
         *
         * @param groupID               the ID of the group
         * @param effect                the dynamic effect of the lights
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function setGroupEffect( groupID:String, effect:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var state:Object =
            {
                effect: effect
            };

            return setGroupState( groupID, state, resultCallback, faultCallback );
        }


        /**
         * Switches a particular group on or off.
         *
         * @param groupID               the ID of the group
         * @param isSwitchedOn          whether the group should be switched on or not
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function toggleGroup( groupID:String, isSwitchedOn:Boolean, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var state:Object =
            {
                "on": isSwitchedOn
            };

            return setGroupState( groupID, state, resultCallback, faultCallback );
        }


        /**
         * Sets the alert state for a particular group
         *
         * @param groupID               the ID of the group
         * @param useBreathCycle        controls whether a single flash or a breath cycle is used
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function alertGroup( groupID:String, useBreathCycle:Boolean = false, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            var alertMethod:String = useBreathCycle ? "lselect" : "select";

            var state:Object =
            {
                "alert": alertMethod
            };

            return setGroupState( groupID, state, resultCallback, faultCallback );
        }

        // Not yet part of the official API
        /*public function createGroup( data:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
         {
         return doPost( "/groups, data, resultCallback, faultCallback );
         }*/

        // Not yet part of the official API
        /*public function deleteGroup( id:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
         {
         return doDelete( "/groups/" + id, data, resultCallback, faultCallback );
         }*/

        // ---

        // Schedules

        /**
         * Gets a list of all schedules that have been added to the bridge.
         *
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getAllSchedules( resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/schedules", null, resultCallback, faultCallback );
        }


        /**
         * Gets all attributes for a schedule.
         *
         * @param scheduleID            the ID of the schedule
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function getSchedule( scheduleID:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doGet( "/schedules/" + scheduleID, null, resultCallback, faultCallback );
        }


        /**
         * Allows the user to create a new schedule.
         *
         * @param schedule              an <code>Object</code> containing the full schedule data
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function createSchedule( schedule:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            schedule.command.address = schedule.command.address.split( "{userName}" ).join( HueDelegate.userName );

            return doPost( "/schedules", schedule, resultCallback, faultCallback );
        }


        /**
         * Allows the user to change attributes of a schedule.
         *
         * @param scheduleID            the ID of the schedule
         * @param schedule              an <code>Object</code> containing the full schedule data
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function changeSchedule( scheduleID:String, schedule:Object, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            schedule.command.address = schedule.command.address.split( "{userName}" ).join( HueDelegate.userName );

            return doPut( "/schedules/" + scheduleID, schedule, resultCallback, faultCallback );
        }


        /**
         * Deletes a schedule from the bridge.
         *
         * @param scheduleID            the ID of the schedule
         * @param resultCallback        callback to be used for a successful result
         * @param faultCallback         callback to be used for an unsuccessful result
         * @return                      the <code>HueDelegate</code> that will be used in the communication
         */
        public function deleteSchedule( scheduleID:String, resultCallback:Function = null, faultCallback:Function = null ):HueDelegate
        {
            return doDelete( "/schedules/" + scheduleID, null, resultCallback, faultCallback );
        }

        // ---


        // ____________________________________________________________________________________________________
        // PRIVATE

        private function storeAndExecute( delegate:AsyncDelegate ):AsyncDelegate
        {
            // Strong event listeners will make sure the delegate does not get garbage collected
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


        private function removeDelegateListeners( delegate:* ):void
        {
            delegate.removeEventListener( AsyncDelegateEvent.RESULT, handleDelegateResult );
            delegate.removeEventListener( AsyncDelegateEvent.FAULT, handleDelegateResult );
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

        /**
         * The IP Address of the Hue Bridge
         */
        public function get ipAddress():String
        {
            return HueDelegate.ipAddress;
        }
        public function set ipAddress( value:String ):void
        {
            HueDelegate.ipAddress = value;
        }


        /**
         * The whitelisted user name to be used for the app
         */
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
            removeDelegateListeners( e.target );
            onResult( e.data );
        }


        private function handleDelegateFault( e:AsyncDelegateEvent ):void
        {
            removeDelegateListeners( e.target );
            onFault( e.data );
        }

    }
}