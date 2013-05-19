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

package nl.imotion.hue.manager.entities
{
    import flash.geom.Point;

    import nl.imotion.hue.manager.enums.ColorMode;
    import nl.imotion.hue.manager.enums.Effect;

    import nl.imotion.utils.range.Range;


    /**
     * @author Pieter van de Sluis
     */
    public class HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        protected static const ERROR_INVALID_OBJECT:String = "Properties object is invalid";

        private var _isOn:Boolean;

        private var _id:String;
        private var _name:String;

        private var _brightness:uint;

        private var _hue:uint;
        private var _saturation:uint;

        private var _xy:Point;

        private var _colorTemperature:uint;

        private var _effect:String;
        private var _colorMode:String;

        private var _hueRange:Range = new Range( 0x0000, 0xffff );
        private var _brightnessRange:Range = new Range( 0x00, 0xfe );
        private var _saturationRange:Range = new Range( 0x00, 0xfe );
        private var _colorTemperatureRange:Range = new Range( 154, 500 );

        private var _updateObject:Object;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueEntity( id:String )
        {
            _id = id;

            _effect = Effect.NONE;
            _colorMode = ColorMode.COLOR_TEMPERATURE;
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function fromObject( propsObject:Object ):void
        {
            try
            {
                _name = propsObject.name;
            }
            catch ( e:Error )
            {
                throw new Error( ERROR_INVALID_OBJECT  );
            }
        }

        public function toStateObject():Object
        {
            var obj:Object =
            {
                "bri": _brightness,
                "on": _isOn
            };

            switch ( _colorMode )
            {
                case ColorMode.HUE_SATURATION:
                    obj.hue = _hue;
                    obj.sat = _saturation;
                    break;

                case ColorMode.COLOR_TEMPERATURE:
                    obj.ct = _colorTemperature;
                    break;

                case ColorMode.XY:
                    obj.xy = [ _xy.x, _xy.y ];
                    break;
            }

            return obj;
        }


        public function hasUpdate():Boolean
        {
            return ( _updateObject != null );
        }


        public function flushUpdateObject():Object
        {
            var tempObject:Object = _updateObject;

            _updateObject = null;

            return tempObject;
        }


        public function invalidate():Object
        {
            _updateObject = toStateObject();

            return _updateObject;
        }

        // ____________________________________________________________________________________________________
        // PRIVATE



        // ____________________________________________________________________________________________________
        // PROTECTED

        protected function basePropsFromObject( basePropsObject:Object ):void
        {
            _isOn = basePropsObject.on;
            _hue = basePropsObject.hue;
            _brightness = basePropsObject.bri;
            _saturation = basePropsObject.sat;
            _xy = new Point( basePropsObject.xy[0], basePropsObject.xy[1] );
            _colorTemperature = basePropsObject.ct;
            _effect = basePropsObject.effect;
            _colorMode = basePropsObject.colormode;
        }


        protected function addToUpdate( newObject:Object ):void
        {
            if ( !_updateObject )
            {
                _updateObject = newObject;
            }
            else
            {
                for ( var key:String in newObject )
                {
                    _updateObject[ key ] = newObject[ key ];
                }
            }
        }

        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS


        public function get id():String
        {
            return _id;
        }
        public function set id( value:String ):void
        {
            _id = value;
        }

        [Bindable]
        public function get name():String
        {
            return _name;
        }
        public function set name( value:String ):void
        {
            _name = value;
        }


        [Bindable]
        public function get isOn():Boolean
        {
            return _isOn;
        }
        public function set isOn( value:Boolean ):void
        {
            if ( _isOn == value ) return;

            _isOn = value;
            addToUpdate( { on: _isOn } );
        }


        [Bindable]
        public function get hue():uint
        {
            return _hue;
        }
        public function set hue( value:uint ):void
        {
            if ( _hue == value ) return;

            _hue = _hueRange.constrain( value );
            _colorMode = ColorMode.HUE_SATURATION;
            addToUpdate( { hue: _hue } );
        }

        [Bindable]
        public function get brightness():uint
        {
            return _brightness;
        }
        public function set brightness( value:uint ):void
        {
            if ( _brightness == value ) return;

            _brightness = _brightnessRange.constrain( value );
            addToUpdate( { bri: _brightness } );
        }

        [Bindable]
        public function get saturation():uint
        {
            return _saturation;
        }
        public function set saturation( value:uint ):void
        {
            if ( _saturation == value ) return;

            _saturation = _saturationRange.constrain( value );
            _colorMode = ColorMode.HUE_SATURATION;
            addToUpdate( { sat: _saturation } );
        }

        [Bindable]
        public function get xy():Point
        {
            return _xy;
        }
        public function set xy( value:Point ):void
        {
            if ( _xy && _xy.x == value.x && _xy.y == value.y ) return;

            _xy = value;
            _colorMode = ColorMode.XY;
            addToUpdate( { xy: [ _xy.x, _xy.y ] } );
        }

        [Bindable]
        public function get colorTemperature():uint
        {
            return _colorTemperature;
        }
        public function set colorTemperature( value:uint ):void
        {
            if ( _colorTemperature == value ) return;

            _colorTemperature = _colorTemperatureRange.constrain( value );
            _colorMode = ColorMode.COLOR_TEMPERATURE;
            addToUpdate( { ct: _colorTemperature } );
        }

        [Bindable]
        public function get effect():String
        {
            return _effect;
        }
        public function set effect( value:String ):void
        {
            if ( _effect == value || Effect.getAll().indexOf( value ) == -1 ) return;

            _effect = value;
            addToUpdate( { effect: _effect } );
        }

        public function get colorMode():String
        {
            return _colorMode;
        }


        public function get saturationRange():Range
        {
            return _saturationRange;
        }


        public function get hueRange():Range
        {
            return _hueRange;
        }


        public function get brightnessRange():Range
        {
            return _brightnessRange;
        }


        public function get colorTemperatureRange():Range
        {
            return _colorTemperatureRange;
        }


        public function get updateObject():Object
        {
            return _updateObject;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS

    }
}