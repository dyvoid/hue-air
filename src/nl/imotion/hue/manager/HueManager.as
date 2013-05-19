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

package nl.imotion.hue.manager
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import nl.imotion.hue.connector.HueConnector;
    import nl.imotion.hue.manager.entities.HueEntity;
    import nl.imotion.hue.manager.entities.HueGroup;
    import nl.imotion.hue.manager.entities.HueLight;
    import nl.imotion.hue.manager.entities.HueSchedule;

    /**
     * @author Pieter van de Sluis
     */
    public class HueManager
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _connector:HueConnector;

        private var _lightsMap:Vector.<HueLight>;
        private var _groupsMap:Vector.<HueGroup>;
        private var _entityMap:Vector.<HueEntity>;

        private var _queue:Vector.<HueEntity>;
        private var _queueTimer:Timer;

        private var _lightRequestRateLimit:uint = 20;
        private var _groupRequestRateLimit:uint = 1;

        private var _lastLightRequestTime:uint = 0;
        private var _lastGroupRequestTime:uint = 0;

        private var _heartbeatInterval:uint = 5000;
        private var _lastHeartbeatTime:uint = 0;

        private var _isReady:Boolean = false;

        private var _useTransitionSmoothing:Boolean = true;

        private var _connectResultCallback:Function;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueManager()
        {
            init();
        }


        private function init():void
        {
            _connector = new HueConnector();

            _lightsMap = new Vector.<HueLight>();
            _groupsMap = new Vector.<HueGroup>();
            _entityMap = new Vector.<HueEntity>();

            _queue = new Vector.<HueEntity>();

            _queueTimer = new Timer( 1000 / ( _lightRequestRateLimit - 1 ) );
            _queueTimer.addEventListener( TimerEvent.TIMER, handleTimerTick );
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function discoverBridge( resultCallback:Function, faultCallback:Function ):void
        {
            _connector.discoverBridgeThroughPortal( resultCallback, faultCallback );
        }


        public function connect( ipAddress:String, userName:String, resultCallback:Function, faultCallback:Function ):void
        {
            _connector.ipAddress = ipAddress;
            _connector.userName = userName;

            _connectResultCallback = resultCallback;

            _connector.getFullState( onGetFullState, faultCallback );
        }


        public function createUser( userName:String, deviceType:String, resultCallback:Function = null, faultCallback:Function = null ):void
        {
            _connector.createUser( userName, deviceType, resultCallback, faultCallback );
        }


        public function createSchedule( schedule:HueSchedule, resultCallback:Function = null, faultCallback:Function = null ):void
        {
            _connector.createSchedule( schedule.toObject(), resultCallback, faultCallback );
        }


        public function invalidateLightByID( lightID:String ):Object
        {
            var light:HueLight = getLightByID( lightID );

            if ( light )
            {
                return light.invalidate();
            }

            return null;
        }


        public function invalidateAllLights():void
        {
            for each ( var light:HueEntity in _lightsMap )
            {
                light.invalidate();
            }
        }

        // ____________________________________________________________________________________________________
        // PRIVATE

        private function startQueue():void
        {
            _queueTimer.start();
        }


        private function stopQueue():void
        {
            _queueTimer.stop();
        }


        private function processQueue():void
        {
            var entityMapLength:uint = _entityMap.length;
            var entityMapClone:Vector.<HueEntity> = _entityMap.concat();

            // Update the queue
            for ( var i:int = 0; i < entityMapLength; i++ )
            {
                var rndIndex:uint = Math.floor( Math.random() * entityMapClone.length );

                var entity:HueEntity = entityMapClone[ rndIndex ];
                entityMapClone.splice( rndIndex, 1 );

                var queuePosition:int = _queue.indexOf( entity );

                if ( entity.hasUpdate() )
                {
                    if ( queuePosition == -1 )
                    {
                        _queue.push( entity );
                    }
                }
                else
                {
                    if ( queuePosition != -1 )
                    {
                        _queue.splice( queuePosition, 1 );
                    }
                }
            }

            // Process the first available entity
            for ( var j:int = 0; j < _queue.length; j++ )
            {
                entity = _queue[ j ];

                if ( entity is HueLight )
                {
                    if ( ( getTimer() - _lastLightRequestTime ) > ( 1000 / _lightRequestRateLimit ) )
                    {
                        _connector.setLightState( entity.id, getUpdateObject( entity ) );
                        _lastLightRequestTime = getTimer();
                        _queue.splice( j, 1 );
                        break;
                    }
                }
                else if ( entity is HueGroup )
                {
                    if ( ( getTimer() - _lastGroupRequestTime ) > ( 1000 / _groupRequestRateLimit ) )
                    {
                        _connector.setGroupState( entity.id, getUpdateObject( entity ) );
                        _lastGroupRequestTime = getTimer();
                        _queue.splice( j, 1 );
                        break;
                    }
                }
            }

            if ( getTimer() - _lastHeartbeatTime > _heartbeatInterval )
            {
                _connector.getFullState( onGetFullState );
                _lastHeartbeatTime = getTimer();
            }
        }


        private function getUpdateObject( entity:HueEntity ):Object
        {
            var updateObject:Object = entity.flushUpdateObject();

            if ( _useTransitionSmoothing )
            {
                updateObject.transitiontime = Math.floor( ( _queueTimer.delay * _queue.length ) / 100 ) + 1;
            }

            return updateObject;
        }


        private function onGetFullState( data:Object ):void
        {
            var key:String;

            var lights:Object = data.lights;
            for ( key in lights )
            {
                var light:HueLight = getLightByID( key );

                if ( !light )
                {
                    light = new HueLight( key, lights[ key ] );
                    _lightsMap.push( light );
                    _entityMap.push( light );
                }
                else
                {
                    light.fromObject( lights[ key ] );
                }
            }

            if ( _groupsMap.length == 0 )
            {
                // Add default group
                var group:HueGroup = new HueGroup( "0" );
                group.name = "Lightset 0";
                for each ( light in _lightsMap )
                {
                    group.addLight( light );
                }
                _groupsMap.push( group );
                _entityMap.push( group );
            }

            var groups:Object = data.groups;
            for ( key in groups )
            {
                group = getGroupByID( key );

                if ( !group )
                {
                    group = new HueGroup( key, groups[ key ] );

                    _groupsMap.push( group );
                    _entityMap.push( group );
                }
                else
                {
                    group.fromObject( groups[ key ] );
                }

                for ( var i:int = 0; i < groups[ key ].lights.length; i++ )
                {
                    var lightID:String = groups[ key ].lights[ i ];

                    if ( !group.getLightByID( lightID ) )
                    {
                        group.addLight( getLightByID( lightID ) );
                    }

                }
            }

            if ( ! _isReady )
            {
                _lastHeartbeatTime = getTimer();
                startQueue();

                _isReady = true;

                if ( _connectResultCallback != null )
                {
                    var callback:Function = _connectResultCallback;
                    _connectResultCallback = null;

                    callback();
                }
            }
        }


        private function handleTimerTick( e:TimerEvent ):void
        {
            processQueue();
        }


        private function getLightByID( id:String ):HueLight
        {
            for each ( var light:HueLight in _lightsMap )
            {
                if ( light.id == id )
                    return light;
            }

            return null;
        }


        private function getGroupByID( id:String ):HueGroup
        {
            for each ( var group:HueGroup in _groupsMap )
            {
                if ( group.id == id )
                    return group;
            }

            return null;
        }

        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get lightsMap():Vector.<HueLight>
        {
            return _lightsMap;
        }


        public function get groupsMap():Vector.<HueGroup>
        {
            return _groupsMap;
        }


        public function get entityMap():Vector.<HueEntity>
        {
            return _entityMap;
        }


        public function get lightRequestRateLimit():uint
        {
            return _lightRequestRateLimit;
        }
        public function set lightRequestRateLimit( value:uint ):void
        {
            _lightRequestRateLimit = value;
        }


        public function get isReady():Boolean
        {
            return _isReady;
        }


        public function get ipAddress():String
        {
            return _connector.ipAddress;
        }
        public function set ipAddress( value:String ):void
        {
            _connector.ipAddress = value;
        }

    }
}