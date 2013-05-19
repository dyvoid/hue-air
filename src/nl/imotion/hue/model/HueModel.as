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

package nl.imotion.hue.model
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import nl.imotion.bindmvc.model.BindModel;
    import nl.imotion.hue.connector.HueConnector;
    import nl.imotion.hue.entities.HueEntity;
    import nl.imotion.hue.entities.HueGroup;
    import nl.imotion.hue.entities.HueLight;
    import nl.imotion.hue.entities.HueSchedule;
    import nl.imotion.hue.notes.ModelReadyNote;
    import nl.imotion.hue.vo.VOLogin;


    /**
     * @author Pieter van de Sluis
     */
    public class HueModel extends BindModel
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        public static const NAME:String = "nl.imotion.hue.model.HueModel"

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

        private var _isReady:Boolean = false;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueModel()
        {
            super( NAME );

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

        public function discoverBridge( onResult:Function, onFault:Function ):void
        {
            _connector.discoverBridgeThroughPortal( onResult, onFault );
        }


        public function register( userName:String, deviceType:String, onResult:Function, onFault:Function ):void
        {
            _connector.createUser( userName, deviceType, onResult, onFault );
        }


        public function connect( loginData:VOLogin ):void
        {
            _connector.ipAddress = loginData.ipAddress;
            _connector.userName = loginData.userName;

            _connector.getFullState( onGetInfoResult );
        }


        public function addSchedule( schedule:HueSchedule ):void
        {
            _connector.createSchedule( schedule.toObject() );
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
        }


        private function getUpdateObject( entity:HueEntity ):Object
        {
            var updateObject:Object = entity.flushUpdateObject();
            updateObject.transitiontime = Math.floor( ( _queueTimer.delay * _queue.length ) / 100 ) + 1;

            return updateObject
        }


        private function onGetInfoResult( data:Object ):void
        {
            var key:String;

            var lights:Object = data.lights;
            for ( key in lights )
            {
                var light:HueLight = new HueLight( key, lights[ key ] );

                _lightsMap.push( light );
                _entityMap.push( light );
            }

            // Add default group
            var group:HueGroup = new HueGroup( "0" );
            group.name = "All lights";
            for each ( light in _lightsMap )
            {
                group.addLight( light );
            }
            _groupsMap.push( group );
            _entityMap.push( group );

            var groups:Object = data.groups;
            for ( key in groups )
            {
                group = new HueGroup( key, groups[ key ] );

                for ( var i:int = 0; i < groups[ key ].lights.length; i++ )
                {
                    group.addLight( getLightByID( groups[ key ].lights[ i ] ) );
                }

                _groupsMap.push( group );
                _entityMap.push( group );
            }

            startQueue();

            _isReady = true;
            dispatchNote( new ModelReadyNote( _lightsMap, _groupsMap, _entityMap) );

            _connector.getGroup("0");

            /*_lightsMap[0].brightness = 0;
            _lightsMap[1].brightness = 0;
            _lightsMap[2].brightness = 0;
            _lightsMap[3].brightness = 0;
            TweenMax.allTo( [_lightsMap[0],_lightsMap[1],_lightsMap[2],_lightsMap[3]], 0.5, { brightness: 255, saturation: 0, ease: Quint.easeInOut } );
            TweenMax.allTo( [_lightsMap[0],_lightsMap[1],_lightsMap[2],_lightsMap[3]], 0.5, { brightness: 155, hue: 1255, saturation: 255, ease: Quint.easeInOut, delay: 0.5 } );*/
        }


        private function handleTimerTick( e:TimerEvent ):void
        {
            processQueue();
        }


        private function invalidateAllLights():void
        {
            for each ( var light:HueEntity in _lightsMap )
            {
                light.invalidate();
            }
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

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}