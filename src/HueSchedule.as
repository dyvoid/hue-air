package
{
    import mx.formatters.DateFormatter;


    /**
     * @author Pieter van de Sluis
     */
    public class HueSchedule extends HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _time           :Date;
        private var _description    :String = "";

        private var _target         :HueEntity;
        private var _transitionTime :uint = 10;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueSchedule()
        {
            super( null );

            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function toObject():Object
        {
            var operationName:String;

            switch ( true )
            {
                case _target is HueLight:
                    operationName = "/lights/" + _target.id + "/state";
                    break;

                case _target is HueGroup:
                    operationName = "/groups/" + _target.id + "/action";
                    break;
            }

            var obj:Object =
            {
                "name": name,
                "time": getTimeString(),
                "description": _description,
                "command":
                {
                    "method": "PUT",
                    "address": "/api/{userName}" + operationName,
                    "body": toStateObject()
                }
            };

            return obj;
        }


        override public function toStateObject():Object
        {
            var obj:Object = super.toStateObject();
            obj.transitiontime = _transitionTime;

            return obj;
        }


        private function getTimeString():String
        {
            var dateString:String =
                    _time.fullYearUTC + "-" +
                    leadingZero( _time.getUTCMonth() + 1 ) + "-" +
                    leadingZero( _time.getUTCDate() ) + "T" +
                    leadingZero( _time.getUTCHours() ) + ":" +
                    leadingZero( _time.getUTCMinutes() ) + ":" +
                    leadingZero( _time.getUTCSeconds() );

            return dateString;
        }


        private function leadingZero( value:uint ):String
        {
            if( value < 10 )
            {
                return "0" + value;
            }

            return value.toString();
        }

        // ____________________________________________________________________________________________________
        // PRIVATE

        private function init():void
        {
            _time = new Date();
            isOn = true;
        }

        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        [Bindable]
        public function get time():Date
        {
            return _time;
        }
        public function set time( value:Date ):void
        {
            _time = value;
        }

        [Bindable]
        public function get description():String
        {
            return _description;
        }
        public function set description( value:String ):void
        {
            _description = value;
        }

        [Bindable]
        public function get target():HueEntity
        {
            return _target;
        }
        public function set target( value:HueEntity ):void
        {
            _target = value;
        }

        [Bindable]
        public function get transitionTime():uint
        {
            return _transitionTime;
        }
        public function set transitionTime( value:uint ):void
        {
            _transitionTime = value;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}