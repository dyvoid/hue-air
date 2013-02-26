package nl.imotion.hue.entities
{
    import flash.geom.Point;

    import nl.imotion.hue.enums.Alert;


    /**
     * @author Pieter van de Sluis
     */
    public class HueLight extends HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _alert          :String;

        private var _reachable      :Boolean;

        private var _type           :String;
        private var _modelID        :String;
        private var _swVersion      :String;
        private var _pointSymbol    :Object;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueLight( id:String, propsObject:Object = null )
        {
            super( id );

            if ( propsObject )
            {
                fromObject( propsObject );
            }
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function fromObject( propsObject:Object ):void
        {
            try
            {
                basePropsFromObject( propsObject.state );
                _alert = propsObject.state.alert;
                _reachable = propsObject.state.reachable;
                _type = propsObject.type;
                name = propsObject.name;
                _modelID = propsObject.modelid;
                _swVersion = propsObject.swversion;
                _pointSymbol = propsObject.pointsymbol;

                isInvalid = false;
            }
            catch ( e:Error )
            {
                throw new Error( "Properties object is invalid" );
            }
        }


        override public function toStateObject():Object
        {
            var obj:Object = super.toStateObject();
            obj.alert = _alert;

            return obj;
        }


        public function alert( isLongSelect:Boolean = false ):void
        {
            _alert = isLongSelect ? Alert.LONG_SELECT : Alert.SELECT;
            isInvalid = true;
        }

        // ____________________________________________________________________________________________________
        // PRIVATE


        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get alertState():String
        {
            return _alert;
        }


        public function get reachable():Boolean
        {
            return _reachable;
        }


        public function get type():String
        {
            return _type;
        }


        public function get modelID():String
        {
            return _modelID;
        }


        public function get swVersion():String
        {
            return _swVersion;
        }


        public function get pointSymbol():Object
        {
            return _pointSymbol;
        }


        override public function set isInvalid( value:Boolean ):void
        {
            super.isInvalid = value;

            // Reset alert state, otherwise we will send it with every invalidation
            if ( !value )
            {
                _alert = Alert.NONE;
            }
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}