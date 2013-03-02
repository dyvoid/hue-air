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

    import nl.imotion.bindmvc.model.BindModel;
    import nl.imotion.hue.connector.HueConnector;
    import nl.imotion.hue.entities.HueEntity;
    import nl.imotion.hue.entities.HueGroup;
    import nl.imotion.hue.entities.HueLight;
    import nl.imotion.hue.notes.ModelReadyNote;


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

        private var _rateLimit:uint = 20;

        private var _masterBrightness:Number = 1;
        private var _masterIsOn:Boolean = true;

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
            _connector = new HueConnector( "192.168.1.10", "c7a514b2b5a681399ecfb86e1265c49c" );

            _lightsMap = new Vector.<HueLight>();
            _groupsMap = new Vector.<HueGroup>();
            _entityMap = new Vector.<HueEntity>();

            _queue = new Vector.<HueEntity>();

            _queueTimer = new Timer( 1000 / _rateLimit );
            _queueTimer.addEventListener( TimerEvent.TIMER, handleTimerTick );

            _connector.getInfo( onGetInfoResult );
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function discover( onResult:Function, onFault:Function ):void
        {
            _connector.discover( onResult, onFault );
        }


        public function register( userName:String, deviceType:String, onResult:Function, onFault:Function ):void
        {
            _connector.register( userName, deviceType, onResult, onFault );
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

            if ( _queue.length != 0 )
            {
                entity = _queue[ 0 ];

                var update:Object = entity.flushUpdateObject();
                update.bri = Math.round( entity.brightness * _masterBrightness );
                update.on = _masterIsOn ? entity.isOn : false;

                if ( entity is HueLight )
                {
                    update.transitiontime = Math.round( ( _queueTimer.delay * _queue.length ) / 100 ) + 1;
                    _connector.updateLight( entity.id, update, onResult );
                }
                else
                {
                    update.transitiontime = Math.round( ( _queueTimer.delay * ( _queue.length + HueGroup( entity ).lights.length ) ) / 100 ) + 1;
                    _connector.updateGroup( entity.id, update, onResult );
                }

                _queue.shift();
            }
        }


        private function onResult( data:String ):void
        {
            trace( data );
        }


        private function onGetInfoResult( data:String ):void
        {
            trace( data );
            var result:Object = JSON.parse( data );

            var key:String;

            var lights:Object = result.lights;
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

            var groups:Object = result.groups;
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

        [Bindable]
        public function get masterBrightness():Number
        {
            return _masterBrightness;
        }
        public function set masterBrightness( value:Number ):void
        {
            if ( _masterBrightness == value ) return;

            _masterBrightness = value;
            invalidateAllLights();
        }


        [Bindable]
        public function get masterIsOn():Boolean
        {
            return _masterIsOn;
        }
        public function set masterIsOn( value:Boolean ):void
        {
            if ( _masterBrightness == value ) return;

            _masterIsOn = value;
            invalidateAllLights();
        }

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


        public function get rateLimit():uint
        {
            return _rateLimit;
        }
        public function set rateLimit( value:uint ):void
        {
            _rateLimit = value;
        }


        public function get isReady():Boolean
        {
            return _isReady;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}