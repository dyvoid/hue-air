package nl.imotion.hue.entities
{
    import flash.geom.Point;

    import nl.imotion.hue.enums.ColorMode;
    import nl.imotion.hue.enums.Effect;

    import nl.imotion.utils.range.Range;


    /**
     * @author Pieter van de Sluis
     */
    public class HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

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

        private var _isInvalid:Boolean = false;

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

        public function toStateObject():Object
        {
            var obj:Object =
            {
                "bri": brightness,
                "on": isOn
            };

            switch ( colorMode )
            {
                case ColorMode.HUE_SATURATION:
                    obj.hue = hue;
                    obj.sat = saturation;
                    break;

                case ColorMode.COLOR_TEMPERATURE:
                    obj.ct = colorTemperature;
                    break;

                case ColorMode.XY:
                    obj.xy = [ xy.x, xy.y ];
                    break;
            }

            return obj;
        }

        // ____________________________________________________________________________________________________
        // PRIVATE


        // ____________________________________________________________________________________________________
        // PROTECTED

        protected function basePropsFromObject( basePropsObject:Object ):void
        {
            isOn = basePropsObject.on;
            hue = basePropsObject.hue;
            brightness = basePropsObject.bri;
            saturation = basePropsObject.sat;
            xy = new Point( basePropsObject.xy[0], basePropsObject.xy[1] );
            colorTemperature = basePropsObject.ct;
            effect = basePropsObject.effect;
            colorMode = basePropsObject.colormode;
            isInvalid = false;
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
            if ( _name == value ) return;

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
            _isInvalid = true;
        }

        [Bindable]
        public function get isInvalid():Boolean
        {
            return _isInvalid;
        }
        public function set isInvalid( value:Boolean ):void
        {
            _isInvalid = value;
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
            _isInvalid = true;
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
            _isInvalid = true;
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
            _isInvalid = true;
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
            _isInvalid = true;
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
            _isInvalid = true;
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
            _isInvalid = true;
        }

        [Bindable]
        public function get colorMode():String
        {
            return _colorMode;
        }
        public function set colorMode( value:String ):void
        {
            if ( _colorMode == value || ColorMode.getAll().indexOf( value ) == -1 ) return;

            _colorMode = value;
            _isInvalid = true;
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

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}